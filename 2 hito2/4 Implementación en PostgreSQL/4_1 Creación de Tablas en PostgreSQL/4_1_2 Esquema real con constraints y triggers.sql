-- 1. Creacion de tablas

CREATE TABLE organizacion (
    id_organizacion INTEGER,
    nombre VARCHAR(50),
    pais VARCHAR(50),
    tipo VARCHAR(20),
    fecha_fundacion DATE
);

CREATE TABLE modelo_llm (
    id_modelo INTEGER,
    nombre VARCHAR(100),
    version VARCHAR(50),
    arquitectura VARCHAR(100),
    tipo_modelo VARCHAR(50),
    num_param BIGINT,
    longitud_token INTEGER,
    tipo_token VARCHAR(50),
    estado VARCHAR(50),
    id_organizacion INTEGER,
    id_modelo_base INTEGER
);

CREATE TABLE dataset (
    id_dataset INTEGER,
    nombre VARCHAR(100),
    version VARCHAR(50),
    fase_uso VARCHAR(50),
    dominio VARCHAR(100),
    formato_datos VARCHAR(50),
    tamanio NUMERIC(12,3),
    num_registros BIGINT,
    licencia VARCHAR(50),
    fuente_origen VARCHAR(200)
);

CREATE TABLE experimento (
    id_run INTEGER,
    nombre VARCHAR(100),
    id_modelo INTEGER,
    tipo_entrenamiento VARCHAR(50),
    optimizador VARCHAR(50),
    precision_calculo VARCHAR(50),
    num_epocas INTEGER,
    tam_batch INTEGER,
    tasa_aprendizaje NUMERIC(10,8),
    estado_ejecucion VARCHAR(50),
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    segundos BIGINT,
    loss_final NUMERIC(10,6)
);

CREATE TABLE gpu (
    id_gpu INTEGER,
    modelo_gpu VARCHAR(100),
    fabricante VARCHAR(100),
    proveedor_cloud VARCHAR(100),
    memoria_vram INTEGER,
    num_nucleos INTEGER,
    costo_por_hora NUMERIC(10,4)
);

CREATE TABLE benchmark (
    id_benchmark INTEGER,
    nombre VARCHAR(100),
    version VARCHAR(50),
    categoria VARCHAR(100),
    metodo VARCHAR(100),
    num_items INTEGER,
    descripcion  TEXT
);

CREATE TABLE evaluacion (
    id_evaluacion INTEGER,
    id_modelo INTEGER,
    id_benchmark INTEGER,
    id_organizacion_evaluadora INTEGER,
    fecha_evaluacion DATE,
    resultado_metrica NUMERIC(10,4)
);

CREATE TABLE item_benchmark (
    id_item INTEGER,
    id_benchmark INTEGER,
    prompt_pregunta TEXT,
    respuesta_esperada TEXT
);

CREATE TABLE respuesta_modelo (
    id_respuesta INTEGER,
    id_evaluacion INTEGER,
    id_item INTEGER,
    output_generado TEXT,
    es_correcta BOOLEAN,
    tokens_output INTEGER,
    latencia NUMERIC(10,4)
);

CREATE TABLE experimento_dataset (
    id_run INTEGER,
    id_dataset INTEGER
);

CREATE TABLE consumo_gpu (
    id_run INTEGER,
    id_gpu INTEGER,
    horas_uso NUMERIC(10,2),
    consumo_energetico NUMERIC(10,2),
    cantidad_unidades  INTEGER
);


-- Key constraints

-- Organizacion
ALTER TABLE organizacion ADD CONSTRAINT pk_organizacion PRIMARY KEY (id_organizacion);

-- Modelo LLM
ALTER TABLE modelo_llm ADD CONSTRAINT pk_modelo_ll PRIMARY KEY (id_modelo);
ALTER TABLE modelo_llm ADD CONSTRAINT fk_modelo_llm_organizacion
    FOREIGN KEY (id_organizacion) REFERENCES organizacion (id_organizacion);
