# 5.6.5 Consulta 5 — Mejor resultado por benchmark y modelo (top 3)

## Pregunta de negocio
¿Cuáles son los 3 mejores modelos por benchmark según `resultado_metrica`?

## SQL (archivo `5_6_5 Consulta 5.sql`)
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

## Bloques explicados
- **CTE `ranked`:** calcula `RANK()` particionado por `id_benchmark`, ordenado por `resultado_metrica` DESC.
- **JOINs:** une `evaluacion` con `benchmark` y `modelo_llm`.
- **SELECT final:** filtra top 3 por benchmark (`rnk <= 3`).

## Tabla de tiempos (ms)

| Volumen | Sin índices | Con índices | Speedup |
|---|---|---|---|
| 1k | 0.543 | 0.241 | 2.25x |
| 10k | 2.013 | 1.143 | 1.76x |
| 100k | 12.382 | 13.477 | 0.92x |
| 1M | 161.629 | 151.010 | 1.07x |

## Plan (EXPLAIN)
- **Sin índices:** Seq Scan + Hash Join + WindowAgg.
- **Con índices:** Seq Scan + Hash Join + WindowAgg. El índice `idx_evaluacion_benchmark_score` no se usa.

## Análisis
- La agregación cubre toda la tabla → Seq Scan más eficiente.
- Los índices no ayudan (tiempo empeora ligeramente en 100k).

## Verificación
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```

## Nota para el informe (LaTeX)
Incluir la consulta y la tabla. Explicar que los índices no son efectivos para agregaciones sobre toda la tabla.