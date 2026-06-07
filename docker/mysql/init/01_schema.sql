CREATE DATABASE IF NOT EXISTS bgtrack
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE bgtrack;

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rol ENUM('admin', 'usuario') NOT NULL DEFAULT 'usuario',
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_login DATETIME NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE juegos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NULL,
    duracion_estimada_minutos INT NULL,
    jugadores_min INT NOT NULL,
    jugadores_max INT NOT NULL,
    fecha_alta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT chk_juegos_duracion
        CHECK (duracion_estimada_minutos IS NULL OR duracion_estimada_minutos > 0),

    CONSTRAINT chk_juegos_jugadores
        CHECK (jugadores_min > 0 AND jugadores_max >= jugadores_min)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE jugadores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NULL,
    residencia VARCHAR(100) NULL,
    fecha_alta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE partidas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_juego INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    duracion_minutos INT NULL,
    estado ENUM('finalizada', 'cancelada') NOT NULL DEFAULT 'finalizada',
    notas TEXT NULL,

    CONSTRAINT fk_partidas_juegos
        FOREIGN KEY (id_juego)
        REFERENCES juegos(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_partidas_usuarios
        FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_partidas_duracion
        CHECK (duracion_minutos IS NULL OR duracion_minutos >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE participaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_partida INT NOT NULL,
    id_jugador INT NOT NULL,
    puntuacion INT NULL,
    es_ganador BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_participaciones_partidas
        FOREIGN KEY (id_partida)
        REFERENCES partidas(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_participaciones_jugadores
        FOREIGN KEY (id_jugador)
        REFERENCES jugadores(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_partida_jugador
        UNIQUE (id_partida, id_jugador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO usuarios 
(rol, nombre, apellidos, username, email, password_hash, activo)
VALUES
('admin', 'Administrador', 'Todopoderoso', 'admin', 'admin@aulanosa.es', '1234abc.', TRUE;