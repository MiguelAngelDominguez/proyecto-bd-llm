# 5.6.1–5.6.5 Resultados por consulta

## Q1 — Modelo con mayor número de parámetros por arquitectura

| Volumen | Sin índices (ms) | Con índices (ms) | Speedup |
|---|---|---|---|
| 1k | 0.274 | 0.283 | 0.97x |
| 10k | 1.609 | 1.606 | 1.00x |
| 100k | 18.700 | 6.897 | 2.71x |
| 1M | 230.178 | 76.805 | 3.00x |

## Q2 — Datasets más utilizados por dominio (top 5)

| Volumen | Sin índices (ms) | Con índices (ms) | Speedup |
|---|---|---|---|
| 1k | 0.237 | 0.227 | 1.04x |
| 10k | 1.066 | 1.083 | 0.98x |
| 100k | 16.679 | 10.463 | 1.59x |
| 1M | 142.170 | 210.319 | 0.68x |

## Q3 — Experimentos con menor loss final por modelo (top 3)

| Volumen | Sin índices (ms) | Con índices (ms) | Speedup |
|---|---|---|---|
| 1k | 0.312 | 0.264 | 1.18x |
| 10k | 1.391 | 1.244 | 1.12x |
| 100k | 11.785 | 17.690 | 0.67x |
| 1M | 169.974 | 203.092 | 0.84x |

## Q4 — Consumo total de horas GPU y costo por experimento

| Volumen | Sin índices (ms) | Con índices (ms) | Speedup |
|---|---|---|---|
| 1k | 0.711 | 0.580 | 1.23x |
| 10k | 4.701 | 4.207 | 1.12x |
| 100k | 39.143 | 42.913 | 0.91x |
| 1M | 541.884 | 556.302 | 0.97x |

## Q5 — Mejor resultado por benchmark y modelo (top 3)

| Volumen | Sin índices (ms) | Con índices (ms) | Speedup |
|---|---|---|---|
| 1k | 0.222 | 0.213 | 1.04x |
| 10k | 1.212 | 1.206 | 1.00x |
| 100k | 13.172 | 13.214 | 1.00x |
| 1M | 150.546 | 171.121 | 0.88x |

## Nota para el informe (LaTeX)
Incluir estas tablas en la sección 5.6 (5.6.1–5.6.5). Destacar que solo Q1 se beneficia claramente de los índices en volúmenes grandes.