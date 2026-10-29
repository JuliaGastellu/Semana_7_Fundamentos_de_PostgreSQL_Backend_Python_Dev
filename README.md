# Pulse — Base de datos del blog — Entrega de la semana 7

En esta entrega diseñé la base relacional de Pulse en PostgreSQL. Separé el trabajo en cuatro scripts para poder crear el esquema, cargar datos, ejecutar consultas y analizar índices de manera ordenada y repetible.

## Archivos

- `01-schema.sql`: crea usuarios, categorías, tags, posts, la relación `post_tags` y comentarios, con claves, restricciones y reglas de borrado.
- `02-seed.sql`: carga 12 usuarios, 6 categorías, 12 tags, 32 posts, 61 relaciones y 58 comentarios, incluyendo casos sin categoría y posts sin comentarios.
- `03-queries.sql`: contiene las diez consultas obligatorias identificadas como Q01, Q11, Q04, Q15, Q18, Q17, Q19, Q24, Q25 y Q26.
- `04-indexes.sql`: crea índices para claves foráneas y búsquedas frecuentes, genera volumen de prueba y compara planes con `EXPLAIN (ANALYZE, BUFFERS)`.

## Cómo lo pruebo

```bash
createdb pulse
psql -d pulse -f 01-schema.sql
psql -d pulse -f 02-seed.sql
psql -d pulse -f 03-queries.sql
psql -d pulse -f 04-indexes.sql
```

Tomé decisiones explícitas para conservar contenido cuando se elimina una categoría (`SET NULL`) y borrar dependencias cuando se elimina un usuario o un post (`CASCADE`). El script de índices elimina al final los datos masivos que utiliza para las mediciones.
