# Mejoras de Alta Disponibilidad — MongoDB, Redis, GaleraDB

Este documento registra los cambios hechos sobre el stack original para cerrar los puntos
2.1, 2.2, 2.3 y 3 de `ToDo.md`.

## 1. MongoDB  

**Antes**: un solo contenedor `mongodb`, sin redundancia.
**Ahora**: `mongo1`, `mongo2`, `mongo3` forman un replica set (`rs0`) con autenticación
interna vía keyfile (`mongodb/mongo-keyfile`, horneado en una imagen propia en `mongodb/Dockerfile`
para evitar problemas de permisos en bind mounts de Windows).

- `mongo1` corre un script propio (`mongodb/init-replica.sh`, definido como `ENTRYPOINT` en
  `mongodb/Dockerfile`) que arranca `mongod` y, **solo en `mongo1`** (`INIT_REPLICA_SET=true`),
  hace `rs.initiate()` y crea el usuario root aprovechando la "localhost exception" de Mongo.
  Esto corre *dentro* del propio contenedor `mongo1` (conexión real por loopback), a diferencia
  de un contenedor aparte, donde esa excepción no aplica. `mongo2`/`mongo3` solo arrancan
  `mongod` y esperan a que `mongo1` los una al replica set.
- La app (`application/index.js`, `application/init-db.js`) ahora se conecta con
  `MONGO_HOSTS=mongo1:27017,mongo2:27017,mongo3:27017` y `?replicaSet=rs0`. El driver detecta
  solo quién es el `PRIMARY` y reconecta automáticamente si cambia.

**Cómo probarlo**:
```bash
docker exec -it distributed-three-tier-mongo1-1 mongosh -u <user> -p <pass> --authenticationDatabase admin --eval "rs.status()"
docker compose stop mongo1   

```

## 2. Redis 

**Decisión (2.3)**: Redis solo cachea `/products/cheapest` por 60s — es un caché desechable,
no una fuente de verdad. Por eso se configuró **sin persistencia** (`--appendonly no --save ""`)
en vez de replicar ese estado.

**Alta disponibilidad (2.2)**: `redis-master` + `redis-replica1/2` + 3 `redis-sentinel*`.
Si el master cae, Sentinel (con quórum de 2 de 3) promueve una réplica automáticamente.

- La app ya no apunta a un host fijo; usa `createSentinel()` del cliente `redis` (v5) con
  `REDIS_SENTINEL_HOSTS` y `REDIS_SENTINEL_NAME=mymaster`, que sigue al master vigente.

**para probarlo**:
```bash
docker compose stop redis-master
docker logs distributed-three-tier-redis-sentinel1-1   
curl http://localhost/api/products/cheapest             
```

## 3. GaleraDB

**Problema original**: `DB_HOST=galera1` — si `galera1` caía, la app dejaba de funcionar aunque
`galera2`/`galera3` siguieran vivos con quórum 

**Solución**: nuevo servicio `galera-proxy` (HAProxy, `haproxy/galera.cfg`) frente a los 3 nodos.
La app ahora usa `DB_HOST=galera-proxy` y nunca habla con un nodo directamente.

- **Routing**: Galera es multi-master; `galera-proxy` balancea con `leastconn` entre los 3 nodos
  sanos. No se separa lectura/escritura — las 3 instancias aceptan ambas.
- **Límite de connection pool** (revisado): cada app node usa `connectionLimit: 10`
  (`application/index.js`). Con 3 réplicas de app son 30 conexiones concurrentes máximo,
  muy por debajo de los límites por defecto de MariaDB — no requirió cambio.
- **Limitación conocida**: el healthcheck de `galera-proxy` es un TCP connect simple, no valida
  `wsrep_cluster_status=Primary`. Un nodo "up" pero expulsado del cluster (split-brain) pasaría
  el check igual. Documentado como gap conocido, igual que ya señalaba el `TEST-PLAN.md`.

**Cómo probarlo**:
```bash
docker compose stop galera1
curl http://localhost/api/products/cheapest  
```

## Archivos modificados/Cambiados


| `docker-compose.yml` | mongo1/2/3 (self-init), redis-master/replica/sentinel×3, galera-proxy |
| `mongodb/Dockerfile`, `mongodb/mongo-keyfile`, `mongodb/init-replica.sh` | nuevos — imagen Mongo que arranca y se auto-inicializa |
| `haproxy/galera.cfg` | nuevo — proxy TCP frente a Galera |
| `application/index.js`, `application/init-db.js` | conexión a replica set Mongo + Sentinel Redis |
| `nagios/architecture.cfg` | checks actualizados a los nuevos nombres de servicio |


