# Mejoras de Alta Disponibilidad — MongoDB, Redis, GaleraDB

En este documento registro los cambios que hice sobre el stack original para cerrar los puntos
2.1, 2.2, 2.3 y 3 de `ToDo.md`. Explico qué tenía el proyecto antes, qué decidí cambiar, por qué,
y cómo lo probé.

## 1. MongoDB

**Antes**: tenía un solo contenedor `mongodb`, sin ningún tipo de redundancia. Si ese contenedor
se caía, toda la base de datos quedaba inaccesible.

**Ahora**: monté tres contenedores — `mongo1`, `mongo2`, `mongo3` — que forman un *replica set*
(`rs0`). Esto significa que los tres nodos mantienen una copia sincronizada de los datos, y si uno
falla, los otros dos siguen funcionando. Además, agregué autenticación interna entre los nodos
mediante un keyfile (`mongodb/mongo-keyfile`). Tuve que "crear" ese keyfile dentro de una imagen
propia (`mongodb/Dockerfile`) en vez de montarlo como bind mount, porque en Windows los bind mounts
no respetan bien los permisos de archivo que Mongo exige para el keyfile.

- Hice que `mongo1` corra un script propio (`mongodb/init-replica.sh`), definido como `ENTRYPOINT`
  en `mongodb/Dockerfile`. Ese script arranca `mongod` normalmente y, **solo en `mongo1`**
  (cuando detecta la variable `INIT_REPLICA_SET=true`), ejecuta `rs.initiate()` para crear el
  replica set y crea el usuario root aprovechando la "localhost exception" de Mongo (una regla que
  permite crear el primer usuario sin autenticación previa, pero solo si la conexión viene del
  mismo contenedor por loopback). Por eso este paso tiene que correr *dentro* del propio
  contenedor `mongo1` y no desde un contenedor aparte — ahí esa excepción ya no aplicaría.
  `mongo2` y `mongo3` no hacen nada especial: solo arrancan `mongod` y esperan a que `mongo1` los
  invite a unirse al replica set.
- Actualicé la app (`application/index.js`, `application/init-db.js`) para que se conecte con
  `MONGO_HOSTS=mongo1:27017,mongo2:27017,mongo3:27017` y el parámetro `?replicaSet=rs0`. Con esto
  el driver de Mongo detecta automáticamente cuál de los tres nodos es el `PRIMARY` en cada
  momento, y si ese nodo cambia (por ejemplo, porque el primario se cayó y hubo una elección),
  el driver reconecta solo, sin que yo tenga que tocar nada en la app.

**Cómo lo probé**:
```bash
docker exec -it distributed-three-tier-mongo1-1 mongosh -u <user> -p <pass> --authenticationDatabase admin --eval "rs.status()"
docker compose stop mongo1
```
Con el primer comando confirmo que los tres nodos aparecen en el replica set y veo cuál es el
`PRIMARY`. Con el segundo, apago `mongo1` a propósito para verificar que la app sigue funcionando
porque Mongo elige un nuevo primario entre `mongo2` y `mongo3`.

## 2. Redis

**Decisión que tomé (punto 2.3)**: Redis en mi proyecto solo cachea el endpoint
`/products/cheapest` durante 60 segundos — es un caché desechable, no una fuente de verdad de
datos. Por eso decidí configurarlo **sin persistencia** (`--appendonly no --save ""`) en vez de
invertir esfuerzo en replicar ese estado: si se pierde el caché, simplemente se vuelve a generar
en la siguiente consulta, así que no vale la pena complicar la arquitectura por algo que no
necesita sobrevivir a un reinicio.

**Alta disponibilidad que sí implementé (punto 2.2)**: armé `redis-master` junto con
`redis-replica1` y `redis-replica2`, más tres instancias de `redis-sentinel` (`sentinel1/2/3`).
Sentinel es el componente de Redis que monitorea constantemente si el master sigue vivo. Si el
master se cae, las tres instancias de Sentinel se ponen de acuerdo por mayoría (quórum de 2 de 3)
y promueven automáticamente a una de las réplicas como nuevo master, sin que yo tenga que
intervenir manualmente.

- Modifiqué la app para que ya no apunte a un host fijo de Redis. Ahora uso la función
  `createSentinel()` del cliente oficial `redis` (versión 5), pasándole
  `REDIS_SENTINEL_HOSTS` (las direcciones de los tres Sentinel) y
  `REDIS_SENTINEL_NAME=mymaster` (el nombre lógico que usan los Sentinel para referirse al master
  actual). Con esto, la app le pregunta a Sentinel "¿quién es el master ahora?" en vez de asumir
  que siempre es el mismo contenedor.

