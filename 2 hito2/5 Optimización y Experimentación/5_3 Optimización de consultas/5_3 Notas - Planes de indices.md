# 5.3 Optimización de consultas (planes de índices)

## Objetivo
Documentar los índices creados y los planes de ejecución (con/sin índices) para cada consulta.

---

## 1. Índices creados (`5_3_0 indices.sql`)

| Índice | Tabla | Columnas | Consulta |
|---|---|---|---|
| `idx_modelo_llm_arq_numparam` | modelo_llm | (arquitectura, num_param DESC) | Q1 |
| `idx_dataset_dominio` | dataset | (dominio) | Q2 |
| `idx_exp_dataset_dataset` | experimento_dataset | (id_dataset) | Q2 |
| `idx_experimento_modelo_loss` | experimento | (id_modelo, loss_final) WHERE estado='Finalizado' | Q3 |
| `idx_consumo_gpu_run` | consumo_gpu | (id_run) | Q4 |
| `idx_consumo_gpu_gpu` | consumo_gpu | (id_gpu) | Q4 |
| `idx_experimento_modelo` | experimento | (id_modelo) | Q4 |
| `idx_evaluacion_benchmark_score` | evaluacion | (id_benchmark, resultado_metrica DESC) | Q5 |
| `idx_evaluacion_modelo` | evaluacion | (id_modelo) | Q5 |
| `idx_modelo_llm_org` | modelo_llm | (id_organizacion) | FK |
| `idx_dataset_id` | dataset | (id_dataset) | FK |
| `idx_experimento_id_modelo` | experimento | (id_modelo) | FK |

---

## 2. Planes por consulta (EXPLAIN sin ANALYZE)

### Q1 — Modelo con mayor número de parámetros por arquitectura
- **Sin índices:** Seq Scan + Sort + WindowAgg.
- **Con índices:** Seq Scan + Sort + WindowAgg (índice no usado en 10k).
- **En 100k/1M:** Index Scan + Sort (el índice ayuda).
- **Índice:** `idx_modelo_llm_arq_numparam (arquitectura, num_param DESC)`.

### Q2 — Datasets más utilizados por dominio (top 5)
- **Sin índices:** Seq Scan + Hash Join + HashAggregate + Sort.
- **Con índices:** mismo plan (Seq Scan + Hash Join).
- **Índices:** `idx_dataset_dominio`, `idx_exp_dataset_dataset`.
- **Observación:** El planner sigue usando Seq Scan porque la agregación cubre toda la tabla.

### Q3 — Experimentos con menor loss final por modelo (top 3)
- **Sin índices:** Seq Scan + Hash Join + WindowAgg.
- **Con índices:** mismo plan (Seq Scan + Hash Join).
- **Índice:** `idx_experimento_modelo_loss (id_modelo, loss_final) WHERE estado='Finalizado'`.
- **Observación:** El índice parcial existe pero no se usa (baja selectividad).

### Q4 — Consumo total de horas GPU y costo por experimento
- **Sin índices:** Seq Scan + Hash Join + HashAggregate + Sort.
- **Con índices:** mismo plan (Seq Scan + Hash Join).
- **Índices:** `idx_consumo_gpu_run`, `idx_consumo_gpu_gpu`, `idx_experimento_modelo`.
- **Observación:** La agregación cubre toda la tabla → Seq Scan más eficiente.

### Q5 — Mejor resultado por benchmark y modelo (top 3)
- **Sin índices:** Seq Scan + Hash Join + WindowAgg.
- **Con índices:** mismo plan (Seq Scan + Hash Join).
- **Índice:** `idx_evaluacion_benchmark_score (id_benchmark, resultado_metrica DESC)`.
- **Observación:** El planner sigue usando Seq Scan porque la agregación cubre toda la tabla.

---

## 3. Archivos de planes
- `explain_with_indexes.txt`: planes con índices (10k).
- `explain_no_indexes.txt`: planes sin índices (10k).

## Nota para el informe (LaTeX)
Incluir los planes (EXPLAIN) con y sin índices para cada consulta, explicando por qué el planner elige Seq Scan en volúmenes pequeños y por qué los índices solo ayudan en Q1 (que filtra/particiona por arquitectura). Para Q2–Q5, los índices no son efectivos porque son consultas de agregación sobre toda la tabla. Incluir las tablas de tiempos (5.6).