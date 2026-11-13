# 5.6.1 Consulta 1 — Modelo con mayor número de parámetros por arquitectura

## Pregunta de negocio
¿Qué modelo tiene más parámetros dentro de cada arquitectura?

## SQL (archivo `5_6_1 Consulta 1.sql`)
```sql
WITH ranked AS (
  SELECT nombre, arquitectura, num_param,
         RANK() OVER (PARTITION BY arquitectura ORDER BY num_param DESC) AS rnk
  FROM modelo_llm
)
SELECT arquitectura, nombre, num_param
FROM ranked WHERE rnk = 1;
```

## Bloques explicados
- **CTE `ranked`:** calcula el ranking de modelos por `num_param` dentro de cada `arquitectura`.
- **`RANK() OVER (PARTITION BY arquitectura ORDER BY num_param DESC)`:** particiona por arquitectura y ordena descendente.
- **SELECT final:** filtra solo el top 1 por arquitectura (`rnk = 1`).

## Tabla de tiempos (ms)

| Volumen | Sin índices | Con índices | Speedup |
|---|---|---|---|
| 1k | 0.274 | 0.283 | 0.97x |
| 10k | 1.609 | 1.606 | 1.00x |
| 100k | 18.700 | 6.897 | 2.71x |
| 1M | 230.178 | 76.805 | 3.00x |

## Plan (EXPLAIN)
- **Sin índices:** Seq Scan + Sort + WindowAgg.
- **Con índices:** el índice `idx_modelo_llm_arq_numparam (arquitectura, num_param DESC)` permite Index Scan + Sort, reduciendo el tiempo en volúmenes grandes.

## Análisis
- En 1k/10k el índice no ayuda (Seq Scan más barato).
- En 100k/1M el índice reduce el tiempo ~3x porque evita ordenar toda la tabla.

## Verificación
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```

## Nota para el informe (LaTeX)
Incluir la consulta, la tabla de tiempos y el plan con índices. Destacar que es la única consulta que se beneficia claramente de los índices.