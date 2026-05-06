# 📚 ReadFlow — Sistema de Biblioteca Digital

Proyecto académico: diseño completo de base de datos para la plataforma **ReadFlow**, que gestiona libros, usuarios, préstamos y reseñas.

---

## 📋 Contenido del repositorio

```
├── schema.sql        # Script DDL (creación de tablas + datos de ejemplo)
├── queries.sql       # Tres consultas SQL requeridas
└── README.md         # Documentación del proceso completo
```

---

## 1. Modelo Conceptual — Diagrama E-R

El modelo conceptual identifica las **entidades**, sus **atributos** y las **relaciones** entre ellas.

### Entidades y atributos

| Entidad | Atributos |
|---|---|
| **USUARIO** | id_usuario (PK), nombre, email (único), teléfono, fecha_registro |
| **LIBRO** | id_libro (PK), título, isbn (único), año_publicación, género |
| **COPIA** | id_copia (PK), id_libro (FK), estado |
| **PRÉSTAMO** | id_prestamo (PK), id_usuario (FK), id_copia (FK), fecha_prestamo, fecha_devolucion |
| **RESEÑA** | id_resena (PK), id_usuario (FK), id_libro (FK), calificacion, comentario, fecha |
| **CATEGORÍA** | id_categoria (PK), nombre |

### Relaciones

| Relación | Cardinalidad |
|---|---|
| USUARIO — PRÉSTAMO | 1 : N (un usuario puede tener varios préstamos) |
| COPIA — PRÉSTAMO | 1 : N (una copia puede tener historial de préstamos) |
| LIBRO — COPIA | 1 : N (un libro tiene múltiples copias) |
| USUARIO — RESEÑA | 1 : N (un usuario puede escribir varias reseñas) |
| LIBRO — RESEÑA | 1 : N (un libro puede recibir varias reseñas) |
| LIBRO — CATEGORÍA | N : M (un libro pertenece a varias categorías) |

> Ver diagrama E-R generado con draw.io / drawSQL en la carpeta `/diagramas`.

---

## 2. Modelo Lógico

El modelo lógico transforma el E-R en tablas relacionales, definiendo **claves primarias**, **claves foráneas** y **restricciones**.

```
usuario(id_usuario PK, nombre, email UNIQUE, telefono, fecha_registro)

categoria(id_categoria PK, nombre UNIQUE)

libro(id_libro PK, titulo, isbn UNIQUE, anio_publicacion, genero)

libro_categoria(id_libro FK→libro, id_categoria FK→categoria)
  PK compuesta: (id_libro, id_categoria)

copia(id_copia PK, id_libro FK→libro, estado CHECK)

prestamo(id_prestamo PK, id_usuario FK→usuario, id_copia FK→copia,
         fecha_prestamo, fecha_devolucion)

resena(id_resena PK, id_usuario FK→usuario, id_libro FK→libro,
       calificacion CHECK(1-5), comentario, fecha)
```

---

## 3. Normalización hasta 3FN

### Primera Forma Normal (1FN)
- Todos los atributos son atómicos (un valor por campo).
- No hay grupos repetitivos: las categorías múltiples se resuelven con la tabla `libro_categoria`.
- Cada tabla tiene clave primaria definida.  
✅ **Cumple 1FN**

### Segunda Forma Normal (2FN)
- Todas las tablas están en 1FN.
- En `libro_categoria` (PK compuesta), no existe dependencia parcial: no hay atributos adicionales que dependan sólo de `id_libro` o sólo de `id_categoria`.
- En el resto de tablas la PK es simple, por lo que no aplica dependencia parcial.  
✅ **Cumple 2FN**

### Tercera Forma Normal (3FN)
- No existen dependencias transitivas:
  - En `libro`: `genero` depende directamente de `id_libro`, no de `isbn`.
  - En `prestamo`: `fecha_devolucion` depende del préstamo, no del usuario ni de la copia.
  - En `copia`: `estado` depende de la copia, no del libro.
- Todos los atributos no clave dependen **única y directamente** de la clave primaria.  
✅ **Cumple 3FN**

---

## 4. Modelo Físico

El modelo físico implementa el lógico en SQL con tipos de datos concretos, restricciones y índices.

### Decisiones de diseño

- `VARCHAR` con longitudes adecuadas por campo.
- Índices en columnas de alta consulta: `prestamo.id_usuario`, `prestamo.id_copia`, `resena.id_libro`, `copia.id_libro`.

## 5. Script SQL

Ver archivo **`schema.sql`** — incluye:
- `CREATE TABLE` para las 7 tablas
- Restricciones (`UNIQUE`, `CHECK`, `FOREIGN KEY`)
- Índices
- Datos de ejemplo (`INSERT INTO`)

Probado en [Programiz SQL Online Compiler](https://www.programiz.com/sql/online-compiler/) y compatible con PostgreSQL.

---

## 6. Consultas SQL

Ver archivo **`queries.sql`** — incluye 3 consultas:

### Consulta 1 — Préstamos activos
Lista todos los préstamos sin fecha de devolución, con nombre del usuario y título del libro.

```sql
SELECT u.nombre AS usuario, l.titulo AS libro, p.fecha_prestamo
FROM prestamos p
JOIN usuarios u ON p.id_usuario = u.id_usuario
JOIN copias c ON p.id_copias = c.id_copias
JOIN libro l ON c.id_libro = l.id_libro
WHERE p.fecha_devolucion IS NULL;
```

### Consulta 2 — Promedio de calificaciones por libro
Calcula el promedio y total de reseñas de cada libro.

```sql
SELECT l.titulo, COUNT(c.id_copias) AS copias_disponibles
FROM libro l
JOIN copias c ON l.id_libro = c.id_libro
WHERE c.estado = 'Disponible'
GROUP BY l.titulo;
```

### Consulta 3 — Disponibilidad de copias por libro
Muestra cuántas copias tiene cada libro y cuántas están disponibles.

```sql
SELECT l.titulo, r.calificacion, r.comentario, u.nombre AS autor_resena
FROM resenas r
JOIN libro l ON r.id_libro = l.id_libro
JOIN usuarios u ON r.id_usuario = u.id_usuario
ORDER BY r.calificacion DESC;
```

---

## 🛠 Herramientas utilizadas

- **draw.io** — Diagramas E-R y lógico
- **Programiz SQL Online Compiler** — Prueba de scripts
- **GitHub** — Control de versiones

---

## 👤 Autor

Proyecto desarrollado como actividad académica de diseño de bases de datos.