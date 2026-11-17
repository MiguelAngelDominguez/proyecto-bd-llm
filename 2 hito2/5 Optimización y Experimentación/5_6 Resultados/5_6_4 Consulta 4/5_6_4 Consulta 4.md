# 5.6.4 Consulta 4 — Consumo total de horas GPU y costo por experimento

## Pregunta de negocio
¿Cuántas horas y kWh consumió cada experimento y cuál fue su costo?

## SQL (archivo `5_6_4 Consulta 4.sql`)
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

## Bloques explicados
- **JOIN múltiple:** experimento → modelo → consumo_gpu → gpu.
- **SUM(cg.horas_uso):** horas totales por experimento.
- **SUM(cg.horas_uso * g.costo_por_hora):** costo estimado en USD.
- **SUM(cg.consumo_energetico):** kWh total.
- **GROUP BY e.id_run, m.nombre:** agrega por experimento.
- **ORDER BY costo_usd DESC:** ordena por costo descendente.

## Tabla de tiempos (ms)

| Volumen | Sin índices | Con índices | Speedup |
|---|---|---|---|
| 1k | 0.597 | 1.633 | 0.37x |
| 10k | 5.402 | 5.041 | 1.07x |
| 100k | 39.303 | 38.089 | 1.03x |
| 1M | 561.265 | 582.728 | 0.96x |

## Plan (EXPLAIN)
- **Sin índices:** Seq Scan + Hash Join + HashAggregate + Sort.
- **Con índices:** mismo plan (Seq Scan + Hash Join). Los índices en `consumo_gpu(id_run)` e `id_gpu` no se usan.

## Análisis
- La agregación cubre toda la tabla → Seq Scan más eficiente.
- Los índices no ayudan (tiempo empeora ligeramente en 1k y 1M).

## Verificación
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```

## Nota para el informe (LaTeX)
Incluir la consulta y la tabla. Explicar que los índices no son efectivos para agregaciones sobre toda la tabla.