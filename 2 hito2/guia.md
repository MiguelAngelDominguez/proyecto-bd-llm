# Guía — Sección 5 (Optimización y Experimentación)

> **BD de trabajo:** `proyectobd_1m` (1.000.000 registros) para la demo; `proyectobd` (10.000) para desarrollo.  
> **Contraseña:** `admin` (o variable `PGPASSWORD`).  
> **Ejecutar desde:** carpeta `2 hito2/`.

---

## Parte 1 — Integrante 1: Consultas SQL para el experimento (5.1)

**Qué decir (guion):**
> "Las 5 consultas seleccionadas son intermedias (no triviales) porque usan window functions, CTEs, joins M:N y agregaciones. Se seleccionaron por ser críticas para el análisis del dominio: modelos, datasets, experimentos, consumo GPU y benchmarks. Se probaron en los 4 volúmenes (1k/10k/100k/1M) sin errores."

**Pasos:**
1. Conectar:
   ```bash
   psql -U postgres -d proyectobd_1m
   ```
2. Ejecutar las 5 consultas (copiar/pegar una por una):

   **Q1 — Modelo con mayor número de parámetros por arquitectura:**
   ```sql
   WITH ranked AS (
     SELECT nombre, arquitectura, num_param,
            RANK() OVER (PARTITION BY arquitectura ORDER BY num_param DESC) AS rnk
     FROM modelo_llm
   )
   SELECT arquitectura, nombre, num_param
   FROM ranked WHERE rnk = 1;
   ```

   **Q2 — Datasets más utilizados por dominio (top 5):**
   ```sql
   SELECT d.dominio, COUNT(ed.id_run) AS num_experimentos, AVG(d.num_registros) AS avg_registros
   FROM dataset d
   JOIN experimento_dataset ed ON ed.id_dataset = d.id_dataset
   GROUP BY d.dominio
   ORDER BY num_experimentos DESC
   LIMIT 5;
   ```

   **Q3 — Experimentos con menor loss final por modelo (top 3):**
   ```sql
   WITH ranked AS (
     SELECT e.id_run, m.nombre AS modelo, e.loss_final, e.num_epocas, e.tasa_aprendizaje,
            ROW_NUMBER() OVER (PARTITION BY e.id_modelo ORDER BY e.loss_final ASC NULLS LAST) AS rn
     FROM experimento e JOIN modelo_llm m ON m.id_modelo=e.id_modelo
     WHERE e.estado_ejecucion='Finalizado'
   )
   SELECT * FROM ranked WHERE rn <= 3;
   ```

   **Q4 — Consumo total de horas GPU y costo por experimento:**
   ```sql
   SELECT e.id_run, m.nombre AS modelo, SUM(cg.horas_uso) AS horas_totales,
          SUM(cg.horas_uso*g.costo_por_hora) AS costo_usd,
          SUM(cg.consumo_energetico) AS kwh
   FROM experimento e
   JOIN modelo_llm m ON m.id_modelo=e.id_modelo
   JOIN consumo_gpu cg ON cg.id_run=e.id_run
   JOIN gpu g ON g.id_gpu=cg.id_gpu
   GROUP BY e.id_run, m.nombre
   ORDER BY costo_usd DESC;
   ```

   **Q5 — Mejor resultado por benchmark y modelo (top 3):**
   ```sql
   WITH ranked AS (
     SELECT b.nombre AS benchmark, m.nombre AS modelo, e.resultado_metrica AS valor,
            e.fecha_evaluacion AS fecha,
            RANK() OVER (PARTITION BY b.id_benchmark ORDER BY e.resultado_metrica DESC) AS rnk
     FROM evaluacion e
     JOIN benchmark b ON b.id_benchmark=e.id_benchmark
     JOIN modelo_llm m ON m.id_modelo=e.id_modelo
   )
   SELECT benchmark, modelo, valor, fecha, rnk
   FROM ranked WHERE rnk <= 3;
   ```

3. Mostrar las primeras filas de cada resultado.

**Tiempo estimado:** 7–10 minutos.

