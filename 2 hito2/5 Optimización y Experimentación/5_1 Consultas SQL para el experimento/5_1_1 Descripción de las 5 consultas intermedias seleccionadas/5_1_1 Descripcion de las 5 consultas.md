# 5.1.1 Descripción de las 5 consultas intermedias seleccionadas

## Objetivo
Documentar las 5 consultas seleccionadas para el experimento de optimización, justificando por qué son **intermedias (no triviales)** y por qué son **críticas** para el dominio.

---

## Evidencia de prueba previa (antes de capturar planes)
Antes de medir tiempos o capturar planes, las 5 consultas se ejecutaron en los 4 volúmenes (1k/10k/100k/1M) para confirmar que no dan errores. Archivos de salida:
- `5_1_2 Implementación de consultas en SQL/1k_output.txt`
- `5_1_2 Implementación de consultas en SQL/100k_output.txt`
- `5_1_2 Implementación de consultas en SQL/1M_output.txt`
- (10k se ejecutó en `proyectobd` directamente)

Resultado: **0 errores** en todos los volúmenes.

---

## Q1 — Modelo con mayor número de parámetros por arquitectura

### Pregunta de negocio
¿Qué modelo tiene más parámetros dentro de cada arquitectura? (ej. Transformer, MoE, SSM, etc.)

### Tablas involucradas
- `modelo_llm` (id_modelo, nombre, arquitectura, num_param)

### Operación
- `RANK() OVER (PARTITION BY arquitectura ORDER BY num_param DESC)` → window function.
- Filtra `rnk = 1` para obtener el top por arquitectura.

### Por qué es intermedia (no trivial)
- Usa **window function** con partición.
- Requiere ordenamiento dentro de cada partición.
- No es un simple `SELECT *` ni un `GROUP BY` básico.

### SQL completo
```sql
WITH ranked AS (
  SELECT nombre, arquitectura, num_param,
         RANK() OVER (PARTITION BY arquitectura ORDER BY num_param DESC) AS rnk
  FROM modelo_llm
)
SELECT arquitectura, nombre, num_param
FROM ranked WHERE rnk = 1;
```

### Bloques explicados
- **CTE `ranked`:** calcula el ranking de modelos por `num_param` dentro de cada `arquitectura`.
- **`RANK() OVER (PARTITION BY arquitectura ORDER BY num_param DESC)`:** particiona por arquitectura y ordena descendente.
- **SELECT final:** filtra solo el top 1 por arquitectura (`rnk = 1`).

---

## Q2 — Datasets más utilizados por dominio (top 5)

### Pregunta de negocio
¿Qué dominios tienen más experimentos y cuántos registros promedio?

### Tablas involucradas
- `dataset` (id_dataset, dominio, num_registros)
- `experimento_dataset` (id_run, id_dataset)

### Operación
- JOIN + GROUP BY + AVG + ORDER BY + LIMIT.

### Por qué es intermedia
- Join M:N + agregación + ordenamiento + límite.
- Requiere entender la relación entre datasets y experimentos.

### SQL completo
```sql
SELECT d.dominio, COUNT(ed.id_run) AS num_experimentos, AVG(d.num_registros) AS avg_registros
FROM dataset d
JOIN experimento_dataset ed ON ed.id_dataset = d.id_dataset
GROUP BY d.dominio
ORDER BY num_experimentos DESC
LIMIT 5;
```

### Bloques explicados
- **JOIN:** une `dataset` con `experimento_dataset` por `id_dataset`.
- **GROUP BY dominio:** agrega por dominio.
- **COUNT(ed.id_run):** número de experimentos por dominio.
- **AVG(d.num_registros):** promedio de registros por dominio.
- **ORDER BY ... LIMIT 5:** top 5 dominios.

---

## Q3 — Experimentos con menor loss final por modelo (top 3)

### Pregunta de negocio
¿Cuáles son los 3 experimentos con menor loss final por modelo?