ALTER TABLE modelo_llm ADD CONSTRAINT fk_modelo_llm_modelo_base
    FOREIGN KEY (id_modelo_base)  REFERENCES modelo_llm (id_modelo);
	
-- Dataset
ALTER TABLE dataset ADD CONSTRAINT pk_dataset PRIMARY KEY (id_dataset);

-- Experimento
ALTER TABLE experimento ADD CONSTRAINT pk_experimento PRIMARY KEY (id_run);
ALTER TABLE experimento ADD CONSTRAINT fk_experimento_modelo
    FOREIGN KEY (id_modelo) REFERENCES modelo_llm (id_modelo);
	
-- GPU
ALTER TABLE gpu ADD CONSTRAINT pk_gpu PRIMARY KEY (id_gpu);

-- Benchmark
ALTER TABLE benchmark ADD CONSTRAINT pk_benchmark PRIMARY KEY (id_benchmark);

-- Evaluacion
ALTER TABLE evaluacion ADD CONSTRAINT pk_evaluacion PRIMARY KEY (id_evaluacion);
ALTER TABLE evaluacion ADD CONSTRAINT fk_evaluacion_modelo
    FOREIGN KEY (id_modelo) REFERENCES modelo_llm (id_modelo);
ALTER TABLE evaluacion ADD CONSTRAINT fk_evaluacion_benchmark
    FOREIGN KEY (id_benchmark) REFERENCES benchmark (id_benchmark);
ALTER TABLE evaluacion ADD CONSTRAINT fk_evaluacion_organizacion
    FOREIGN KEY (id_organizacion_evaluadora) REFERENCES organizacion (id_organizacion);
	
-- Item_benchmark
ALTER TABLE item_benchmark ADD CONSTRAINT pk_item_benchmark PRIMARY KEY (id_item);
ALTER TABLE item_benchmark ADD CONSTRAINT fk_item_benchmark_benchmark
    FOREIGN KEY (id_benchmark) REFERENCES benchmark (id_benchmark);
	
-- Respuesta modelo
ALTER TABLE respuesta_modelo ADD CONSTRAINT pk_respuesta_modelo PRIMARY KEY (id_respuesta);
ALTER TABLE respuesta_modelo ADD CONSTRAINT fk_respuesta_modelo_evaluacion
    FOREIGN KEY (id_evaluacion) REFERENCES evaluacion (id_evaluacion) ON DELETE CASCADE;
ALTER TABLE respuesta_modelo ADD CONSTRAINT fk_respuesta_modelo_item
    FOREIGN KEY (id_item) REFERENCES item_benchmark (id_item);

-- Experimento dataset
ALTER TABLE experimento_dataset ADD CONSTRAINT pk_experimento_dataset PRIMARY KEY (id_run, id_dataset);
ALTER TABLE experimento_dataset ADD CONSTRAINT fk_experimento_dataset_run
    FOREIGN KEY (id_run) REFERENCES experimento (id_run) ON DELETE CASCADE;
ALTER TABLE experimento_dataset ADD CONSTRAINT fk_experimento_dataset_dataset
    FOREIGN KEY (id_dataset) REFERENCES dataset (id_dataset);
	
-- Consumo GPU
ALTER TABLE consumo_gpu ADD CONSTRAINT pk_consumo_gpu PRIMARY KEY (id_run, id_gpu);
ALTER TABLE consumo_gpu ADD CONSTRAINT fk_consumo_gpu_run
    FOREIGN KEY (id_run) REFERENCES experimento (id_run) ON DELETE CASCADE;
ALTER TABLE consumo_gpu ADD CONSTRAINT fk_consumo_gpu_gpu
    FOREIGN KEY (id_gpu) REFERENCES gpu (id_gpu);
	
-- 2.2 Claves unicas (llaves candidatas)
ALTER TABLE organizacion ADD CONSTRAINT uq_organizacion_nombre
    UNIQUE (nombre);
ALTER TABLE modelo_llm   ADD CONSTRAINT uq_modelo_llm_nombre_version
    UNIQUE (nombre, version);
