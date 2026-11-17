-- Creacion de tablas

CREATE TABLE IF NOT EXISTS organizacion (
    id_organizacion INTEGER,
    nombre VARCHAR(50),
    pais VARCHAR(50),
    tipo VARCHAR(20),
    fecha_fundacion DATE
);

CREATE TABLE IF NOT EXISTS modelo_llm (
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

CREATE TABLE IF NOT EXISTS dataset (
    id_dataset INTEGER,
    nombre VARCHAR(100),
    version VARCHAR(50),
    dominio VARCHAR(100),
    formato_datos VARCHAR(50),
    tamanio NUMERIC(12,3),
    num_registros BIGINT,
    licencias VARCHAR(50),
    fuente_origen VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS experimento (
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
    loss_final NUMERIC(10,6)
);

CREATE TABLE IF NOT EXISTS gpu (
    id_gpu INTEGER,
    modelo_gpu VARCHAR(100),
    fabricante VARCHAR(100),
    proveedor_cloud VARCHAR(100),
    memoria_vram INTEGER,
    num_nucleos INTEGER,
    costo_por_hora NUMERIC(10,4)
);

CREATE TABLE IF NOT EXISTS benchmark (
    id_benchmark INTEGER,
    nombre VARCHAR(100),
    version VARCHAR(50),
    categoria VARCHAR(100),
    metodo VARCHAR(100),
    num_items INTEGER,
    descripcion TEXT,
    autor VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS evaluacion (
    id_evaluacion INTEGER,
    id_modelo INTEGER,
    id_benchmark INTEGER,
    id_organizacion_evaluadora INTEGER,
    fecha_evaluacion DATE,
    resultado_metrica NUMERIC(10,4)
);

CREATE TABLE IF NOT EXISTS item_benchmark (
    id_benchmark INTEGER,
    id_item INTEGER,
    prompt_pregunta TEXT,
    respuesta_esperada TEXT
);

CREATE TABLE IF NOT EXISTS respuesta_modelo (
    id_respuesta INTEGER,
    id_evaluacion INTEGER,
    id_benchmark INTEGER,
    id_item INTEGER,
    output_generado TEXT,
    es_correcta BOOLEAN,
    tokens_output INTEGER,
    latencia NUMERIC(10,4)
);

CREATE TABLE IF NOT EXISTS experimento_dataset (
    id_run INTEGER,
    id_dataset INTEGER,
    fase_uso VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS consumo_gpu (
    id_run INTEGER,
    id_gpu INTEGER,
    horas_uso NUMERIC(10,2),
    consumo_energetico NUMERIC(10,2),
    cantidad_unidades INTEGER DEFAULT 1
);


-- Key constraints

-- Organizacion
ALTER TABLE organizacion ADD CONSTRAINT pk_organizacion_id PRIMARY KEY ( id_organizacion );

-- ModeloLLM
ALTER TABLE modelo_llm ADD CONSTRAINT pk_modelo_llm_id PRIMARY KEY ( id_modelo );
ALTER TABLE modelo_llm ADD CONSTRAINT fk_modelo_llm_organizacion FOREIGN KEY ( id_organizacion ) REFERENCES organizacion ( id_organizacion );
ALTER TABLE modelo_llm ADD CONSTRAINT fk_modelo_llm_modelo_base FOREIGN KEY ( id_modelo_base ) REFERENCES modelo_llm ( id_modelo );

-- Dataset
ALTER TABLE dataset ADD CONSTRAINT pk_dataset_id PRIMARY KEY ( id_dataset );

-- Experimento
ALTER TABLE experimento ADD CONSTRAINT pk_experimento_id_run PRIMARY KEY ( id_run );
ALTER TABLE experimento ADD CONSTRAINT fk_experimento_modelo_llm FOREIGN KEY ( id_modelo ) REFERENCES modelo_llm ( id_modelo );

-- GPU
ALTER TABLE gpu ADD CONSTRAINT pk_gpu_id PRIMARY KEY ( id_gpu );

-- Benchmark
ALTER TABLE benchmark ADD CONSTRAINT pk_benchmark_id PRIMARY KEY ( id_benchmark );

-- Evaluacion
ALTER TABLE evaluacion ADD CONSTRAINT pk_evaluacion_id PRIMARY KEY ( id_evaluacion );
ALTER TABLE evaluacion ADD CONSTRAINT fk_evaluacion_modelo_llm FOREIGN KEY ( id_modelo ) REFERENCES modelo_llm ( id_modelo );
ALTER TABLE evaluacion ADD CONSTRAINT fk_evaluacion_benchmark FOREIGN KEY ( id_benchmark ) REFERENCES benchmark ( id_benchmark );
ALTER TABLE evaluacion ADD CONSTRAINT fk_evaluacion_organizacion FOREIGN KEY ( id_organizacion_evaluadora ) REFERENCES organizacion ( id_organizacion );
-- Clave candidata que permite la FK compuesta de respuesta_modelo
ALTER TABLE evaluacion ADD CONSTRAINT uq_evaluacion_id_benchmark UNIQUE ( id_evaluacion, id_benchmark );

-- ItemBenchmark (entidad debil de Benchmark)
ALTER TABLE item_benchmark ADD CONSTRAINT pk_item_benchmark_id PRIMARY KEY ( id_benchmark, id_item );
ALTER TABLE item_benchmark ADD CONSTRAINT fk_item_benchmark_benchmark FOREIGN KEY ( id_benchmark ) REFERENCES benchmark ( id_benchmark ) ON DELETE CASCADE;

-- RespuestaModelo
ALTER TABLE respuesta_modelo ADD CONSTRAINT pk_respuesta_modelo_id PRIMARY KEY ( id_respuesta );
ALTER TABLE respuesta_modelo ADD CONSTRAINT fk_respuesta_evaluacion FOREIGN KEY ( id_evaluacion, id_benchmark ) REFERENCES evaluacion ( id_evaluacion, id_benchmark ) ON DELETE CASCADE;
ALTER TABLE respuesta_modelo ADD CONSTRAINT fk_respuesta_item_benchmark FOREIGN KEY ( id_benchmark, id_item ) REFERENCES item_benchmark ( id_benchmark, id_item );

-- Experimento_Dataset (relacion utiliza)
ALTER TABLE experimento_dataset ADD CONSTRAINT pk_experimento_dataset PRIMARY KEY ( id_run, id_dataset, fase_uso );
ALTER TABLE experimento_dataset ADD CONSTRAINT fk_experimento_dataset_experimento FOREIGN KEY ( id_run ) REFERENCES experimento ( id_run ) ON DELETE CASCADE;
ALTER TABLE experimento_dataset ADD CONSTRAINT fk_experimento_dataset_dataset FOREIGN KEY ( id_dataset ) REFERENCES dataset ( id_dataset );

-- Consumo_GPU (relacion consume)
ALTER TABLE consumo_gpu ADD CONSTRAINT pk_consumo_gpu PRIMARY KEY ( id_run, id_gpu );
ALTER TABLE consumo_gpu ADD CONSTRAINT fk_consumo_gpu_experimento FOREIGN KEY ( id_run ) REFERENCES experimento ( id_run ) ON DELETE CASCADE;
ALTER TABLE consumo_gpu ADD CONSTRAINT fk_consumo_gpu_gpu FOREIGN KEY ( id_gpu ) REFERENCES gpu ( id_gpu );


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
ALTER TABLE dataset ALTER COLUMN dominio SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN formato_datos SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN tamanio SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN num_registros SET NOT NULL;
ALTER TABLE dataset ALTER COLUMN licencias SET NOT NULL;
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

ALTER TABLE item_benchmark ALTER COLUMN prompt_pregunta SET NOT NULL;
ALTER TABLE item_benchmark ALTER COLUMN respuesta_esperada SET NOT NULL;

ALTER TABLE respuesta_modelo ALTER COLUMN id_evaluacion SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN id_benchmark SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN id_item SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN output_generado SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN es_correcta SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN tokens_output SET NOT NULL;
ALTER TABLE respuesta_modelo ALTER COLUMN latencia SET NOT NULL;

ALTER TABLE consumo_gpu ALTER COLUMN horas_uso SET NOT NULL;
ALTER TABLE consumo_gpu ALTER COLUMN consumo_energetico SET NOT NULL;
ALTER TABLE consumo_gpu ALTER COLUMN cantidad_unidades SET NOT NULL;


-- Otros constraints

-- Organizacion
ALTER TABLE organizacion ADD CONSTRAINT uq_organizacion_nombre UNIQUE ( nombre );
ALTER TABLE organizacion ADD CONSTRAINT ck_organizacion_tipo CHECK ( tipo IN ('Creador', 'Evaluador', 'Ambos') );

-- ModeloLLM
ALTER TABLE modelo_llm ADD CONSTRAINT uq_modelo_llm_nombre_version UNIQUE ( nombre, version );
ALTER TABLE modelo_llm ADD CONSTRAINT ck_modelo_llm_num_param CHECK ( num_param > 0 );
ALTER TABLE modelo_llm ADD CONSTRAINT ck_modelo_llm_longitud_token CHECK ( longitud_token > 0 );
ALTER TABLE modelo_llm ADD CONSTRAINT ck_modelo_llm_estado CHECK ( estado IN ('Activo', 'Inactivo', 'En Pruebas', 'Obsoleto') );
ALTER TABLE modelo_llm ADD CONSTRAINT ck_modelo_llm_base_distinto CHECK ( id_modelo_base IS NULL OR id_modelo_base <> id_modelo );

-- Dataset
ALTER TABLE dataset ADD CONSTRAINT uq_dataset_nombre_version UNIQUE ( nombre, version );
ALTER TABLE dataset ADD CONSTRAINT ck_dataset_tamanio CHECK ( tamanio > 0 );
ALTER TABLE dataset ADD CONSTRAINT ck_dataset_num_registros CHECK ( num_registros > 0 );

-- Experimento
ALTER TABLE experimento ADD CONSTRAINT ck_experimento_tipo_entrenamiento CHECK ( tipo_entrenamiento IN ('Preentrenamiento', 'Fine-tuning', 'RLHF', 'Destilación') );
ALTER TABLE experimento ADD CONSTRAINT ck_experimento_precision CHECK ( precision_calculo IN ('FP32', 'FP16', 'BF16', 'INT8') );
ALTER TABLE experimento ADD CONSTRAINT ck_experimento_num_epocas CHECK ( num_epocas > 0 );
ALTER TABLE experimento ADD CONSTRAINT ck_experimento_tam_batch CHECK ( tam_batch > 0 );
ALTER TABLE experimento ADD CONSTRAINT ck_experimento_tasa_aprendizaje CHECK ( tasa_aprendizaje > 0 );
ALTER TABLE experimento ADD CONSTRAINT ck_experimento_estado CHECK ( estado_ejecucion IN ('En ejecución', 'Finalizado', 'Error', 'Cancelado') );
ALTER TABLE experimento ADD CONSTRAINT ck_experimento_loss_final CHECK ( loss_final >= 0 );
ALTER TABLE experimento ADD CONSTRAINT ck_experimento_fechas CHECK ( fecha_fin IS NULL OR fecha_fin >= fecha_inicio );

-- GPU
ALTER TABLE gpu ADD CONSTRAINT ck_gpu_memoria_vram CHECK ( memoria_vram > 0 );
ALTER TABLE gpu ADD CONSTRAINT ck_gpu_num_nucleos CHECK ( num_nucleos > 0 );
ALTER TABLE gpu ADD CONSTRAINT ck_gpu_costo_por_hora CHECK ( costo_por_hora >= 0 );

-- Benchmark
ALTER TABLE benchmark ADD CONSTRAINT uq_benchmark_nombre_version UNIQUE ( nombre, version );
ALTER TABLE benchmark ADD CONSTRAINT ck_benchmark_num_items CHECK ( num_items > 0 );

-- Evaluacion
ALTER TABLE evaluacion ADD CONSTRAINT ck_evaluacion_resultado CHECK ( resultado_metrica >= 0 );

-- ItemBenchmark
ALTER TABLE item_benchmark ADD CONSTRAINT ck_item_benchmark_id_item CHECK ( id_item > 0 );

-- RespuestaModelo
ALTER TABLE respuesta_modelo ADD CONSTRAINT uq_respuesta_evaluacion_item UNIQUE ( id_evaluacion, id_item );
ALTER TABLE respuesta_modelo ADD CONSTRAINT ck_respuesta_tokens_output CHECK ( tokens_output >= 0 );
ALTER TABLE respuesta_modelo ADD CONSTRAINT ck_respuesta_latencia CHECK ( latencia >= 0 );

-- Experimento_Dataset
ALTER TABLE experimento_dataset ADD CONSTRAINT ck_experimento_dataset_fase CHECK ( fase_uso IN ('Entrenamiento', 'Validación', 'Prueba', 'Fine-tuning') );

-- Consumo_GPU
ALTER TABLE consumo_gpu ADD CONSTRAINT ck_consumo_gpu_horas CHECK ( horas_uso > 0 );
ALTER TABLE consumo_gpu ADD CONSTRAINT ck_consumo_gpu_energia CHECK ( consumo_energetico >= 0 );
ALTER TABLE consumo_gpu ADD CONSTRAINT ck_consumo_gpu_unidades CHECK ( cantidad_unidades > 0 );


-- Triggers (reglas de negocio no expresables con claves ni CHECK)

-- Una organizacion de tipo Evaluador no puede crear modelos
CREATE OR REPLACE FUNCTION fn_validar_organizacion_creadora ()
RETURNS TRIGGER AS
$$
BEGIN
    IF (SELECT tipo FROM organizacion WHERE id_organizacion = NEW.id_organizacion) = 'Evaluador' THEN
        RAISE EXCEPTION 'La organizacion % es de tipo Evaluador y no puede crear modelos',
            NEW.id_organizacion;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_organizacion_creadora
BEFORE INSERT OR UPDATE OF id_organizacion ON modelo_llm
FOR EACH ROW EXECUTE FUNCTION fn_validar_organizacion_creadora ();

-- Una organizacion de tipo Creador no puede aplicar evaluaciones
CREATE OR REPLACE FUNCTION fn_validar_organizacion_evaluadora ()
RETURNS TRIGGER AS
$$
BEGIN
    IF (SELECT tipo FROM organizacion WHERE id_organizacion = NEW.id_organizacion_evaluadora) = 'Creador' THEN
        RAISE EXCEPTION 'La organizacion % es de tipo Creador y no puede aplicar evaluaciones',
            NEW.id_organizacion_evaluadora;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_organizacion_evaluadora
BEFORE INSERT OR UPDATE OF id_organizacion_evaluadora ON evaluacion
FOR EACH ROW EXECUTE FUNCTION fn_validar_organizacion_evaluadora ();

-- La cadena de modelos base (relacion basado) no puede contener ciclos
CREATE OR REPLACE FUNCTION fn_validar_ciclo_modelo_base ()
RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.id_modelo_base IS NOT NULL AND EXISTS (
        WITH RECURSIVE ancestros AS (
            SELECT id_modelo, id_modelo_base
            FROM modelo_llm
            WHERE id_modelo = NEW.id_modelo_base
            UNION
            SELECT m.id_modelo, m.id_modelo_base
            FROM modelo_llm m JOIN ancestros a ON m.id_modelo = a.id_modelo_base
        )
        SELECT 1 FROM ancestros WHERE id_modelo = NEW.id_modelo
    ) THEN
        RAISE EXCEPTION 'El modelo base % genera un ciclo en la cadena de modelos',
            NEW.id_modelo_base;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_ciclo_modelo_base
BEFORE INSERT OR UPDATE OF id_modelo_base ON modelo_llm
FOR EACH ROW EXECUTE FUNCTION fn_validar_ciclo_modelo_base ();
