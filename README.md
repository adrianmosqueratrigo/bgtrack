# BGTrack

BGTrack es una aplicación para la gestión y registro de partidas de juegos de mesa. Ésta permite registrar juegos, jugadores, partidas y sus puntuaciones y ganadores, además de consultar un histórico y estadísticas básicas.

---

## Tecnologías utilizadas

- Flutter
- Dart
- MySQL
- Docker
- phpMyAdmin
- Android Studio Emulator
- Git / GitHub

---

## Estado del proyecto

El proyecto está actualmente en desarrollo.

Funcionalidades previstas:

- Login de usuarios.
- Menú principal / dashboard.
- Gestión de juegos.
- Gestión de jugadores.
- Registro de nuevas partidas.
- Consulta de partidas jugadas.
- Estadísticas básicas.
- Gestión de usuarios para administradores.

---

## Requisitos previos

Antes de ejecutar el proyecto, es necesario tener instalado:

- Flutter SDK
- Android Studio
- Un emulador Android configurado (Pixel 7)
- Docker Desktop
- Git
- IDE (por ej. Visual Studio Code)

Para comprobar que Flutter está correctamente instalado:

    flutter doctor

---

## Estructura general del proyecto

En desarrollo.

---

## Base de datos con Docker

El proyecto utiliza MySQL mediante Docker.

Servicios definidos:

| Servicio | Puerto local | Puerto contenedor |
|---|---:|---:|
| MySQL | 3306 | 3306 |
| phpMyAdmin | 8081 | 80 |

Credenciales de MySQL para desarrollo:

    Base de datos: bgtrack
    Usuario root: root
    Contraseña root: root

    Usuario app: bgtrack
    Contraseña app: bgtrack

---

## Levantar la base de datos

Desde la raíz del proyecto, ejecutar:

    docker compose up -d

Comprobar que los contenedores están activos:

    docker ps

Acceder a phpMyAdmin:

    http://localhost:8081

Credenciales recomendadas para entrar:

    Usuario: root
    Contraseña: root

También se puede usar:

    Usuario: bgtrack
    Contraseña: bgtrack

---

## Inicialización de la base de datos

Los scripts SQL se encuentran en:

    docker/mysql/init/

Importante: los scripts de inicialización solo se ejecutan automáticamente la primera vez que se crea el volumen.

Si se necesita reiniciar la base de datos desde cero:

    docker compose down -v
    docker compose up -d

> Atención: `docker compose down -v` elimina el volumen de datos de MySQL.

---

## Ejecutar la aplicación Flutter

Primero, arrancar el emulador desde Android Studio:

    Android Studio → Device Manager → Start emulator

Después, desde la raíz del proyecto:

    flutter pub get
    flutter devices
    flutter run

También se puede ejecutar desde Visual Studio Code:

1. Abrir el proyecto en VS Code.
2. Seleccionar el emulador Android.
3. Abrir `lib/main.dart`.
4. Pulsar `F5`.

---

## Comandos útiles

Comprobar instalación de Flutter:

    flutter doctor

Ver dispositivos disponibles:

    flutter devices

Ejecutar la app:

    flutter run

Levantar Docker:

    docker compose up -d

Parar Docker:

    docker compose down

Reiniciar la base de datos desde cero:

    docker compose down -v
    docker compose up -d

Entrar al contenedor de MySQL:

    docker exec -it bgtrack_mysql mysql -u root -p

---

## Notas de desarrollo

La aplicación está pensada para ejecutarse en un emulador Android durante el desarrollo. La base de datos se ejecuta localmente mediante Docker.

En una arquitectura final, la aplicación Flutter debería comunicarse con la base de datos mediante una API/backend, no directamente contra MySQL.

---

## Autor

Proyecto desarrollado por Adrián M.