---

## Parte 2 — Índices creados y justificación (5.3)

**Qué decir (guion):**
> "Los índices se crearon sobre las columnas que aparecen en WHERE, JOIN, ORDER BY y PARTITION BY. Cada índice tiene una justificación específica para una consulta. El índice parcial de Q3 reduce el tamaño al excluir experimentos no finalizados."

**Pasos:**
1. Conectar a `proyectobd_1m`.
2. Mostrar el script:
   ```sql
   \i "5 Optimización y Experimentación/5_3 Optimización de consultas/5_3_0 indices.sql"
   ```
3. Explicar cada índice:
   - `idx_modelo_llm_arq_numparam (arquitectura, num_param DESC)` → Q1.
   - `idx_dataset_dominio (dominio)` → Q2.
   - `idx_exp_dataset_dataset (id_dataset)` → Q2.
   - `idx_experimento_modelo_loss (id_modelo, loss_final) WHERE estado='Finalizado'` → Q3.
   - `idx_consumo_gpu_run (id_run)` → Q4.
   - `idx_consumo_gpu_gpu (id_gpu)` → Q4.
   - `idx_experimento_modelo (id_modelo)` → Q4.
   - `idx_evaluacion_benchmark_score (id_benchmark, resultado_metrica DESC)` → Q5.
   - `idx_evaluacion_modelo (id_modelo)` → Q5.
4. Justificar: columnas en WHERE/JOIN/ORDER BY/PARTITION BY; índice parcial para Q3.
5. Verificar:
   ```sql
   SELECT indexname, tablename FROM pg_indexes WHERE schemaname='public' ORDER BY tablename;
   ```

**Tiempo estimado:** 5–7 minutos.

---

## Parte 3 — Medición de tiempos (5.5)

**Sin índices:**
1. Eliminar índices:
   ```sql
   \i "5 Optimización y Experimentación/5_3 Optimización de consultas/5_3_0 drop_indexes.sql"
   ```
2. Ejecutar mediciones:
   ```sql
   \i "5 Optimización y Experimentación/5_5 Medición de tiempos/5_5_1 Sin índices/measure_no_indexes.sql"
   ```
3. Registrar tiempos (ej. Q1: 217ms, Q2: 108ms, etc.).

**Con índices:**
4. Crear índices:
   ```sql
   \i "5 Optimización y Experimentación/5_3 Optimización de consultas/5_3_0 indices.sql"
   ```
5. Ejecutar mediciones:
   ```sql
   \i "5 Optimización y Experimentación/5_5 Medición de tiempos/5_5_2 Con índices/measure_with_indexes.sql"
   ```
6. Registrar tiempos (ej. Q1: 99ms, Q2: 89ms, etc.).

**Repetir** para 1k, 10k, 100k (o mostrar los archivos ya generados).

---

## Parte 4 — Resultados (5.6)
- Mostrar la tabla consolidada de tiempos (sin/con) para los 4 volúmenes.
- Mostrar las tablas por consulta (`5_6_1` … `5_6_5`).
- Mostrar el gráfico (`chart_tiempos.png`).

---

## Parte 5 — Análisis (5.7)
- Explicar por qué Q1 mejora ~2-3x con índices.
- Explicar por qué Q2–Q5 no mejoran (agregaciones sobre toda la tabla → Seq Scan).
- Discutir escalabilidad y recomendaciones (índices parciales, materialized views).

---

## Verificación post-ejecución
```sql
SELECT viewname FROM pg_views WHERE schemaname='public';
SELECT routine_name FROM information_schema.routines WHERE routine_schema='public' AND routine_type='PROCEDURE';
SELECT COUNT(*) AS triggers FROM pg_trigger WHERE NOT tgisinternal;
```

---

## Notas
- **BD de trabajo:** `proyectobd_1m` para la demo; `proyectobd` (10k) para desarrollo.
- **Contraseña:** `admin` (o variable `PGPASSWORD`).
- **Rutas:** ejecutar desde la carpeta `2 hito2/` para que los `\i` resuelvan correctamente.