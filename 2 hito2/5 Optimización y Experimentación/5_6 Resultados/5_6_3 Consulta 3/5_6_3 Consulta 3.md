# 5.6.3 Consulta 3 — Experimentos con menor loss final por modelo (top 3)

## Pregunta de negocio
¿Cuáles son los 3 experimentos con menor loss final por modelo?

## SQL (archivo `5_6_3 Consulta 3.sql`)
```sql
WITH ranked AS (
  SELECT e.id_run, m.nombre AS modelo, e.loss_final, e.num_epocas, e.tasa_aprendizaje,
         ROW_NUMBER() OVER (PARTITION BY e.id_modelo ORDER BY e.loss_final ASC NULLS LAST) AS rn
  FROM experimento e JOIN modelo_llm m ON m.id_modelo=e.id_modelo
  WHERE e.estado_ejecucion='Finalizado'
)
SELECT * FROM ranked WHERE rn <= 3;
```

## Bloques explicados
- **CTE `ranked`:** calcula `ROW_NUMBER()` particionado por `id_modelo`, ordenado por `loss_final` ASC.
- **`WHERE estado_ejecucion='Finalizado'`:** filtra solo experimentos finalizados.
- **SELECT final:** filtra top 3 por modelo (`rn <= 3`).

## Tabla de tiempos (ms)

| Volumen | Sin índices | Con índices | Speedup |
|---|---|---|---|
| 1k | 0.226 | 0.393 | 0.57x |
| 10k | 1.339 | 1.272 | 1.05x |
| 100k | 11.075 | 10.839 | 1.02x |
| 1M | 161.249 | 110.461 | 1.46x |

## Plan (EXPLAIN)
- **Sin índices:** Seq Scan + Hash Join + WindowAgg.
- **Con índices:** Seq Scan + Hash Join + WindowAgg. El índice parcial `idx_experimento_modelo_loss` no se usa.

## Análisis
- El índice parcial existe pero el planner no lo usa (volumen pequeño o baja selectividad).
- En 100k/1M el tiempo mejora ligeramente (11.1ms → 10.8ms, 161ms → 110ms).

## Verificación
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```

## Nota para el informe (LaTeX)
Incluir la consulta y la tabla. Explicar que el índice parcial no se usa porque la agregación cubre toda la tabla.