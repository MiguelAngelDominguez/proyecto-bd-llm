-- =====================================================================
-- HITO 2 - Implementacion en PostgreSQL
-- Archivo: 01_ddl.sql
-- Crea la estructura de la base de datos (9 entidades + 3 intermedias)
-- =====================================================================

DROP TABLE IF EXISTS respuesta_modelo CASCADE;
DROP TABLE IF EXISTS item_benchmark CASCADE;
DROP TABLE IF EXISTS evaluacion CASCADE;
DROP TABLE IF EXISTS resultado_benchmark CASCADE;
DROP TABLE IF EXISTS experimento_gpu CASCADE;
DROP TABLE IF EXISTS experimento_dataset CASCADE;
DROP TABLE IF EXISTS benchmark CASCADE;
DROP TABLE IF EXISTS gpu CASCADE;
DROP TABLE IF EXISTS experimento CASCADE;
DROP TABLE IF EXISTS dataset CASCADE;
DROP TABLE IF EXISTS modelo_llm CASCADE;
DROP TABLE IF EXISTS organizacion CASCADE;

CREATE TABLE organizacion (
    id_organizacion     INTEGER PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    pais                VARCHAR(50)  NOT NULL,
    tipo                VARCHAR(20)  NOT NULL CHECK (tipo IN ('Creador','Evaluador','Ambos')),
    fecha_fundacion     DATE         NOT NULL
);

CREATE TABLE modelo_llm (
    id_modelo           INTEGER PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    version             VARCHAR(50)  NOT NULL,
    arquitectura        VARCHAR(100) NOT NULL,
    tipo_modelo         VARCHAR(50)  NOT NULL,
    num_param           BIGINT       NOT NULL CHECK (num_param > 0),
    longitud_token      INTEGER      NOT NULL CHECK (longitud_token > 0),
    tipo_token          VARCHAR(50)  NOT NULL,
    estado              VARCHAR(50)  NOT NULL CHECK (estado IN ('Activo','Inactivo','En Pruebas','Obsoleto')),
    id_organizacion     INTEGER      NOT NULL REFERENCES organizacion(id_organizacion),
    id_modelo_base      INTEGER      REFERENCES modelo_llm(id_modelo)
);

CREATE TABLE dataset (
    id_dataset          INTEGER PRIMARY KEY,
    id_modelo           INTEGER      NOT NULL REFERENCES modelo_llm(id_modelo),
    nombre              VARCHAR(100) NOT NULL,
    version             VARCHAR(50)  NOT NULL,
    fase_uso            VARCHAR(50)  NOT NULL CHECK (fase_uso IN ('Entrenamiento','Validacion','Prueba','Fine-tuning')),
    dominio             VARCHAR(100) NOT NULL,
    formato_datos       VARCHAR(50)  NOT NULL,
    tamanio             NUMERIC(10,2) NOT NULL CHECK (tamanio > 0),
    num_registros       BIGINT       NOT NULL CHECK (num_registros > 0),
    licencia            VARCHAR(50)  NOT NULL,
    fuente_origen       VARCHAR(200) NOT NULL
);

CREATE TABLE experimento (
    id_run              INTEGER PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    id_modelo           INTEGER      NOT NULL REFERENCES modelo_llm(id_modelo),
    tipo_entrenamiento  VARCHAR(50)  NOT NULL CHECK (tipo_entrenamiento IN ('Preentrenamiento','Fine-tuning','RLHF','Destilacion')),
    optimizador         VARCHAR(50)  NOT NULL,
    precision_calculo   VARCHAR(50)  NOT NULL CHECK (precision_calculo IN ('FP32','FP16','BF16','INT8')),
    num_epocas          INTEGER      NOT NULL CHECK (num_epocas > 0),
    tam_batch           INTEGER      NOT NULL CHECK (tam_batch > 0),
    tasa_aprendizaje    NUMERIC(10,8) NOT NULL CHECK (tasa_aprendizaje > 0),
    estado_ejecucion    VARCHAR(50)  NOT NULL CHECK (estado_ejecucion IN ('En ejecucion','Finalizado','Error','Cancelado')),
    fecha_inicio        TIMESTAMP    NOT NULL,
    fecha_fin           TIMESTAMP,
    segundos            BIGINT       CHECK (segundos >= 0),
    loss_final          NUMERIC(10,6) CHECK (loss_final >= 0)
);