**Cómo lo probé**:
```bash
docker compose stop redis-master
docker logs distributed-three-tier-redis-sentinel1-1
curl http://localhost/api/products/cheapest
```
Apago el master a propósito, reviso los logs de uno de los Sentinel para confirmar que detectó
la caída y promovió una réplica, y después hago una petición al endpoint cacheado para verificar
que la app se reconectó sola al nuevo master sin devolver error.

## 3. GaleraDB

**Problema que tenía originalmente**: la app se conectaba directo con `DB_HOST=galera1`. Esto
significaba que, aunque tuviera `galera2` y `galera3` funcionando perfectamente y con quórum
(mayoría del cluster viva), si específicamente `galera1` se caía, la app dejaba de funcionar
igual — porque nunca intentaba hablar con los otros dos nodos.

**Solución que implementé**: agregué un nuevo servicio, `galera-proxy`, que es un HAProxy
(configurado en `haproxy/galera.cfg`) ubicado delante de los tres nodos de Galera. Ahora la app
usa `DB_HOST=galera-proxy` y nunca se conecta directamente a un nodo — siempre pasa por el proxy,
que decide a cuál de los tres nodos sanos enviar cada conexión.

- **Cómo reparte las conexiones**: Galera es "multi-master", es decir, los tres nodos pueden
  recibir tanto lecturas como escrituras sin distinción (a diferencia de un esquema
  master-replica tradicional). Por eso configuré `galera-proxy` con el algoritmo `leastconn`
  (manda cada nueva conexión al nodo que menos conexiones activas tiene en ese momento) y no
  separé tráfico de lectura/escritura, porque los tres nodos aceptan ambos tipos de operación.
- **Revisé el límite del pool de conexiones** y decidí no cambiarlo: cada instancia de la app usa
  `connectionLimit: 10` (configurado en `application/index.js`). Como tengo 3 réplicas de la app
  corriendo, eso da un máximo de 30 conexiones concurrentes hacia la base de datos — un número muy
  por debajo de los límites por defecto que trae MariaDB/Galera, así que no hizo falta tocarlo.
- **Limitación que dejo documentada**: el healthcheck que usa `galera-proxy` para decidir si un
  nodo está "sano" es solo un TCP connect simple — es decir, únicamente verifica que el puerto
  responda, pero no revisa si la variable interna `wsrep_cluster_status` de ese nodo dice
  `Primary`. Esto significa que, en un escenario de split-brain (un nodo que quedó aislado y
  expulsado lógicamente del cluster pero cuyo proceso sigue corriendo), ese healthcheck lo
  seguiría marcando como "up" y el proxy le seguiría mandando tráfico, aunque ese nodo ya no
  forme parte del cluster real. Dejo esto señalado como una limitación conocida, consistente con
  lo que ya advertía el `TEST-PLAN.md` del proyecto.

**Cómo lo probé**:
```bash
docker compose stop galera1
curl http://localhost/api/products/cheapest
```
Apago `galera1` a propósito y hago una petición a un endpoint que consulta la base de datos, para
confirmar que `galera-proxy` redirige el tráfico a `galera2` o `galera3` automáticamente y la app
sigue respondiendo sin errores.

## Archivos que modifiqué o agregué

| Archivo | Qué hice |
|---|---|
| `docker-compose.yml` | Agregué los servicios `mongo1/2/3` (con auto-inicialización), `redis-master`, `redis-replica1/2`, los tres `redis-sentinel`, y `galera-proxy`. |
| `mongodb/Dockerfile`, `mongodb/mongo-keyfile`, `mongodb/init-replica.sh` | Archivos nuevos que creé para tener una imagen de Mongo que se auto-inicializa como replica set al arrancar. |
| `haproxy/galera.cfg` | Archivo nuevo: configuración del proxy TCP que puse delante de los tres nodos de Galera. |
| `application/index.js`, `application/init-db.js` | Actualicé la lógica de conexión para que hable con el replica set de Mongo y con Redis a través de Sentinel, en vez de apuntar a hosts fijos. |
| `nagios/architecture.cfg` | Actualicé los checks de monitoreo para que apunten a los nombres de los servicios nuevos. |