ALTER TABLE dataset      ADD CONSTRAINT uq_dataset_nombre_version_fase
    UNIQUE (nombre, version, fase_uso);
ALTER TABLE benchmark    ADD CONSTRAINT uq_benchmark_nombre_version
    UNIQUE (nombre, version);


-- Not null constraints

ALTER TABLE organizacion ALTER COLUMN nombre SET NOT NULL;
ALTER TABLE organizacion ALTER COLUMN pais SET NOT NULL;
ALTER TABLE organizacion ALTER COLUMN tipo SET NOT NULL;
ALTER TABLE organizacion ALTER COLUMN fecha_fundacion SET NOT NULL;

ALTER TABLE modelo_llm ALTER COLUMN nombre SET NOT NULL;
ALTER TABLE modelo_llm ALTER COLUMN version SET NOT NULL;
ALTER TABLE modelo_llm ALTER COLUMN arquitectura SET NOT NULL;
ALTER TABLE modelo_llm ALTER COLUMN tipo_modelo SET NOT NULL;
ALTER TABLE modelo_llm ALTER COLUMN num_param SET NOT NULL;
ALTER TABLE modelo_llm ALTER COLUMN longitud_token SET NOT NULL;
ALTER TABLE modelo_llm ALTER COLUMN tipo_token SET NOT NULL;
ALTER TABLE modelo_llm ALTER COLUMN estado SET NOT NULL;
ALTER TABLE modelo_llm ALTER COLUMN id_organizacion SET NOT NULL;

ALTER TABLE dataset ALTER COLUMN nombre SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN version SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN fase_uso SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN dominio SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN formato_datos SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN tamanio SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN num_registros SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN licencia SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN fuente_origen SET NOT NULL;

ALTER TABLE experimento ALTER COLUMN nombre SET NOT NULL;
ALTER TABLE experimento ALTER COLUMN id_modelo SET NOT NULL;
ALTER TABLE experimento ALTER COLUMN tipo_entrenamiento SET NOT NULL;
ALTER TABLE experimento ALTER COLUMN optimizador SET NOT NULL;
ALTER TABLE experimento ALTER COLUMN precision_calculo SET NOT NULL;
ALTER TABLE experimento ALTER COLUMN num_epocas SET NOT NULL;
ALTER TABLE experimento ALTER COLUMN tam_batch SET NOT NULL;
ALTER TABLE experimento ALTER COLUMN tasa_aprendizaje SET NOT NULL;
ALTER TABLE experimento ALTER COLUMN estado_ejecucion SET NOT NULL;
ALTER TABLE experimento ALTER COLUMN fecha_inicio SET NOT NULL;

ALTER TABLE gpu ALTER COLUMN modelo_gpu SET NOT NULL;
ALTER TABLE gpu ALTER COLUMN fabricante SET NOT NULL;
ALTER TABLE gpu ALTER COLUMN memoria_vram SET NOT NULL;
ALTER TABLE gpu ALTER COLUMN num_nucleos SET NOT NULL;
ALTER TABLE gpu ALTER COLUMN costo_por_hora SET NOT NULL;

ALTER TABLE benchmark ALTER COLUMN nombre SET NOT NULL;
ALTER TABLE benchmark ALTER COLUMN version SET NOT NULL;
ALTER TABLE benchmark ALTER COLUMN categoria SET NOT NULL;
ALTER TABLE benchmark ALTER COLUMN metodo SET NOT NULL;
ALTER TABLE benchmark ALTER COLUMN num_items SET NOT NULL;

ALTER TABLE evaluacion ALTER COLUMN id_modelo SET NOT NULL;
ALTER TABLE evaluacion ALTER COLUMN id_benchmark SET NOT NULL;
ALTER TABLE evaluacion ALTER COLUMN id_organizacion_evaluadora SET NOT NULL;
ALTER TABLE evaluacion ALTER COLUMN fecha_evaluacion SET NOT NULL;
ALTER TABLE evaluacion ALTER COLUMN resultado_metrica SET NOT NULL;

