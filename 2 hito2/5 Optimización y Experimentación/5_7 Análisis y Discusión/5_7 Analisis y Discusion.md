# 5.7 Análisis y Discusión

## Comparación de planes (con vs. sin índices)

### Q1 — Modelo con mayor número de parámetros por arquitectura
- **Sin índices:** Seq Scan + Sort + WindowAgg.
- **Con índices:** Index Scan + Sort + WindowAgg (en 100k/1M).
- **Resultado:** Mejora ~3x en 1M (230ms → 76ms).
- **Motivo:** El índice `idx_modelo_llm_arq_numparam (arquitectura, num_param DESC)` permite ordenar por arquitectura y num_param sin escanear toda la tabla.

### Q2 — Datasets más utilizados por dominio (top 5)
- **Sin índices:** Seq Scan + Hash Join + HashAggregate + Sort.
- **Con índices:** Mismo plan (Seq Scan + Hash Join).
- **Resultado:** Empeora en 1M (142ms → 210ms).
- **Motivo:** La agregación cubre toda la tabla; el índice en `dominio` no reduce filas a leer.

### Q3 — Experimentos con menor loss final por modelo (top 3)
- **Sin índices:** Seq Scan + Hash Join + WindowAgg.
- **Con índices:** Mismo plan (Seq Scan + Hash Join).
- **Resultado:** Empeora en 100k/1M (11.8ms → 17.7ms, 170ms → 203ms).
- **Motivo:** El índice parcial `idx_experimento_modelo_loss` no se usa porque la selectividad es baja.

### Q4 — Consumo total de horas GPU y costo por experimento
- **Sin índices:** Seq Scan + Hash Join + HashAggregate + Sort.
- **Con índices:** Mismo plan (Seq Scan + Hash Join).
- **Resultado:** Empeora ligeramente en 100k/1M.
- **Motivo:** Agregación sobre toda la tabla → Seq Scan más eficiente.

### Q5 — Mejor resultado por benchmark y modelo (top 3)
- **Sin índices:** Seq Scan + Hash Join + WindowAgg.
- **Con índices:** Mismo plan (Seq Scan + Hash Join).
- **Resultado:** Empeora ligeramente en 1M (150ms → 171ms).
- **Motivo:** Agregación sobre toda la tabla → Seq Scan más eficiente.

---

## Bottlenecks identificados
1. **Agregaciones (GROUP BY):** Q2, Q4 agregan toda la tabla → Seq Scan inevitable.
2. **Window functions (RANK/ROW_NUMBER):** Q1, Q3, Q5 requieren ordenar/particionar → Sort costoso.
3. **Joins M:N:** Q4 une 4 tablas → Hash Join + Seq Scan.

---

## Por qué los índices no ayudan en Q2–Q5
- Las consultas **agregan toda la tabla** (no filtran por un valor específico).
- El índice no reduce el número de filas a leer → el planner prefiere Seq Scan.
- Los índices son útiles cuando hay **filtros selectivos** (ej. `WHERE id_modelo = X`).

---

## Escalabilidad
- **Q1** escala bien con índices (mejora ~3x en 1M).
- **Q2–Q5** no escalan con índices; se necesitarían:
  - Índices parciales más selectivos.
  - Materialized views para pre-agregar.
  - Particionamiento por dominio/benchmark.

---

## Nota para el informe (LaTeX)
Incluir esta discusión en la sección 5.7, con capturas de los planes (EXPLAIN) con y sin índices. Explicar que los índices no son una solución universal y dependen del patrón de consulta. Incluir la tabla de tiempos (5.6) y la gráfica de speedup.