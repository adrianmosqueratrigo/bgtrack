# BGTrack

Aplicación de escritorio/móvil desarrollada con **Flutter** para registrar y consultar partidas de juegos de mesa.

El proyecto permite gestionar una ludoteca, jugadores, partidas, estadísticas y usuarios, manteniendo un flujo completo desde la creación de una partida hasta su finalización y almacenamiento en base de datos.

---

## Tecnologías utilizadas

- Flutter
- Dart
- MySQL
- Docker
- phpMyAdmin
- SharedPreferences
- Visual Studio Code
- Android Studio / Emulador Android

---

## Requisitos previos

Antes de arrancar el proyecto, asegúrate de tener instalado:

- Flutter SDK
- Dart SDK
- Git
- Docker Desktop
- Visual Studio Code
- Android Studio
- Un emulador Android configurado

> Nota: durante el desarrollo, se utilizó el emulador Pixel 7.

---

## Arrancar el proyecto en local

### 1. Clonar el repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
```

Entrar en la carpeta del proyecto:

```bash
cd bgtrack
```

---

### 2. Instalar dependencias de Flutter

Desde la raíz del proyecto, ejecutar:

```bash
flutter pub get
```

---

### 3. Levantar los contenedores Docker

El proyecto utiliza Docker para levantar la base de datos MySQL y phpMyAdmin.

```bash
docker compose up -d
```

Este comando arranca los contenedores en segundo plano.

Los scripts SQL se ejecutan automáticamente cuando se crea el contenedor de la base de datos.

```txt
bgtrack\docker\mysql\init
```

Esta es la ruta donde se ubican los scripts SQL.

---

### 4. Seleccionar el emulador desde el VS Code

Desde el IDE, selecciona el emulador para que esté activo y disponible cuando se arranque la aplicación.


---

### 5. Arrancar la aplicación Flutter

Desde VS Code, Android Studio o una terminal en la raíz del proyecto:

```bash
flutter run
```

---

## URLs del proyecto

Una vez arrancado Docker, estarán disponibles las siguientes URLs:

| Servicio | URL |
|---|---|
| MySQL | http://localhost:3306 |
| phpMyAdmin | http://localhost:8081 |

---

## Base de datos

La base de datos se levanta mediante Docker Compose.

El proyecto utiliza MySQL y contiene las tablas principales necesarias para gestionar usuarios, juegos, jugadores, partidas y participaciones.

Tablas principales:

- usuarios
- juegos
- jugadores
- partidas
- participaciones

---

## Acceso a phpMyAdmin

phpMyAdmin se levanta mediante Docker Compose y está disponible en:

```txt
http://localhost:8081
```

Credenciales para el entorno local de desarrollo:

| Campo | Valor |
|---|---|
| Servidor | mysql |
| Usuario | bgtrack |
| Contraseña | bgtrack |

---

## Usuarios de prueba

El proyecto incluye usuarios de prueba para iniciar sesión en la aplicación.

| Usuario | Contraseña | Rol |
|---|---|---|
| admin | 1234abc. | admin |

---

## Funcionalidades principales

### Login y sesión

- Inicio de sesión de usuarios.
- Mantenimiento de sesión iniciada.
- Cierre de sesión.
- Diferenciación entre usuario normal y administrador.

### Mi cuenta

- Visualización de los datos del usuario logueado.
- Edición de datos personales.
- Acceso a gestión de usuarios para administradores.
- Cierre de sesión.

### Gestión de usuarios

- Listado de usuarios.
- Creación de usuarios.
- Edición de usuarios.
- Activación o desactivación de usuarios.
- Asignación de rol de usuario o administrador.

### Gestión de juegos

- Listado de juegos.
- Creación de juegos.
- Edición de juegos.
- Activación o desactivación de juegos.
- Definición de número mínimo y máximo de jugadores.
- Definición de duración aproximada.

### Gestión de jugadores

- Listado de jugadores.
- Creación de jugadores.
- Edición de jugadores.
- Activación o desactivación de jugadores.
- Registro de fecha de nacimiento y residencia.

### Nueva partida

- Selección de juego.
- Selección del número de jugadores.
- Selección de participantes.
- Control de reloj de partida.
- Confirmación de datos de partida.
- Finalización de partida.

### Finalizar partida

- Resumen de la partida.
- Selección del estado de la partida.
- Registro de puntuaciones.
- Marcado de ganador o ganadores.
- Registro de observaciones.
- Guardado de partida y participaciones.

### Histórico de partidas

- Listado de partidas registradas.
- Consulta de detalle de cada partida.
- Edición básica de partidas.
- Visualización de participantes, puntuaciones y ganadores.

### Estadísticas

- Estadísticas generales.
- Estadísticas por jugador.
- Estadísticas por juego.
- Cálculo de partidas jugadas, victorias, ratios y duración media.

---

## Estructura general del proyecto

```txt
bgtrack/
├── assets/
│   └── images/
├── docker
│   └── mysql/
│       └── init/
├── lib/
│   ├── database/
│   ├── models/
│   ├── pages/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   ├── widgets/
│   └── main.dart
├── compose.yml
├── pubspec.yaml
└── README.md
```

---

## Comandos útiles

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar la aplicación:

```bash
flutter run
```

Arrancar Docker:

```bash
docker compose up -d
```

Parar Docker sin borrar datos:

```bash
docker compose down
```

Parar Docker borrando también la base de datos:

```bash
docker compose down -v
```

---

## Notas para desarrollo

- La aplicación está desarrollada con Flutter.
- La base de datos utilizada es MySQL.
- La conexión con la base de datos se configura en:

```txt
lib/database/connection.dart
```

- El tema visual general de la aplicación se configura en:

```txt
lib/theme/app_theme.dart
```

- Los widgets reutilizables se encuentran en:

```txt
lib/widgets/
```

- Los métodos comunes, como los mensajes `Snackbar`, se encuentran en:

```txt
lib/utils/
```

- Los scripts SQL iniciales se encuentran en:

```txt
01_schema.sql
02_data_test.sql
```

---

## Estado del proyecto

Proyecto finalizado.
