# 4.5 Procedimientos Almacenados

## Objetivo
Documentar los procedimientos almacenados implementados, correspondiente al punto **4.5** de la rúbrica (Hito 2).

## Archivo de la carpeta
- `4_5_1 procedures.sql`: 2 procedimientos + 2 funciones/triggers auxiliares.

---

## 1. Pensamiento general
Los procedimientos automatizan el ciclo de vida de un experimento:
- `sp_registrar_experimento`: crea un run en estado "En ejecución".
- `sp_finalizar_experimento`: cierra el run con métricas finales.

---

## 2. Procedimiento 1: `sp_registrar_experimento`

### Firma
```sql
CREATE OR REPLACE PROCEDURE sp_registrar_experimento(
    p_id_run INTEGER, p_nombre VARCHAR, p_id_modelo INTEGER,
    p_tipo VARCHAR, p_opt VARCHAR, p_prec VARCHAR,
    p_epocas INTEGER, p_batch INTEGER, p_lr NUMERIC
)
```

### Cuerpo
```sql
BEGIN
    INSERT INTO experimento(id_run, nombre, id_modelo, tipo_entrenamiento, optimizador,
        precision_calculo, num_epocas, tam_batch, tasa_aprendizaje, estado_ejecucion, fecha_inicio)
    VALUES (p_id_run, p_nombre, p_id_modelo, p_tipo, p_opt, p_prec, p_epocas, p_batch, p_lr,
            'En ejecución', NOW());
END;
```

### Bloques
- **INSERT:** crea el registro con los parámetros del run.
- **`estado_ejecucion = 'En ejecución'`**: con tilde (CHECK del esquema).
- **`fecha_inicio = NOW()`**: timestamp de inicio.
- **`fecha_fin`, `segundos`, `loss_final`**: quedan NULL (run en ejecución).

### Corrección aplicada
- Se cambió `'En ejecucion'` → `'En ejecución'` (CHECK `chk_experimento_estado`).

---

## 3. Procedimiento 2: `sp_finalizar_experimento`

### Firma
```sql
CREATE OR REPLACE PROCEDURE sp_finalizar_experimento(
    p_id_run INTEGER, p_loss NUMERIC
)
```

### Cuerpo
```sql
BEGIN
    UPDATE experimento
    SET estado_ejecucion='Finalizado',
        fecha_fin=NOW(),
        segundos=EXTRACT(EPOCH FROM (NOW()-fecha_inicio))::BIGINT,
        loss_final=p_loss
    WHERE id_run=p_id_run;
END;
```

### Bloques
- **UPDATE:** cambia el estado a `Finalizado`.
- **`fecha_fin = NOW()`**: timestamp de fin.
- **`segundos`**: calculado por el trigger `trg_calcular_segundos` (también se asigna aquí).
- **`loss_final`**: métrica final del run.

### Dependencia
- Trigger `trg_calcular_segundos` (en `4_1_2`) recalcula `segundos` automáticamente.

---

## 4. Triggers auxiliares (en el mismo archivo)

### `fn_validar_fechas` / `trg_validar_fechas`
- Valida `fecha_fin >= fecha_inicio`.
- Calcula `segundos` si falta.

### `fn_estado_gpu` / `trg_estado_gpu`
- Valida `consumo_energetico >= 0`.
- Corrección aplicada: tabla cambiada de `experimento_gpu` a `consumo_gpu`.

---

## 5. Ejecución

```bash
psql -U postgres -d proyectobd -f "4 Implementación en PostgreSQL/4_5 Procedimientos Almacenados/4_5_1 procedures.sql"
```

## 6. Prueba realizada

```sql
CALL sp_registrar_experimento(9999,'Test proc',1,'Fine-tuning','AdamW','FP16',3,32,0.0001);
SELECT id_run, estado_ejecucion, fecha_fin FROM experimento WHERE id_run=9999;

CALL sp_finalizar_experimento(9999,1.234);
SELECT id_run, estado_ejecucion, segundos, loss_final FROM experimento WHERE id_run=9999;

DELETE FROM experimento WHERE id_run=9999;
```

Resultado:
- Registro: `estado_ejecucion = 'En ejecución'`, `fecha_fin = NULL`.
- Finalización: `estado_ejecucion = 'Finalizado'`, `segundos = 2`, `loss_final = 1.234000`.
- Limpieza: eliminado, conteo volvió a 1500.

## Nota para el informe (LaTeX)
Explicar los procedimientos como automatización del ciclo de vida del experimento y su integración con triggers. Incluir la prueba y sus resultados.