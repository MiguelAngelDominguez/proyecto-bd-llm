# 4.3 Simulación de Datos Faltantes

## Objetivo
Documentar cómo se simulan datos faltantes (NULLs) en la base de datos, correspondiente al punto **4.3** de la rúbrica (Hito 2).

## Archivo de la carpeta
- `4_3_1 validate_data.py`: valida integridad, PKs, FKs, CHECKs y fechas.

---

## 1. Clasificación de nulos

### A) Nulos por diseño (semánticos)
Campos que **deben ser NULL** por la lógica del negocio:

| Campo | Condición de NULL | Razón |
|---|---|---|
| `modelo_llm.id_modelo_base` | ~70% de los modelos | Son modelos base (no derivan de otro) |
| `experimento.fecha_fin` | `estado_ejecucion <> 'Finalizado'` | Runs en ejecución/error/cancelado no tienen fin |
| `experimento.segundos` | `estado_ejecucion <> 'Finalizado'` | No hay duración si no finalizó |
| `experimento.loss_final` | `estado_ejecucion <> 'Finalizado'` | No hay loss si no finalizó |
| `gpu.proveedor_cloud` | ~30% de las GPUs | Hardware propio (on-premise) |
| `benchmark.descripcion` | Opcional | No todos los benchmarks tienen descripción |

### B) Nulos por falta de fuente (Epoch no reporta)
Campos que **pueden ser NULL** porque la fuente no los reporta:

| Campo | Tasa de nulos | Fuente |
|---|---|---|
| `dataset.tokens_totales` | ~60% | Epoch no reporta tamaño en muchos modelos |
| `experimento.computo_pretraining_flop` | ~57% | No todos reportan FLOP |
| `experimento.computo_finetune_flop` | ~89% | Pocos reportan fine-tuning |
| `experimento.epocas` | ~74% | No siempre se reporta |
| `experimento.tam_batch` | ~90% | Casi nunca se reporta |
| `consumo_gpu.horas_entrenamiento` | ~86% | No siempre se reporta |
| `consumo_gpu.consumo_energetico_kwh` | ~89% | Calculado solo si hay datos |

---

## 2. Bloque de código que genera nulos (en `generate_data.py`)

### Nulos en `id_modelo_base`
```python
base = None
if random.random() < 0.3 and i > 1:
    base = random.randint(1, i-1)
# ...
'id_modelo_base': base if base is not None else "",
```
- ~30% de los modelos tienen un modelo base (derivados).
- ~70% son modelos base (NULL).

### Nulos en `fecha_fin` / `segundos` / `loss_final`
```python
estado = random.choice(["Finalizado","Finalizado","Finalizado","En ejecución","Error","Cancelado"])
if estado != "En ejecución":
    dur = random.randint(3600, 30*86400)
    fecha_fin = fecha_inicio + timedelta(seconds=dur)
    segundos = dur
    loss = round(random.uniform(0.5, 5.0), 6) if estado == "Finalizado" else round(random.uniform(0.5, 5.0), 6)
```
- Solo `Finalizado` tiene loss real; `Error`/`Cancelado` también tienen fecha_fin (abortados).
- `En ejecución` no tiene fecha_fin (CHECK `chk_experimento_estado_fecha_fin`).

### Nulos en `proveedor_cloud`
```python
"proveedor_cloud": seed["proveedor_cloud"] if random.random() > 0.3 else "",
```
- ~30% son NULL (on-premise).

### Nulos en `tokens_totales` (Epoch)
```python
'tokens_totales': df_llm['Training dataset size (total)'].apply(lambda x: int(x) if pd.notnull(x) and x > 0 else None)
```
- Se mantiene NULL si Epoch no reporta.

---

## 3. Por qué se mantienen los nulos
- **Robustez de consultas:** las vistas y queries deben manejar NULLs (LEFT JOIN, COALESCE).
- **Realismo:** los datos reales tienen missing values.
- **Prueba de constraints:** el esquema permite NULLs en campos opcionales.

## 4. Validación (`validate_data.py`)
- Verifica PKs, FKs, CHECKs, rangos y fechas.
- No falla por nulos (son permitidos donde el esquema lo indica).

## Nota para el informe (LaTeX)
Explicar la diferencia entre nulos por diseño y nulos por falta de fuente, y cómo se mantienen para probar la robustez de consultas y vistas. Incluir tabla de tasas de missingness.


## 5. Cambios respecto al esquema corregido
- dataset: sin ase_uso ni id_modelo.
- xperimento: sin segundos (no se simula nulo en ese campo).
- xperimento_dataset: ase_uso puede ser NULL? No, es NOT NULL en el esquema.
- 
espuesta_modelo: id_benchmark se deriva de la evaluación (no NULL).