CREATE TABLE gpu (
    id_gpu              INTEGER PRIMARY KEY,
    modelo_gpu          VARCHAR(100) NOT NULL,
    fabricante          VARCHAR(100) NOT NULL,
    proveedor_cloud     VARCHAR(100),
    memoria_vram        INTEGER      NOT NULL CHECK (memoria_vram > 0),
    num_nucleos         INTEGER      NOT NULL CHECK (num_nucleos > 0),
    costo_por_hora      NUMERIC(10,4) NOT NULL CHECK (costo_por_hora > 0)
);

CREATE TABLE benchmark (
    id_benchmark        INTEGER PRIMARY KEY,
    nombre              VARCHAR(100) NOT NULL,
    version             VARCHAR(50)  NOT NULL,
    categoria           VARCHAR(100) NOT NULL,
    metodo              VARCHAR(100) NOT NULL,
    num_items           INTEGER      NOT NULL CHECK (num_items > 0),
    descripcion         TEXT
);

CREATE TABLE evaluacion (
    id_evaluacion       INTEGER PRIMARY KEY,
    id_modelo           INTEGER      NOT NULL REFERENCES modelo_llm(id_modelo),
    id_benchmark        INTEGER      NOT NULL REFERENCES benchmark(id_benchmark),
    id_organizacion_evaluadora INTEGER NOT NULL REFERENCES organizacion(id_organizacion),
    fecha_evaluacion    DATE         NOT NULL,
    resultado_metrica   NUMERIC(10,4) NOT NULL CHECK (resultado_metrica >= 0)
);

CREATE TABLE item_benchmark (
    id_item             INTEGER PRIMARY KEY,
    id_benchmark        INTEGER      NOT NULL REFERENCES benchmark(id_benchmark),
    prompt_pregunta     TEXT         NOT NULL,
    respuesta_esperada  TEXT         NOT NULL
);

CREATE TABLE respuesta_modelo (
    id_respuesta        INTEGER PRIMARY KEY,
    id_evaluacion       INTEGER      NOT NULL REFERENCES evaluacion(id_evaluacion),
    id_item             INTEGER      NOT NULL REFERENCES item_benchmark(id_item),
    output_generado     TEXT         NOT NULL,
    es_correcta         BOOLEAN      NOT NULL,
    tokens_output       INTEGER      NOT NULL CHECK (tokens_output >= 0),
    latencia            NUMERIC(10,4) NOT NULL CHECK (latencia >= 0)
);

CREATE TABLE experimento_dataset (
    id_run              INTEGER NOT NULL REFERENCES experimento(id_run),
    id_dataset          INTEGER NOT NULL REFERENCES dataset(id_dataset),
    PRIMARY KEY (id_run, id_dataset)
);

CREATE TABLE experimento_gpu (
    id_run              INTEGER NOT NULL REFERENCES experimento(id_run),
    id_gpu              INTEGER NOT NULL REFERENCES gpu(id_gpu),
    horas_uso           NUMERIC(10,2) NOT NULL CHECK (horas_uso > 0),
    consumo_energetico  NUMERIC(10,2) NOT NULL CHECK (consumo_energetico >= 0),
    PRIMARY KEY (id_run, id_gpu)
);

CREATE TABLE resultado_benchmark (
    id_run              INTEGER NOT NULL REFERENCES experimento(id_run),
    id_benchmark        INTEGER NOT NULL REFERENCES benchmark(id_benchmark),
    valor               NUMERIC(10,4) NOT NULL CHECK (valor >= 0),
    metrica             NUMERIC(10,2) NOT NULL,
    fecha               DATE        NOT NULL,
    PRIMARY KEY (id_run, id_benchmark)
);