ALTER TABLE item_benchmark ALTER COLUMN id_benchmark SET NOT NULL;
ALTER TABLE item_benchmark ALTER COLUMN prompt_pregunta SET NOT NULL;
ALTER TABLE item_benchmark ALTER COLUMN respuesta_esperada SET NOT NULL;

ALTER TABLE respuesta_modelo ALTER COLUMN id_evaluacion SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN id_item SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN output_generado SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN es_correcta SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN tokens_output SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN latencia SET NOT NULL;

ALTER TABLE consumo_gpu ALTER COLUMN horas_uso SET NOT NULL;
ALTER TABLE consumo_gpu ALTER COLUMN consumo_energetico SET NOT NULL;
ALTER TABLE consumo_gpu ALTER COLUMN cantidad_unidades SET NOT NULL;

-- 3.1 Identificadores autogenerados (requieren la columna ya NOT NULL por ser PK).
ALTER TABLE organizacion ALTER COLUMN id_organizacion ADD GENERATED BY DEFAULT AS IDENTITY;
ALTER TABLE modelo_llm ALTER COLUMN id_modelo ADD GENERATED BY DEFAULT AS IDENTITY;
ALTER TABLE dataset ALTER COLUMN id_dataset ADD GENERATED BY DEFAULT AS IDENTITY;
ALTER TABLE experimento ALTER COLUMN id_run ADD GENERATED BY DEFAULT AS IDENTITY;
ALTER TABLE gpu ALTER COLUMN id_gpu ADD GENERATED BY DEFAULT AS IDENTITY;
ALTER TABLE benchmark ALTER COLUMN id_benchmark ADD GENERATED BY DEFAULT AS IDENTITY;
ALTER TABLE evaluacion ALTER COLUMN id_evaluacion ADD GENERATED BY DEFAULT AS IDENTITY;
ALTER TABLE item_benchmark ALTER COLUMN id_item ADD GENERATED BY DEFAULT AS IDENTITY;
ALTER TABLE respuesta_modelo ALTER COLUMN id_respuesta ADD GENERATED BY DEFAULT AS IDENTITY;

-- Otros Constraints

-- Valor por defecto
ALTER TABLE consumo_gpu ALTER COLUMN cantidad_unidades SET DEFAULT 1;

-- Organizacion
ALTER TABLE organizacion ADD CONSTRAINT chk_organizacion_tipo
    CHECK (tipo IN ('Creador', 'Evaluador', 'Ambos'));

-- Modelo_LLM
ALTER TABLE modelo_llm ADD CONSTRAINT chk_modelo_llm_num_param
    CHECK (num_param > 0);
ALTER TABLE modelo_llm ADD CONSTRAINT chk_modelo_llm_longitud_token
    CHECK (longitud_token > 0);
ALTER TABLE modelo_llm ADD CONSTRAINT chk_modelo_llm_estado
    CHECK (estado IN ('Activo', 'Inactivo', 'En Pruebas', 'Obsoleto'));
ALTER TABLE modelo_llm ADD CONSTRAINT chk_modelo_llm_no_autobase
    CHECK (id_modelo_base IS NULL OR id_modelo_base <> id_modelo);

-- Dataset
ALTER TABLE dataset ADD CONSTRAINT chk_dataset_fase_uso
    CHECK (fase_uso IN ('Entrenamiento', 'Validación', 'Prueba', 'Fine-tuning'));
ALTER TABLE dataset ADD CONSTRAINT chk_dataset_tamanio
    CHECK (tamanio > 0);
ALTER TABLE dataset ADD CONSTRAINT chk_dataset_num_registros
    CHECK (num_registros > 0);

-- Experimento
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_tipo_entrenamiento
    CHECK (tipo_entrenamiento IN ('Preentrenamiento', 'Fine-tuning', 'RLHF', 'Destilación'));
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_precision
    CHECK (precision_calculo IN ('FP32', 'FP16', 'BF16', 'INT8'));
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_estado
    CHECK (estado_ejecucion IN ('En ejecución', 'Finalizado', 'Error', 'Cancelado'));
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_num_epocas
    CHECK (num_epocas > 0);
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_tam_batch
    CHECK (tam_batch > 0);
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_tasa_aprendizaje
    CHECK (tasa_aprendizaje > 0);
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_segundos
    CHECK (segundos >= 0);
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_loss_final
    CHECK (loss_final >= 0);
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_fechas
    CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio);
