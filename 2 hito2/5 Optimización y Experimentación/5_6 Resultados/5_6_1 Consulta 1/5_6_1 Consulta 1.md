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
| 1k | 0.359 | 0.433 | 0.83x |
| 10k | 3.185 | 1.558 | 2.04x |
| 100k | 16.385 | 7.238 | 2.26x |
| 1M | 217.460 | 98.962 | 2.20x |

## Plan (EXPLAIN)
- **Sin índices:** Seq Scan + Sort + WindowAgg.
- **Con índices:** Index Scan + Sort + WindowAgg (en 100k/1M).

## Análisis
- En 1k/10k el índice no ayuda (Seq Scan más barato).
- En 100k/1M el índice reduce el tiempo ~2x porque evita ordenar toda la tabla.

## Verificación
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```

## Nota para el informe (LaTeX)
Incluir la consulta, la tabla de tiempos y el plan con índices. Destacar que es la única consulta que se beneficia claramente de los índices.