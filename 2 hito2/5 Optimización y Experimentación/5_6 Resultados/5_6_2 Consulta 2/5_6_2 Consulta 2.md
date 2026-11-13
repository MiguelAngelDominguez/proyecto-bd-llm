# 5.6.2 Consulta 2 — Datasets más utilizados por dominio (top 5)

## Pregunta de negocio
¿Qué dominios tienen más experimentos y cuántos registros promedio?

## SQL (archivo `5_6_2 Consulta 2.sql`)
```sql
SELECT d.dominio, COUNT(ed.id_run) AS num_experimentos, AVG(d.num_registros) AS avg_registros
FROM dataset d
JOIN experimento_dataset ed ON ed.id_dataset = d.id_dataset
GROUP BY d.dominio
ORDER BY num_experimentos DESC
LIMIT 5;
```

## Bloques explicados
- **JOIN:** une `dataset` con `experimento_dataset` por `id_dataset`.
- **GROUP BY dominio:** agrega por dominio.
- **COUNT(ed.id_run):** número de experimentos por dominio.
- **AVG(d.num_registros):** promedio de registros por dominio.
- **ORDER BY ... LIMIT 5:** top 5 dominios.

## Tabla de tiempos (ms)

| Volumen | Sin índices | Con índices | Speedup |
|---|---|---|---|
| 1k | 0.237 | 0.227 | 1.04x |
| 10k | 1.066 | 1.083 | 0.98x |
| 100k | 16.679 | 10.463 | 1.59x |
| 1M | 142.170 | 210.319 | 0.68x |

## Plan (EXPLAIN)
- **Sin índices:** Seq Scan + Hash Join + HashAggregate + Sort.
- **Con índices:** mismo plan (Seq Scan + Hash Join). El índice en `dominio` no se usa porque la agregación cubre toda la tabla.

## Análisis
- Los índices no ayudan porque la consulta agrega **toda la tabla** (no filtra por un dominio específico).
- En 1M, los índices empeoran el tiempo (210ms vs. 142ms) por overhead de mantenimiento.

## Verificación
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```

## Nota para el informe (LaTeX)
Incluir la consulta y la tabla. Explicar que los índices no son efectivos para agregaciones sobre toda la tabla.