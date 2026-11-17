-- =====================================================================
-- HITO 2 - Procedimientos almacenados (esquema corregido)
-- =====================================================================

CREATE OR REPLACE PROCEDURE sp_registrar_experimento(
    p_id_run INTEGER, p_nombre VARCHAR, p_id_modelo INTEGER,
    p_tipo VARCHAR, p_opt VARCHAR, p_prec VARCHAR,
    p_epocas INTEGER, p_batch INTEGER, p_lr NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO experimento(id_run, nombre, id_modelo, tipo_entrenamiento, optimizador,
        precision_calculo, num_epocas, tam_batch, tasa_aprendizaje, estado_ejecucion, fecha_inicio)
    VALUES (p_id_run, p_nombre, p_id_modelo, p_tipo, p_opt, p_prec, p_epocas, p_batch, p_lr,
            'En ejecución', NOW());
END;
$$;

CREATE OR REPLACE PROCEDURE sp_finalizar_experimento(
    p_id_run INTEGER, p_loss NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE experimento
    SET estado_ejecucion = 'Finalizado',
        fecha_fin = NOW(),
        loss_final = p_loss
    WHERE id_run = p_id_run;
END;
$$;

-- Trigger auxiliar para consumo_gpu
CREATE OR REPLACE FUNCTION fn_estado_gpu()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.consumo_energetico < 0 THEN
        RAISE EXCEPTION 'consumo_energetico invalido';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_estado_gpu ON consumo_gpu;
CREATE TRIGGER trg_estado_gpu
BEFORE INSERT OR UPDATE ON consumo_gpu
FOR EACH ROW EXECUTE FUNCTION fn_estado_gpu();