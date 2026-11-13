# Anexo — Guía de grabación del video (experimentación con 1M)

## Objetivo
Grabar la experimentación con 1.000.000 de registros con y sin índices, como exige la rúbrica (anexo). Duración estimada: **8–12 minutos**.

---

## Preparación (antes de grabar)
1. Abrir terminal con fuente legible (14pt+).
2. Conectar a `proyectobd_1m`:
   ```bash
   psql -U postgres -d proyectobd_1m
   ```
3. Tener a mano la tabla de resultados (`5_6 Tablas por consulta.md`).
4. Abrir OBS Studio (o herramienta de grabación) y configurar captura de pantalla.

---

## Guion detallado

### Parte 0 — Introducción (0:00–0:30)
**Qué mostrar:** Terminal con `psql` conectado a `proyectobd_1m`.
**Narración sugerida:**
> "En este video se muestra la experimentación de la Sección 5 con 1 millón de registros en la base de datos `proyectobd_1m`. Se comparará el rendimiento de 5 consultas con y sin índices."

---

### Parte 1 — Sin índices (0:30–4:00)
**Comandos:**
```sql
\i "5_3 Optimización de consultas/5_3_0 drop_indexes.sql"
```
**Narración:**
> "Primero eliminamos todos los índices creados (solo quedan las claves primarias)."

**Ejecutar cada consulta:**
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```
**Qué mostrar:** El plan (Seq Scan) y el tiempo de ejecución.
**Narración sugerida (por consulta):**
> "La consulta Q1 usa Seq Scan + Sort. Tiempo: 230ms. En volúmenes grandes, el ordenamiento completo de la tabla es costoso."

**Tiempos esperados (sin índices):**
| Consulta | Tiempo (ms) |
|---|---|
| Q1 | 230.178 |
| Q2 | 142.170 |
| Q3 | 169.974 |
| Q4 | 541.884 |
| Q5 | 150.546 |

---

### Parte 2 — Con índices (4:00–8:00)
**Comandos:**
```sql
\i "5_3 Optimización de consultas/5_3_0 indices.sql"
```
**Narración:**
> "Ahora creamos los índices propuestos en la sección 5.3."

**Ejecutar las mismas 5 consultas:**
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```
**Qué mostrar:** El plan (Index Scan donde aplique) y el tiempo.
**Narración sugerida (por consulta):**
> "Q1 ahora usa Index Scan + Sort. Tiempo: 76ms. Mejora ~3x. Las demás consultas siguen usando Seq Scan porque son agregaciones sobre toda la tabla."

**Tiempos esperados (con índices):**
| Consulta | Tiempo (ms) |
|---|---|
| Q1 | 76.805 |
| Q2 | 210.319 |
| Q3 | 203.092 |
| Q4 | 556.302 |
| Q5 | 171.121 |

---

### Parte 3 — Comparación (8:00–10:00)
**Qué mostrar:** Tabla de tiempos (sin/con) y speedup.

| Consulta | Sin índices (ms) | Con índices (ms) | Speedup |
|---|---|---|---|
| Q1 | 230.178 | 76.805 | 3.00x |
| Q2 | 142.170 | 210.319 | 0.68x |
| Q3 | 169.974 | 203.092 | 0.84x |
| Q4 | 541.884 | 556.302 | 0.97x |
| Q5 | 150.546 | 171.121 | 0.88x |

**Narración sugerida:**
> "Solo Q1 se beneficia de los índices (mejora ~3x). Q2–Q5 son más lentas con índices porque son agregaciones sobre toda la tabla, donde el planner prefiere Seq Scan. Los índices no son una solución universal."

---

### Parte 4 — Cierre (10:00–10:30)
**Narración sugerida:**
> "En conclusión, los índices mejoran el rendimiento cuando la consulta filtra o particiona por una columna indexada (Q1). Para agregaciones sobre toda la tabla, los índices no ayudan e incluso empeoran el rendimiento. Esto se documenta en la sección 5.7 del informe."

---

## Checklist antes de grabar
- [ ] Terminal con fuente legible (14pt+).
- [ ] Conexión a `proyectobd_1m` verificada.
- [ ] OBS Studio configurado (captura de pantalla).
- [ ] Tabla de resultados a mano.
- [ ] Comandos copiados en un archivo de texto para copiar/pegar.

## Nota para el informe (LaTeX)
Incluir el video como anexo (archivo o enlace) y mencionarlo en la sección 7. Referenciar la guía y los resultados de la Sección 5.