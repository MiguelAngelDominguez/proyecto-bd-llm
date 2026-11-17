# 4.2 Carga de datos

## Objetivo
Documentar el pipeline ETL que genera y carga los 10.000 registros de la base de datos, correspondiente al punto **4.2** de la rúbrica (Hito 2).

## Archivos de la carpeta
- `4_2_1 load_proyectobd.sql`: carga masiva con `\copy` en orden de FKs.
- `4_2_2 generate_data.py`: genera los 12 CSVs (10.000 filas totales) a partir de Epoch + datos sintéticos.
- `4_2_3 load_data_original.sql`: carga original (referencia, no usada en el esquema final).

---

## 1. Flujo general (pensamiento general)

```
Fuente (Epoch CSV)
   ↓
Filtrar LLMs
   ↓
Limpieza numérica (to_numeric)
   ↓
Transformación por entidad (organizacion, modelo, dataset, experimento, gpu, benchmark, evaluacion, item, respuesta, relaciones M:N)
   ↓
Enriquecimiento (campos inventados: version, arquitectura, optimizador, etc.)
   ↓
Simulación de nulos (missingness semántica)
   ↓
Escritura streaming (CSV)
   ↓
Validación (PKs, FKs, CHECKs)
   ↓
Carga con COPY (orden de FKs)
```

---

## 2. Bloques de `generate_data.py` (explicación paso a paso)

### Bloque 1 — Lectura de semillas
```python
seed_models = read_csv("1_Modelo_LLM.csv")
seed_gpus = read_csv("3_Catalogo_GPU.csv")
```
Se usan los CSV reales de Epoch como plantillas. Se leen con `csv.DictReader` (sin pandas, para no depender de librerías).

### Bloque 2 — Organización (20 filas)
```python
orgs_raw = []
seen = set()
for r in seed_models:
    o = r["organizacion_desarrolladora"].strip()
    if o and o not in seen:
        seen.add(o)
        orgs_raw.append(o)
```
- Deduplica organizaciones reales de Epoch.
- Rellena hasta 20 con orgs sintéticas si faltan.
- Asigna `id_organizacion`, `pais`, `tipo` (Creador/Evaluador/Ambos), `fecha_fundacion`.

### Bloque 3 — GPU (20 filas)
```python
for i in range(1, 21):
    seed = seed_gpus[(i-1) % len(seed_gpus)]
    gpu_rows.append({
        "id_gpu": i,
        "modelo_gpu": ...,
        "memoria_vram": random.choice([16,24,40,48,80,96,128,144,192]),
        "num_nucleos": random.choice([...]),
        "costo_por_hora": round(random.uniform(0.5, 8.0), 4),
        "proveedor_cloud": seed["proveedor_cloud"] if random.random() > 0.3 else "",
    })
```
- Usa nombres reales de Epoch como semilla.
- Inventa `memoria_vram`, `num_nucleos`, `costo_por_hora` (obligatorios en el esquema).
- `proveedor_cloud` es NULL (cadena vacía) en ~30% de los casos (on-premise).

### Bloque 4 — Benchmark (10 filas)
```python
benchmarks = [
    ("MMLU","5.0","Knowledge","Multiple choice",5700,"..."),
    ...
]
```
- Catálogo de benchmarks reales (MMLU, HellaSwag, ARC, GSM8K, HumanEval, etc.).
- Cada uno con `version`, `categoria`, `metodo`, `num_items`, `descripcion`.

### Bloque 5 — ItemBenchmark (100 filas)
```python
for b in bench_rows:
    for j in range(10):
        item_rows.append({"id_item": iid, "id_benchmark": b["id_benchmark"], ...})
```
- 10 preguntas por benchmark (100 total).
- `prompt_pregunta` y `respuesta_esperada` sintéticas pero coherentes.

### Bloque 6 — Modelo LLM (1500 filas)
```python
creator_orgs = [o["id_organizacion"] for o in org_rows if o["tipo"] in ("Creador","Ambos")]
org_id = random.choice(creator_orgs)
base = None
if random.random() < 0.3 and i > 1:
    base = random.randint(1, i-1)
```
- `org_id`: solo orgs que pueden crear modelos (trigger `trg_validar_modelo_llm`).
- `base`: solo modelos anteriores (evita ciclos).
- `num_param`: convertido de billones a entero (`int(params_b * 1e9)`).
- Campos inventados: `version`, `arquitectura`, `tipo_modelo`, `longitud_token`, `tipo_token`, `estado`.

### Bloque 7 — Dataset (1500 filas)
```python
dataset_rows.append({
    "id_dataset": i,
    "nombre": f"Dataset {i}",
    "fase_uso": random.choice(["Entrenamiento","Validación","Prueba","Fine-tuning"]),
    "dominio": dominio,
    "formato_datos": random.choice(["Texto","JSON","Parquet","CSV"]),
    "tamanio": round(random.uniform(1.0, 500.0), 2),
    "num_registros": random.randint(1000, 10_000_000),
    ...
})
```
- `id_modelo` se omite en el CSV final (no existe en el esquema real).
- `fase_uso` con tilde (`Validación`) para cumplir CHECK.

