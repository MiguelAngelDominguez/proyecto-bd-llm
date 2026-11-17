# 5.6 Resultados (tiempos de ejecución)

## Tabla consolidada (ms)

| Volumen | Q1 sin | Q1 con | Q2 sin | Q2 con | Q3 sin | Q3 con | Q4 sin | Q4 con | Q5 sin | Q5 con |
|---|---|---|---|---|---|---|---|---|---|---|
| 1k | 0.359 | 0.433 | 0.206 | 0.204 | 0.226 | 0.393 | 0.597 | 1.633 | 0.543 | 0.241 |
| 10k | 3.185 | 1.558 | 3.424 | 1.055 | 1.339 | 1.272 | 5.402 | 5.041 | 2.013 | 1.143 |
| 100k | 16.385 | 7.238 | 10.215 | 10.593 | 11.075 | 10.839 | 39.303 | 38.089 | 12.382 | 13.477 |
| 1M | 217.460 | 98.962 | 108.444 | 89.314 | 161.249 | 110.461 | 561.265 | 582.728 | 161.629 | 151.010 |

## Observaciones
- **Q1** mejora notablemente con índices en 100k y 1M (speedup ~2.2x).
- **Q2** mejora en 10k (3.25x) y 1M (1.21x), pero empeora en 100k.
- **Q3** mejora en 10k (1.05x) y 1M (1.46x), pero empeora en 1k.
- **Q4** mejora ligeramente en 10k/100k, pero empeora en 1k y 1M.
- **Q5** mejora en 1k (2.25x), 10k (1.76x) y 1M (1.07x), pero empeora en 100k.

## Tablas por consulta
Las tablas individuales por consulta se encuentran en las carpetas `5_6_1` … `5_6_5` (`.md` con SQL + tabla + plan + análisis).

## Nota para el informe (LaTeX)
Incluir esta tabla en la sección 5.6 y las tablas individuales en 5.6.1–5.6.5. Destacar que solo Q1 se beneficia claramente de los índices en volúmenes grandes. Incluir también las capturas de los planes (EXPLAIN).