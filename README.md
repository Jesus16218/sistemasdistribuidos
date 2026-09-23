# 📓 Apuntes Semanales

**Materia:** sistemas distribuidos

---

## Semana 1 (17 de agosto / 19 de agosto)

* **Tema:** Presentación del curso, criterios de evaluación y trayectoria profesional del profesor.
* **Lo que vimos:**
  *.
  * **Criterios de evaluación:** El profesor explicó detalladamente cómo se evaluará el curso, incluyendo:
    * Porcentaje de participación en clase.
    * Entrega de tareas y trabajos prácticos.
    * Proyectos individuales o en equipo.
    * Exámenes parciales y final.
    * Asistencia y puntualidad.
  * **Trayectoria del profesor:** Compartió su experiencia profesional como empleado en distintas empresas del sector tecnológico, mencionando:
    * Los roles que ha desempeñado (soporte técnico, administración de redes, desarrollo, etc.).
    * Cómo aplicó los conocimientos de redes y sistemas en cada trabajo.
    * Anécdotas y consejos sobre el mundo laboral real, la importancia de la ética profesional y la actualización constante.
  * **Expectativas del curso:** Se estableció la dinámica de trabajo: cómo se entregarán las tareas, qué herramientas se usarán (Markdown, GitHub, etc.) y la importancia de la participación activa.
* **Notas / Ejemplos:**
  * La trayectoria del profesor sirvió para conectar la teoría con casos reales del mundo laboral.
  * Se recomendó llevar un registro ordenado de los apuntes semana a semana, ya que el curso es acumulativo.
  * Se mencionó que se usará Markdown para documentar los apuntes y trabajos.

---

## Semana 2 (24 de agosto / 26 de agosto)

* **Tema:** Modelos de capas OSI y TCP/IP, entornos monolíticos y protocolos de seguridad.
* **Lo que vimos:**
  * **Modelo OSI (Open Systems Interconnection):**
    * Es un modelo de referencia creado por la ISO que divide la comunicación en redes en **7 capas**: Física, Enlace de Datos, Red, Transporte, Sesión, Presentación y Aplicación.
    * Cada capa tiene una función específica y se comunica con la capa superior e inferior.
    * Sirve para entender cómo viajan los datos desde una aplicación hasta el medio físico y viceversa.
  * **Modelo TCP/IP:**
    * Es el modelo práctico que usa internet, compuesto por **4 capas**: Acceso a la Red, Internet, Transporte y Aplicación.
    * Se relaciona con el modelo OSI: por ejemplo, la capa de Aplicación de TCP/IP engloba las capas de Sesión, Presentación y Aplicación de OSI.
    * TCP/IP es el conjunto de protocolos que permite la comunicación entre dispositivos en internet.
  * **Entornos monolíticos vs. otras arquitecturas:**
    * Un **entorno monolítico** es una aplicación donde toda la lógica (interfaz, negocio, datos) está concentrada en un solo bloque.
    * Ventajas: fácil de desplegar al inicio, simple de desarrollar para equipos pequeños.
    * Desventajas: difícil de escalar, un fallo afecta todo el sistema, complicado de mantener cuando crece.
    * Se comparó con arquitecturas como microservicios, donde cada función es independiente.
  * **PDU (Protocol Data Unit):**
    * Es la unidad de datos que se maneja en cada capa del modelo OSI/TCP-IP.
    * Cambia de nombre según la capa:
      * Aplicación → Datos.
      * Transporte → Segmento (TCP) o Datagrama (UDP).
      * Red → Paquete.
      * Enlace de Datos → Trama.
      * Física → Bits.
  * **Protocolos de seguridad:**
    * **SSL/TLS:** Cifra la comunicación entre cliente y servidor (HTTPS).
    * **IPsec:** Protege la comunicación a nivel de red (VPNs).
    * **HTTPS:** Versión segura de HTTP que usa TLS.
    * Importancia: proteger datos sensibles, autenticar identidades y garantizar integridad.
* **Notas / Ejemplos:**
  * El modelo OSI tiene 7 capas; TCP/IP se resume en 4 capas prácticas.
  * La PDU cambia de nombre según la capa: datos, segmento, paquete, trama, bits.
  * Un entorno monolítico es más simple de desplegar al inicio, pero difícil de escalar.
  * SSL/TLS es lo que hace que aparezca el candado en el navegador.

---

## Semana 3 (31 de agosto / 2 de septiembre)

* **Tema:** Funcionamiento de servidores, transmisión de datos en tiempo real y cableado marino/subterráneo.
* **Lo que vimos:**
  * **Funcionamiento de los servidores:**
    * Un **servidor** es una computadora o programa que proporciona servicios, datos o recursos a otros dispositivos llamados **clientes**.
    * El cliente envía una **petición** (request) y el servidor responde con una **respuesta** (response).
    * Tipos de servidores: web, de correo, de archivos, de bases de datos, de aplicaciones, etc.
    * Componentes clave: CPU, RAM, almacenamiento, tarjeta de red, sistema operativo (Linux, Windows Server).
  * **Transmisión de datos en tiempo real:**
    * Los datos viajan por la red en paquetes y pueden sufrir **latencia** (retraso), **jitter** (variación en el retraso) o **pérdida de paquetes**.
    * **Ancho de banda:** cantidad de datos que se pueden transmitir por segundo (Mbps, Gbps).
    * **Tiempo de respuesta:** tiempo que tarda el servidor en contestar.
    * Aplicaciones en tiempo real: videollamadas, streaming, juegos en línea, IoT.
  * **Cableado marino y subterráneo:**
    * La mayor parte del tráfico de internet viaja por **cables submarinos** que cruzan océanos.
    * Estos cables están formados por fibras ópticas protegidas por capas de plástico, acero y aluminio.
    * También existen cables **subterráneos** que conectan ciudades y regiones dentro de los continentes.
    * Importancia: permiten la globalización de internet, aunque son vulnerables a daños naturales o accidentales.