### Tablas involucradas
- `experimento` (id_run, id_modelo, loss_final, num_epocas, tasa_aprendizaje, estado_ejecucion)
- `modelo_llm` (id_modelo, nombre)

### Operación
- `ROW_NUMBER() OVER (PARTITION BY id_modelo ORDER BY loss_final ASC NULLS LAST)` + filtro de estado.

### Por qué es intermedia
- Window function con partición + filtro de estado + NULLS LAST.
- Requiere manejar nulos (experimentos sin loss).

### SQL completo
```sql
WITH ranked AS (
  SELECT e.id_run, m.nombre AS modelo, e.loss_final, e.num_epocas, e.tasa_aprendizaje,
         ROW_NUMBER() OVER (PARTITION BY e.id_modelo ORDER BY e.loss_final ASC NULLS LAST) AS rn
  FROM experimento e JOIN modelo_llm m ON m.id_modelo=e.id_modelo
  WHERE e.estado_ejecucion='Finalizado'
)
SELECT * FROM ranked WHERE rn <= 3;
```

### Bloques explicados
- **CTE `ranked`:** calcula `ROW_NUMBER()` particionado por `id_modelo`, ordenado por `loss_final` ASC.
- **`WHERE estado_ejecucion='Finalizado'`:** filtra solo experimentos finalizados.
- **SELECT final:** filtra top 3 por modelo (`rn <= 3`).

---

## Q4 — Consumo total de horas GPU y costo por experimento

### Pregunta de negocio
¿Cuántas horas y kWh consumió cada experimento y cuál fue su costo?

### Tablas involucradas
- `experimento` (id_run, id_modelo)
- `modelo_llm` (id_modelo, nombre)
- `consumo_gpu` (id_run, id_gpu, horas_uso, consumo_energetico)
- `gpu` (id_gpu, costo_por_hora)

### Operación
- JOIN múltiple + SUM + GROUP BY + ORDER BY.

### Por qué es intermedia
- Join M:N (experimento–GPU) + agregación + cálculo de costo.
- Requiere unir 4 tablas.

### SQL completo
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

### Bloques explicados
- **JOIN múltiple:** experimento → modelo → consumo_gpu → gpu.
- **SUM(cg.horas_uso):** horas totales por experimento.
- **SUM(cg.horas_uso * g.costo_por_hora):** costo estimado en USD.
- **SUM(cg.consumo_energetico):** kWh total.
- **GROUP BY e.id_run, m.nombre:** agrega por experimento.
- **ORDER BY costo_usd DESC:** ordena por costo descendente.

---

## Q5 — Mejor resultado por benchmark y modelo (top 3)

### Pregunta de negocio
¿Cuáles son los 3 mejores modelos por benchmark según `resultado_metrica`?

### Tablas involucradas
- `evaluacion` (id_evaluacion, id_modelo, id_benchmark, resultado_metrica, fecha_evaluacion)
- `benchmark` (id_benchmark, nombre)
- `modelo_llm` (id_modelo, nombre)

### Operación
- `RANK() OVER (PARTITION BY id_benchmark ORDER BY resultado_metrica DESC)` + filtro top 3.

### Por qué es intermedia
- Window function + join M:N + filtro top N.
- Requiere manejar múltiples benchmarks y modelos.

### SQL completo
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

### Bloques explicados
- **CTE `ranked`:** calcula `RANK()` particionado por `id_benchmark`, ordenado por `resultado_metrica` DESC.
- **JOINs:** une `evaluacion` con `benchmark` y `modelo_llm`.
- **SELECT final:** filtra top 3 por benchmark (`rnk <= 3`).

---

## Nota para el informe (LaTeX)
Incluir esta descripción en la sección 5.1.1. Las consultas son intermedias (no triviales) porque usan window functions, CTEs, joins M:N y agregaciones. Se probaron en los 4 volúmenes (1k/10k/100k/1M) sin errores.