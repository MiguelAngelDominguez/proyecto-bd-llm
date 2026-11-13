# 5.6 Resultados (tiempos de ejecución)

## Tabla consolidada (ms)

| Volumen | Q1 sin | Q1 con | Q2 sin | Q2 con | Q3 sin | Q3 con | Q4 sin | Q4 con | Q5 sin | Q5 con |
|---|---|---|---|---|---|---|---|---|---|---|
| 1k | 0.274 | 0.283 | 0.237 | 0.227 | 0.312 | 0.264 | 0.711 | 0.580 | 0.222 | 0.213 |
| 10k | 1.609 | 1.606 | 1.066 | 1.083 | 1.391 | 1.244 | 4.701 | 4.207 | 1.212 | 1.206 |
| 100k | 18.700 | 6.897 | 16.679 | 10.463 | 11.785 | 17.690 | 39.143 | 42.913 | 13.172 | 13.214 |
| 1M | 230.178 | 76.805 | 142.170 | 210.319 | 169.974 | 203.092 | 541.884 | 556.302 | 150.546 | 171.121 |

## Observaciones
- **Q1** mejora notablemente con índices en 100k y 1M (speedup ~3x).
- **Q2–Q5** son más lentas con índices en volúmenes grandes (el planner prefiere Seq Scan para agregaciones sobre toda la tabla).

## Tablas por consulta
Las tablas individuales por consulta se encuentran en las carpetas `5_6_1` … `5_6_5` (`.md` con SQL + tabla + plan + análisis).

## Nota para el informe (LaTeX)
Incluir esta tabla consolidada en la sección 5.6 y las tablas individuales en 5.6.1–5.6.5. Destacar que solo Q1 se beneficia claramente de los índices. Incluir también las capturas de los planes (EXPLAIN).