# 4.6 Triggers

## Objetivo
Documentar los triggers implementados (automatización y reglas de negocio), correspondiente al punto **4.6** de la rúbrica (Hito 2).

## Archivo fuente
Los triggers están definidos en `4_1_2 Esquema real con constraints y triggers.sql` (y funciones auxiliares en `4_5_1 procedures.sql`).

---

## 1. Pensamiento general
Los triggers implementan reglas de negocio que no se pueden expresar solo con CHECKs:
- Validación de roles de organizaciones (creador vs. evaluador).
- Prevención de ciclos en modelos base.
- Coherencia entre item y benchmark en respuestas.
- Cálculo automático de duración.

---

## 2. Trigger 1: `trg_validar_modelo_llm`

### Función
```sql
CREATE OR REPLACE FUNCTION fn_validar_modelo_llm()
RETURNS TRIGGER AS $$
DECLARE
    v_tipo   organizacion.tipo%TYPE;
    v_actual INTEGER;
BEGIN
    SELECT tipo INTO v_tipo FROM organizacion WHERE id_organizacion = NEW.id_organizacion;
    IF v_tipo = 'Evaluador' THEN
        RAISE EXCEPTION 'La organizacion % es solo Evaluador y no puede crear modelos', NEW.id_organizacion;
    END IF;

    v_actual := NEW.id_modelo_base;
    WHILE v_actual IS NOT NULL LOOP
        IF v_actual = NEW.id_modelo THEN
            RAISE EXCEPTION 'El modelo % formaria un ciclo de modelos base', NEW.id_modelo;
        END IF;
        SELECT id_modelo_base INTO v_actual FROM modelo_llm WHERE id_modelo = v_actual;
    END LOOP;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
```

### Bloques
- **Validación de org creadora:** si la org es solo `Evaluador`, no puede crear modelos.
- **Prevención de ciclos:** recorre la cadena de `id_modelo_base` y rechaza si vuelve al modelo actual.

---

## 3. Trigger 2: `trg_validar_evaluacion`

### Función
```sql
CREATE OR REPLACE FUNCTION fn_validar_evaluacion()
RETURNS TRIGGER AS $$
DECLARE
    v_tipo organizacion.tipo%TYPE;
BEGIN
    SELECT tipo INTO v_tipo FROM organizacion WHERE id_organizacion = NEW.id_organizacion_evaluadora;
    IF v_tipo = 'Creador' THEN
        RAISE EXCEPTION 'La organizacion % es solo Creador y no puede evaluar', NEW.id_organizacion_evaluadora;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
```

### Bloque
- Valida que la org evaluadora sea `Evaluador` o `Ambos`.

---

## 4. Trigger 3: `trg_validar_respuesta`

### Función
```sql
CREATE OR REPLACE FUNCTION fn_validar_respuesta()
RETURNS TRIGGER AS $$
DECLARE
    v_bench_item INTEGER;
    v_bench_eval INTEGER;
BEGIN
    SELECT id_benchmark INTO v_bench_item FROM item_benchmark WHERE id_item = NEW.id_item;
    SELECT id_benchmark INTO v_bench_eval FROM evaluacion WHERE id_evaluacion = NEW.id_evaluacion;
    IF v_bench_item IS NOT NULL AND v_bench_eval IS NOT NULL AND v_bench_item <> v_bench_eval THEN
        RAISE EXCEPTION 'El item % no pertenece al benchmark de la evaluacion %', NEW.id_item, NEW.id_evaluacion;
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
```

### Bloque
- Valida que el item respondido pertenezca al mismo benchmark que la evaluación.

### Nota de rendimiento
- Se **desactiva** durante la carga masiva (`DISABLE TRIGGER`) y se **reactiva** al final, porque hace 2 lecturas por fila.

---

## 5. Trigger 4: `trg_calcular_segundos`

### Función
```sql
CREATE OR REPLACE FUNCTION fn_calcular_segundos()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_fin IS NOT NULL THEN
        NEW.segundos := ROUND(EXTRACT(EPOCH FROM (NEW.fecha_fin - NEW.fecha_inicio)));
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
```

### Bloque
- Calcula `segundos` automáticamente cuando hay `fecha_fin`.

---

## 6. Triggers auxiliares (de `4_5_1 procedures.sql`)

### `trg_validar_fechas`
- Valida `fecha_fin >= fecha_inicio`.
- Calcula `segundos` si falta.

### `trg_estado_gpu`
- Valida `consumo_energetico >= 0`.
- Corrección aplicada: tabla cambiada de `experimento_gpu` a `consumo_gpu`.

---

## 7. Verificación

```sql
SELECT COUNT(*) AS triggers FROM pg_trigger WHERE NOT tgisinternal;
```

Resultado: **6 triggers** activos.

## Nota para el informe (LaTeX)
Explicar las reglas de negocio automatizadas, por qué se desactiva `trg_validar_respuesta` en carga masiva y cómo se integran con los procedimientos. Incluir el código de las funciones.