-- un run en ejecucion no tiene fecha_fin; cualquier otro estado si
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_estado_fecha_fin
    CHECK ((estado_ejecucion = 'En ejecución' AND fecha_fin IS NULL)
        OR (estado_ejecucion <> 'En ejecución' AND fecha_fin IS NOT NULL));
ALTER TABLE experimento ADD CONSTRAINT chk_experimento_segundos_fin
    CHECK (segundos IS NULL OR fecha_fin IS NOT NULL);

-- GPU
ALTER TABLE gpu ADD CONSTRAINT chk_gpu_memoria_vram   CHECK (memoria_vram > 0);
ALTER TABLE gpu ADD CONSTRAINT chk_gpu_num_nucleos    CHECK (num_nucleos > 0);
ALTER TABLE gpu ADD CONSTRAINT chk_gpu_costo_por_hora CHECK (costo_por_hora >= 0);

-- Benchmark
ALTER TABLE benchmark ADD CONSTRAINT chk_benchmark_num_items
    CHECK (num_items > 0);

-- Evaluacion
ALTER TABLE evaluacion ADD CONSTRAINT chk_evaluacion_resultado
    CHECK (resultado_metrica >= 0);

-- Respuesta_Modelo (sin UNIQUE(id_evaluacion,id_item): regla 2.3.9 del Hito 1)
ALTER TABLE respuesta_modelo ADD CONSTRAINT chk_respuesta_tokens_output
    CHECK (tokens_output >= 0);
ALTER TABLE respuesta_modelo ADD CONSTRAINT chk_respuesta_latencia
    CHECK (latencia >= 0);

-- Consumo_GPU
ALTER TABLE consumo_gpu ADD CONSTRAINT chk_consumo_gpu_horas
    CHECK (horas_uso > 0);
ALTER TABLE consumo_gpu ADD CONSTRAINT chk_consumo_gpu_energia
    CHECK (consumo_energetico >= 0);
ALTER TABLE consumo_gpu ADD CONSTRAINT chk_consumo_gpu_unidades
    CHECK (cantidad_unidades > 0);

-- Comentarios del catalogo (unidades y semantica)
COMMENT ON COLUMN dataset.tamanio                IS 'Tamano del dataset en GB';
COMMENT ON COLUMN gpu.memoria_vram               IS 'Memoria VRAM en GB';
COMMENT ON COLUMN gpu.costo_por_hora             IS 'Costo en USD por hora de uso';
COMMENT ON COLUMN gpu.proveedor_cloud            IS 'NULL cuando el hardware es propio';
COMMENT ON COLUMN modelo_llm.longitud_token      IS 'Ventana de contexto maxima en tokens';
COMMENT ON COLUMN modelo_llm.id_modelo_base      IS 'Modelo del que deriva (NULL si es modelo base)';
COMMENT ON COLUMN experimento.segundos           IS 'Duracion del run en segundos; la calcula el trigger a partir de fecha_fin - fecha_inicio';
COMMENT ON COLUMN consumo_gpu.consumo_energetico IS 'Consumo energetico estimado de esta asignacion, en kWh';
COMMENT ON COLUMN respuesta_modelo.latencia      IS 'Latencia de la respuesta en segundos';


-- Triggers

CREATE OR REPLACE FUNCTION fn_validar_modelo_llm()
RETURNS TRIGGER AS
$$
DECLARE
    v_tipo   organizacion.tipo%TYPE;
    v_actual INTEGER;
