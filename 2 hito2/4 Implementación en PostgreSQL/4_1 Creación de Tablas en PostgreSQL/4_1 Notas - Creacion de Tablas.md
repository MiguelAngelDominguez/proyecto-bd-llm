# 4.1 Creación de Tablas en PostgreSQL

## Objetivo
Documentar el modelo físico implementado en PostgreSQL: tablas, claves, constraints y triggers. Esta sección corresponde al punto **4.1** de la rúbrica (Hito 2).

## Archivos de la carpeta
- `4_1_1 DDL base.sql`: DDL original del proyecto (tablas base + constraints).
- `4_1_2 Esquema real con constraints y triggers.sql`: esquema final cargado en `proyectobd` (incluye triggers y reglas de negocio).

---

## 1. Modelo físico (9 entidades + 3 intermedias)

### Entidades
| Tabla | PK | FKs principales |
|---|---|---|
| `organizacion` | `id_organizacion` | — |
| `modelo_llm` | `id_modelo` | `id_organizacion` → organizacion; `id_modelo_base` → modelo_llm (self) |
| `dataset` | `id_dataset` | — (sin id_modelo en el esquema final) |
| `experimento` | `id_run` | `id_modelo` → modelo_llm |
| `gpu` | `id_gpu` | — |
| `benchmark` | `id_benchmark` | — |
| `evaluacion` | `id_evaluacion` | `id_modelo`, `id_benchmark`, `id_organizacion_evaluadora` |
| `item_benchmark` | `id_item` | `id_benchmark` → benchmark |
| `respuesta_modelo` | `id_respuesta` | `id_evaluacion`, `id_item` |

### Intermedias (M:N)
| Tabla | PK compuesta | FKs |
|---|---|---|
| `experimento_dataset` | `(id_run, id_dataset)` | `id_run` → experimento; `id_dataset` → dataset |
| `consumo_gpu` | `(id_run, id_gpu)` | `id_run` → experimento; `id_gpu` → gpu |

---

## 2. Bloques del DDL (pensamiento general)

### Bloque A — Creación de tablas base
```sql
CREATE TABLE organizacion (
    id_organizacion INTEGER,
    nombre VARCHAR(50),
    pais VARCHAR(50),
    tipo VARCHAR(20),
    fecha_fundacion DATE
);
```
Se crea sin constraints primero; luego se agregan PKs/FKs/CHECKs con `ALTER TABLE`. Esto facilita la carga masiva (se pueden desactivar triggers/FKs si hace falta).

### Bloque B — Claves y relaciones
```sql
ALTER TABLE modelo_llm ADD CONSTRAINT pk_modelo_ll PRIMARY KEY (id_modelo);
ALTER TABLE modelo_llm ADD CONSTRAINT fk_modelo_llm_organizacion
    FOREIGN KEY (id_organizacion) REFERENCES organizacion (id_organizacion);
ALTER TABLE modelo_llm ADD CONSTRAINT fk_modelo_llm_modelo_base
    FOREIGN KEY (id_modelo_base) REFERENCES modelo_llm (id_modelo);
```
- `id_modelo_base` es nullable (modelos base no derivan de otro).
- Se agrega CHECK `id_modelo_base IS NULL OR id_modelo_base <> id_modelo` para evitar auto-referencia.

### Bloque C — Constraints de dominio
```sql
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_tipo_entrenamiento
    CHECK (tipo_entrenamiento IN ('Preentrenamiento','Fine-tuning','RLHF','Destilación'));
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_estado
    CHECK (estado_ejecucion IN ('En ejecución','Finalizado','Error','Cancelado'));
```
Los enums usan tildes exactas (`Destilación`, `En ejecución`), por eso el generador de datos debe respetarlas.

### Bloque D — Reglas de negocio con triggers
```sql
CREATE TRIGGER trg_validar_modelo_llm
    BEFORE INSERT OR UPDATE OF id_organizacion, id_modelo_base ON modelo_llm
    FOR EACH ROW EXECUTE FUNCTION fn_validar_modelo_llm();
```
- Valida que la org creadora no sea solo `Evaluador`.
- Evita ciclos en la cadena de `id_modelo_base`.

```sql
CREATE TRIGGER trg_calcular_segundos
    BEFORE INSERT OR UPDATE OF fecha_inicio, fecha_fin, segundos ON experimento
    FOR EACH ROW EXECUTE FUNCTION fn_calcular_segundos();
```
- Calcula `segundos = fecha_fin - fecha_inicio` automáticamente.

---

## 3. Diferencias entre DDL base y esquema real

| Aspecto | DDL base (`4_1_1`) | Esquema real (`4_1_2`) |
|---|---|---|
| Tabla de consumo | `experimento_gpu` | `consumo_gpu` |
| `resultado_benchmark` | Existe | No existe |
| `dataset.id_modelo` | Existe | No existe |
| Triggers | Básicos | Incluye validaciones de org creadora/evaluadora, respuesta vs. benchmark |

**Por qué se renombró `experimento_gpu` → `consumo_gpu`:** el esquema final se ajustó al dominio real (la tabla representa consumo de GPU, no solo el experimento). Por eso todas las vistas/procedimientos deben usar `consumo_gpu`.

---

## 4. Ejecución

```bash
psql -U postgres -d proyectobd -f "4 Implementación en PostgreSQL/4_1 Creación de Tablas en PostgreSQL/4_1_2 Esquema real con constraints y triggers.sql"
```

## 5. Verificación

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

Resultado esperado: 11 tablas (`benchmark`, `consumo_gpu`, `dataset`, `evaluacion`, `experimento`, `experimento_dataset`, `gpu`, `item_benchmark`, `modelo_llm`, `organizacion`, `respuesta_modelo`).

## Nota para el informe (LaTeX)
Explicar el modelo físico, las decisiones de implementación (constraints, triggers, nombres de tablas) y por qué se eligió PostgreSQL para estas reglas de negocio.