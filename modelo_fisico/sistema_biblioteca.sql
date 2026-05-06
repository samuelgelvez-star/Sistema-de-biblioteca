----------------------------------creacion de tablas ----------------------------------------------


-- 1. Crear la tabla de Categorías primero (entidad independiente)
CREATE TABLE categorias (
    id_categoria VARCHAR(50) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- 2. Crear la tabla de Usuarios (entidad independiente)
CREATE TABLE usuarios (
    id_usuario VARCHAR(50) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    fecha_registro DATE DEFAULT CURRENT_DATE,
    email VARCHAR(150) UNIQUE NOT NULL -- Restricción de unicidad
);

-- 3. Crear la tabla de Libro
CREATE TABLE libro (
    id_libro VARCHAR(50) PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    ano INT,
    isbn VARCHAR(20) UNIQUE NOT NULL, -- Restricción de unicidad
    genero VARCHAR(100)
);

-- 4. Crear tabla intermedia para la relación N:M entre Libros y Categorías
CREATE TABLE es_clasificado (
    id_libro VARCHAR(50),
    id_categoria VARCHAR(50),
    PRIMARY KEY (id_libro, id_categoria),
    FOREIGN KEY (id_libro) REFERENCES libro(id_libro) ON DELETE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria) ON DELETE CASCADE
);

-- 5. Crear la tabla de Copias (Ejemplares)
CREATE TABLE copias (
    id_copias VARCHAR(50) PRIMARY KEY,
    estado VARCHAR(50) NOT NULL, -- Ejemplo: 'Disponible', 'Prestado', 'Mantenimiento'
    id_libro VARCHAR(50),
    FOREIGN KEY (id_libro) REFERENCES libro(id_libro) ON DELETE CASCADE
);

-- 6. Crear la tabla de Préstamos
CREATE TABLE prestamos (
    id_prestamos VARCHAR(50) PRIMARY KEY,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion DATE,
    id_usuario VARCHAR(50),
    id_copias VARCHAR(50),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_copias) REFERENCES copias(id_copias)
);

-- 7. Crear la tabla de Reseñas
CREATE TABLE resenas (
    id_resena VARCHAR(50) PRIMARY KEY,
    calificacion INT CHECK (calificacion >= 1 AND calificacion <= 5), -- Validación de rango
    comentario TEXT,
    fecha_resena DATE DEFAULT CURRENT_DATE,
    id_libro VARCHAR(50),
    id_usuario VARCHAR(50),
    FOREIGN KEY (id_libro) REFERENCES libro(id_libro),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);




-------------------------------------------insercion de datos de ejemplo ---------------------------------------

-- Insertar Categorías
INSERT INTO categorias (id_categoria, nombre) VALUES 
('CAT01', 'Ciencia Ficción'),
('CAT02', 'Realismo Mágico'),
('CAT03', 'Tecnología');

-- Insertar Usuarios
INSERT INTO usuarios (id_usuario, nombre, telefono, fecha_registro, email) VALUES 
('USR01', 'Leonardo', '5551234', '2026-01-15', 'leonardo@email.com'),
('USR02', 'Ana García', '5555678', '2026-02-10', 'ana.garcia@email.com'),
('USR03', 'Carlos Ruiz', '5559012', '2026-03-05', 'cruiz@email.com');

-- Insertar Libros
INSERT INTO libro (id_libro, titulo, ano, isbn, genero) VALUES 
('LIB01', 'Cien años de soledad', 1967, '978-0307474728', 'Novela'),
('LIB02', 'Fundación', 1951, '978-0553293357', 'Ciencia Ficción'),
('LIB03', 'Clean Code', 2008, '978-0132350884', 'Educativo');

-- Clasificar Libros (Relación N:M)
INSERT INTO es_clasificado (id_libro, id_categoria) VALUES 
('LIB01', 'CAT02'),
('LIB02', 'CAT01'),
('LIB03', 'CAT03');

-- Insertar Copias (Ejemplares)
INSERT INTO copias (id_copias, estado, id_libro) VALUES 
('COP01-01', 'Prestado', 'LIB01'),
('COP01-02', 'Disponible', 'LIB01'),
('COP02-01', 'Disponible', 'LIB02'),
('COP03-01', 'Prestado', 'LIB03');

-- Insertar Préstamos
INSERT INTO prestamos (id_prestamos, fecha_prestamo, fecha_devolucion, id_usuario, id_copias) VALUES 
('PRE01', '2026-04-01', '2026-04-15', 'USR01', 'COP01-01'),
('PRE02', '2026-05-01', NULL, 'USR02', 'COP03-01');

-- Insertar Reseñas
INSERT INTO resenas (id_resena, calificacion, comentario, fecha_resena, id_libro, id_usuario) VALUES 
('RES01', 5, 'Una obra maestra absoluta.', '2026-04-20', 'LIB01', 'USR01'),
('RES02', 4, 'Muy útil para mejorar mi código.', '2026-05-05', 'LIB03', 'USR02');




--------------------------- consultas ------------------------------------


SELECT u.nombre AS usuario, l.titulo AS libro, p.fecha_prestamo
FROM prestamos p
JOIN usuarios u ON p.id_usuario = u.id_usuario
JOIN copias c ON p.id_copias = c.id_copias
JOIN libro l ON c.id_libro = l.id_libro
WHERE p.fecha_devolucion IS NULL;



SELECT l.titulo, COUNT(c.id_copias) AS copias_disponibles
FROM libro l
JOIN copias c ON l.id_libro = c.id_libro
WHERE c.estado = 'Disponible'
GROUP BY l.titulo;


SELECT l.titulo, r.calificacion, r.comentario, u.nombre AS autor_resena
FROM resenas r
JOIN libro l ON r.id_libro = l.id_libro
JOIN usuarios u ON r.id_usuario = u.id_usuario
ORDER BY r.calificacion DESC;