BEGIN
    SELECT tipo INTO v_tipo FROM organizacion WHERE id_organizacion = NEW.id_organizacion;
    IF v_tipo = 'Evaluador' THEN
        RAISE EXCEPTION 'La organizacion % es solo Evaluador y no puede crear modelos', NEW.id_organizacion
            USING ERRCODE = '23514', CONSTRAINT = 'trg_modelo_organizacion_creadora';
    END IF;

    v_actual := NEW.id_modelo_base;
    WHILE v_actual IS NOT NULL LOOP
        IF v_actual = NEW.id_modelo THEN
            RAISE EXCEPTION 'El modelo % formaria un ciclo de modelos base', NEW.id_modelo
                USING ERRCODE = '23514', CONSTRAINT = 'trg_modelo_sin_ciclos';
        END IF;
        SELECT id_modelo_base INTO v_actual FROM modelo_llm WHERE id_modelo = v_actual;
    END LOOP;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_modelo_llm
    BEFORE INSERT OR UPDATE OF id_organizacion, id_modelo_base ON modelo_llm
    FOR EACH ROW EXECUTE FUNCTION fn_validar_modelo_llm();

-- 5.2 La organizacion evaluadora debe ser Evaluador o Ambos.
CREATE OR REPLACE FUNCTION fn_validar_evaluacion()
RETURNS TRIGGER AS
$$
DECLARE
    v_tipo organizacion.tipo%TYPE;
BEGIN
    SELECT tipo INTO v_tipo FROM organizacion WHERE id_organizacion = NEW.id_organizacion_evaluadora;
    IF v_tipo = 'Creador' THEN
        RAISE EXCEPTION 'La organizacion % es solo Creador y no puede evaluar', NEW.id_organizacion_evaluadora
            USING ERRCODE = '23514', CONSTRAINT = 'trg_evaluacion_organizacion_evaluadora';
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_evaluacion
    BEFORE INSERT OR UPDATE OF id_organizacion_evaluadora ON evaluacion
    FOR EACH ROW EXECUTE FUNCTION fn_validar_evaluacion();

-- 5.3 El item respondido debe pertenecer al benchmark de la evaluacion.
--     (Es el trigger mas costoso en la carga masiva: dos lecturas por PK.
--      Para cargar 1M de filas puede desactivarse y validarse despues:
--      ALTER TABLE respuesta_modelo DISABLE TRIGGER trg_validar_respuesta;)
CREATE OR REPLACE FUNCTION fn_validar_respuesta()
RETURNS TRIGGER AS
$$
DECLARE
    v_bench_item INTEGER;
    v_bench_eval INTEGER;
BEGIN
    SELECT id_benchmark INTO v_bench_item FROM item_benchmark WHERE id_item = NEW.id_item;
    SELECT id_benchmark INTO v_bench_eval FROM evaluacion WHERE id_evaluacion = NEW.id_evaluacion;
    IF v_bench_item IS NOT NULL AND v_bench_eval IS NOT NULL AND v_bench_item <> v_bench_eval THEN
        RAISE EXCEPTION 'El item % (benchmark %) no pertenece al benchmark % de la evaluacion %',
            NEW.id_item, v_bench_item, v_bench_eval, NEW.id_evaluacion
            USING ERRCODE = '23514', CONSTRAINT = 'trg_respuesta_item_del_benchmark';
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_respuesta
    BEFORE INSERT OR UPDATE OF id_evaluacion, id_item ON respuesta_modelo
    FOR EACH ROW EXECUTE FUNCTION fn_validar_respuesta();

-- 5.4 Atributo derivado: segundos = fecha_fin - fecha_inicio (cuando hay fecha_fin).
--     Tambien se dispara al modificar segundos, para impedir valores manuales erroneos.
CREATE OR REPLACE FUNCTION fn_calcular_segundos()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.fecha_fin IS NOT NULL THEN
        NEW.segundos := ROUND(EXTRACT(EPOCH FROM (NEW.fecha_fin - NEW.fecha_inicio)));
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calcular_segundos
    BEFORE INSERT OR UPDATE OF fecha_inicio, fecha_fin, segundos ON experimento
    FOR EACH ROW EXECUTE FUNCTION fn_calcular_segundos();