### Bloque 8 — Experimento (1500 filas)
```python
estado = random.choice(["Finalizado","Finalizado","Finalizado","En ejecución","Error","Cancelado"])
if estado != "En ejecución":
    dur = random.randint(3600, 30*86400)
    fecha_fin = fecha_inicio + timedelta(seconds=dur)
    segundos = dur
    loss = round(random.uniform(0.5, 5.0), 6) if estado == "Finalizado" else ...
```
- `tipo_entrenamiento` con tilde (`Destilación`).
- `estado_ejecucion` con tilde (`En ejecución`).
- `fecha_fin`/`segundos`/`loss_final` solo para estados ≠ `En ejecución` (CHECK `chk_experimento_estado_fecha_fin`).

### Bloque 9 — Relaciones M:N
```python
ed_rows = [{"id_run": i, "id_dataset": i} for i in range(1, N_MODEL+1)]
eg_rows.append({"id_run": i, "id_gpu": g["id_gpu"], "horas_uso": horas, "consumo_energetico": ...})
```
- `experimento_dataset`: 1:1 (un dataset por experimento).
- `experimento_gpu` → `consumo_gpu`: 1 GPU por experimento.

### Bloque 10 — Evaluación (750 filas)
```python
eval_orgs = [o for o in org_rows if o["tipo"] in ("Evaluador","Ambos")]
org = random.choice(eval_orgs)
```
- La org evaluadora debe ser Evaluador o Ambos (trigger `trg_validar_evaluacion`).

### Bloque 11 — RespuestaModelo (1000 filas)
```python
items_by_bench = {}
for it in item_rows:
    items_by_bench.setdefault(it["id_benchmark"], []).append(it)
# al generar respuesta:
it = random.choice(items_by_bench[bench_id])
```
- El item debe ser del mismo benchmark que la evaluación (trigger `trg_validar_respuesta`).

### Bloque 12 — ResultadoBenchmark (600 filas)
```python
seen_rb = set()
while len(rb_rows) < 600:
    key = (e["id_run"], b["id_benchmark"])
    if key in seen_rb: continue
    ...
```
- PK compuesta única (sin duplicados).

---

## 3. Validación (`validate_data.py`)

Bloques de validación:
1. **PKs**: unicidad simple (organizacion, modelo, dataset, experimento, gpu, benchmark, evaluacion, item, respuesta) y compuesta (experimento_dataset, consumo_gpu, resultado_benchmark).
2. **FKs**: existencia de referencias (modelo→org, dataset→modelo (omitido en esquema real), experimento→modelo, etc.).
3. **Rangos**: `num_param > 0`, `longitud_token > 0`, `memoria_vram > 0`, `num_nucleos > 0`, `costo_por_hora > 0`, `num_items > 0`.
4. **Fechas**: `fecha_fin >= fecha_inicio` (cuando hay fecha_fin).

Resultado: **0 errores** en 10.000 registros.

---

## 4. Carga (`load_proyectobd.sql`)

Orden de carga (respeta FKs y triggers):
1. `organizacion`
2. `modelo_llm`
3. `dataset`
4. `experimento`
5. `gpu`
6. `benchmark`
7. `evaluacion`
8. `item_benchmark`
9. `respuesta_modelo` (con trigger desactivado)
10. `experimento_dataset`
11. `consumo_gpu`

```sql
ALTER TABLE respuesta_modelo DISABLE TRIGGER trg_validar_respuesta;
-- \copy ...
ALTER TABLE respuesta_modelo ENABLE TRIGGER trg_validar_respuesta;
```

## 5. Verificación post-carga
```sql
SELECT 'organizacion', COUNT(*) FROM organizacion
UNION ALL SELECT 'modelo_llm', COUNT(*) FROM modelo_llm
...
```
Total: 10.000 filas.

## Nota para el informe (LaTeX)
Explicar el pipeline ETL completo (fuente → transformación → carga), las decisiones de enriquecimiento sintético y la validación de integridad. Incluir la tabla de conteos.


## 6. Cambios respecto al esquema corregido (LaTeX 4.1)
- dataset: licencia → licencias (plural); se elimina ase_uso y id_modelo.
- xperimento: se elimina segundos.
- enchmark: se agrega utor.
- item_benchmark: PK compuesta (id_benchmark, id_item).
- 
espuesta_modelo: se agrega id_benchmark; FKs compuestas a valuacion y item_benchmark.
- xperimento_dataset: se agrega ase_uso; PK compuesta (id_run, id_dataset, fase_uso).
- consumo_gpu: sin cambios.
- Triggers: solo los 3 del informe (org creadora, org evaluadora, ciclo modelo base).