* **Notas / Ejemplos:**
  * Los cables submarinos transportan más del 95% del tráfico de internet entre continentes.
  * La latencia depende de la distancia física y del número de nodos intermedios.
  * Un servidor web típico usa HTTP/HTTPS en el puerto 80/443.

---

## Semana 4 (7 de septiembre / 9 de septiembre)

* **Tema:** Arquitectura de servidores y modelo de responsabilidad compartida.
* **Lo que vimos:**
  * **Arquitectura de servidores:**
    * Mediante material visual (fotos, diagramas, videos) observamos cómo son físicamente los servidores:
      * **Racks:** gabinetes metálicos donde se montan los servidores.
      * **Blades:** servidores modulares que comparten energía y refrigeración.
      * **Almacenamiento:** discos duros, SSD, arreglos RAID.
      * **Redundancia:** fuentes de poder duplicadas, discos en espejo, conexiones de red redundantes.
    * Se explicó la importancia de la **alta disponibilidad** y la **tolerancia a fallos**.
  * **Modelo de responsabilidad compartida:**
    * Es un concepto usado en servicios en la nube (AWS, Azure, GCP) donde **tanto el proveedor como el cliente tienen responsabilidades divididas**.
    * **Responsabilidades del proveedor:**
      * Seguridad física de los data centers.
      * Infraestructura de red, servidores y almacenamiento.
      * Disponibilidad de los servicios.
    * **Responsabilidades del cliente:**
      * Administración de usuarios y accesos (IAM).
      * Configuración de seguridad (firewalls, cifrado).
      * Parcheo y actualización de sistemas operativos y aplicaciones.
      * Gestión de datos y copias de seguridad.
      * Rapidez y optimización de los datos.
* **Notas / Ejemplos:**
  * En la nube, el proveedor asegura la infraestructura física; el cliente asegura sus datos, accesos y configuraciones.
  * Una mala configuración del cliente no es responsabilidad del proveedor.
  * Ejemplo: si un bucket de S3 queda público por error, es responsabilidad del cliente.

---

## Semana 5 (14 de septiembre / 16 de septiembre)

* **Tema:** IA con Raspberry Pi, servicios AWS y subneteo CIDR (IPv4).
* **Lo que vimos:**
  * **Proyecto de IA con Raspberry Pi:**
    * El profesor presentó un programa de **inteligencia artificial** capaz de detectar movimientos, objetos y personas.
    * Componentes usados:
      * **Raspberry Pi:** computadora pequeña de bajo costo.
      * **Sensor:** para detectar movimiento o distancia.
      * **Cámara de video:** para capturar imágenes en tiempo real.
    * El sistema procesa las imágenes localmente (edge computing) y puede enviar alertas o datos a la nube.
    * Aplicaciones: seguridad, domótica, monitoreo, reconocimiento de objetos.
  * **Servicios AWS:**
    * **AWS (Amazon Web Services):** plataforma de servicios en la nube.
    * Servicios vistos:
      * **EC2:** servidores virtuales.
      * **S3:** almacenamiento de objetos.
      * **CloudWatch:** monitoreo y logs.
    * **Logs:** registros de eventos que permiten auditar y monitorear el comportamiento de los servicios.
    * **Comportamiento de la nube:** escalabilidad, elasticidad, pago por uso.
  * **Subneteo CIDR (IPv4):**
    * **CIDR (Classless Inter-Domain Routing):** notación para representar rangos de direcciones IP.
    * Se escribe como `192.168.1.0/24`, donde `/24` indica cuántos bits son de red.
    * Permite dividir una red en subredes más pequeñas.
    * Ejemplo: `/24` = 256 direcciones, `/16` = 65,536 direcciones.
    * Importancia: optimizar el uso de direcciones IP y organizar redes.
* **Notas / Ejemplos:**
  * CIDR permite representar rangos de IP con notación como /24, /16, etc.
  * La Raspberry Pi puede usarse como nodo edge para procesar datos localmente antes de enviarlos a la nube.
  * Los logs en AWS permiten auditar y monitorear el comportamiento de los servicios.
  * Ejemplo de subneteo: dividir 192.168.1.0/24 en dos subredes /25.

---

## Semana 6 (20 de septiembre/ 23 de septiembre 
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 7
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 8
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 9
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 10
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 11
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 12
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 13
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 14
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 15
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ] 

---

## Semana 16
* **Tema:** 
* **Lo que vimos:**
  * 
  * 
* **Notas / Ejemplos:**
  * 
* **Pendientes / Tareas:**
  * [ ]
