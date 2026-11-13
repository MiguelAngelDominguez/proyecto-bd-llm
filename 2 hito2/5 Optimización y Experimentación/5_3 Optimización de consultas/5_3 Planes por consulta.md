# 5.3.1–5.3.5 Planes de índices por consulta

## Q1 — Modelo con mayor número de parámetros por arquitectura

### Sin índices (10k)
```
Seq Scan on modelo_llm  (cost=0.00..39.00 rows=1500 width=43)
  -> Sort  (cost=118.13..121.88 rows=1500 width=43)
       Sort Key: modelo_llm.arquitectura, modelo_llm.num_param DESC
  -> WindowAgg  (cost=118.15..148.13 rows=1500 width=51)
```

### Con índices (10k)
```
Seq Scan on modelo_llm  (cost=0.00..39.00 rows=1500 width=43)
  -> Sort  (cost=118.13..121.88 rows=1500 width=43)
       Sort Key: modelo_llm.arquitectura, modelo_llm.num_param DESC
  -> WindowAgg  (cost=118.15..148.13 rows=1500 width=51)
```

**Índice:** `idx_modelo_llm_arq_numparam (arquitectura, num_param DESC)`
**Observación:** En 10k el planner usa Seq Scan (volumen pequeño). En 100k/1M el índice reduce el tiempo de 18.7ms a 6.9ms (100k) y de 230ms a 76ms (1M).

---

## Q2 — Datasets más utilizados por dominio (top 5)

### Sin índices (10k)
```
Seq Scan on experimento_dataset ed  (cost=0.00..22.00 rows=1500 width=8)
Seq Scan on dataset d  (cost=0.00..37.00 rows=1500 width=21)
Hash Join  (cost=55.75..81.70 rows=1500 width=21)
HashAggregate  (cost=92.95..92.96 rows=1 width=49)
Sort  (cost=92.97..92.98 rows=1 width=49)
Limit  (cost=92.97..92.98 rows=1 width=49)
```

### Con índices (10k)
```
Seq Scan on experimento_dataset ed  (cost=0.00..22.00 rows=1500 width=8)
Seq Scan on dataset d  (cost=0.00..37.00 rows=1500 width=21)
Hash Join  (cost=55.75..81.70 rows=1500 width=21)
HashAggregate  (cost=92.95..92.96 rows=1 width=49)
Sort  (cost=92.97..92.98 rows=1 width=49)
Limit  (cost=92.97..92.98 rows=1 width=49)
```

**Índices:** `idx_dataset_dominio (dominio)`, `idx_exp_dataset_dataset (id_dataset)`
**Observación:** El planner sigue usando Seq Scan + Hash Join porque la agregación cubre toda la tabla. Los índices no ayudan (el tiempo incluso empeora ligeramente en 100k/1M).

---

## Q3 — Experimentos con menor loss final por modelo (top 3)

### Sin índices (10k)
```
Seq Scan on experimento e  (cost=0.00..39.00 rows=1500 width=43)
  Filter: (estado_ejecucion = 'Finalizado')
Seq Scan on modelo_llm m  (cost=0.00..39.00 rows=1500 width=43)
Hash Join  (cost=... )
WindowAgg  (cost=... )
```

### Con índices (10k)
```
Seq Scan on experimento e  (cost=0.00..39.00 rows=1500 width=43)
  Filter: (estado_ejecucion = 'Finalizado')
Seq Scan on modelo_llm m  (cost=0.00..39.00 rows=1500 width=43)
Hash Join  (cost=... )
WindowAgg  (cost=... )
```

**Índice:** `idx_experimento_modelo_loss (id_modelo, loss_final) WHERE estado_ejecucion = 'Finalizado'`
**Observación:** El índice parcial existe pero el planner no lo usa en 10k (volumen pequeño). En 100k/1M el tiempo empeora ligeramente (11.8ms → 17.7ms), lo que sugiere que el índice no es selectivo para esta consulta.

---

## Q4 — Consumo total de horas GPU y costo por experimento

### Sin índices (10k)
```
Seq Scan on experimento e  (cost=0.00..39.00 rows=1500 width=43)
Seq Scan on modelo_llm m  (cost=0.00..39.00 rows=1500 width=43)
Seq Scan on consumo_gpu cg  (cost=0.00..22.00 rows=1500 width=16)
Seq Scan on gpu g  (cost=0.00..1.20 rows=20 width=12)
Hash Join / Nested Loop
HashAggregate  (cost=... )
Sort  (cost=... )
```

### Con índices (10k)
```
Seq Scan on experimento e  (cost=0.00..39.00 rows=1500 width=43)
Seq Scan on modelo_llm m  (cost=0.00..39.00 rows=1500 width=43)
Seq Scan on consumo_gpu cg  (cost=0.00..22.00 rows=1500 width=16)
Seq Scan on gpu g  (cost=0.00..1.20 rows=20 width=12)
Hash Join / Nested Loop
HashAggregate  (cost=... )
Sort  (cost=... )
```

**Índices:** `idx_consumo_gpu_run (id_run)`, `idx_consumo_gpu_gpu (id_gpu)`, `idx_experimento_modelo (id_modelo)`
**Observación:** La agregación cubre toda la tabla → Seq Scan más eficiente. Los índices no ayudan (tiempo empeora ligeramente en 100k/1M).

---

## Q5 — Mejor resultado por benchmark y modelo (top 3)

### Sin índices (10k)
```
Seq Scan on evaluacion e  (cost=0.00..22.00 rows=750 width=24)
Seq Scan on benchmark b  (cost=0.00..1.20 rows=10 width=49)
Seq Scan on modelo_llm m  (cost=0.00..39.00 rows=1500 width=43)
Hash Join / Nested Loop
WindowAgg  (cost=... )
```

### Con índices (10k)
```
Seq Scan on evaluacion e  (cost=0.00..22.00 rows=750 width=24)
Seq Scan on benchmark b  (cost=0.00..1.20 rows=10 width=49)
Seq Scan on modelo_llm m  (cost=0.00..39.00 rows=1500 width=43)
Hash Join / Nested Loop
WindowAgg  (cost=... )
```

**Índice:** `idx_evaluacion_benchmark_score (id_benchmark, resultado_metrica DESC)`
**Observación:** El planner sigue usando Seq Scan porque la agregación cubre toda la tabla. El índice no reduce el número de filas a leer.

---

## Nota para el informe (LaTeX)
Incluir estos planes en la sección 5.3 (5.3.1–5.3.5) y explicar por qué el planner elige Seq Scan en volúmenes pequeños y por qué los índices solo ayudan en Q1 (que filtra/particiona por arquitectura). Para Q2–Q5, los índices no son efectivos porque son consultas de agregación sobre toda la tabla.