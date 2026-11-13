-- =====================================================================
-- HITO 2 - Indices para optimizacion (Seccion 5.3)
-- =====================================================================

-- Indices para FKs y consultas criticas

-- Q1: mayor num_param por arquitectura
CREATE INDEX IF NOT EXISTS idx_modelo_llm_arq_numparam
    ON modelo_llm (arquitectura, num_param DESC);

-- Q2: datasets por dominio
CREATE INDEX IF NOT EXISTS idx_dataset_dominio
    ON dataset (dominio);

CREATE INDEX IF NOT EXISTS idx_exp_dataset_dataset
    ON experimento_dataset (id_dataset);

-- Q3: experimentos con menor loss por modelo
CREATE INDEX IF NOT EXISTS idx_experimento_modelo_loss
    ON experimento (id_modelo, loss_final)
    WHERE estado_ejecucion = 'Finalizado';

-- Q4: consumo por experimento y GPU
CREATE INDEX IF NOT EXISTS idx_consumo_gpu_run
    ON consumo_gpu (id_run);

CREATE INDEX IF NOT EXISTS idx_consumo_gpu_gpu
    ON consumo_gpu (id_gpu);

CREATE INDEX IF NOT EXISTS idx_experimento_modelo
    ON experimento (id_modelo);

-- Q5: mejor resultado por benchmark
CREATE INDEX IF NOT EXISTS idx_evaluacion_benchmark_score
    ON evaluacion (id_benchmark, resultado_metrica DESC);

CREATE INDEX IF NOT EXISTS idx_evaluacion_modelo
    ON evaluacion (id_modelo);

-- Indices para FKs generales
CREATE INDEX IF NOT EXISTS idx_modelo_llm_org
    ON modelo_llm (id_organizacion);

CREATE INDEX IF NOT EXISTS idx_dataset_id
    ON dataset (id_dataset);

CREATE INDEX IF NOT EXISTS idx_experimento_id_modelo
    ON experimento (id_modelo);

-- Para eliminar indices (prueba sin indices):
-- DROP INDEX IF EXISTS idx_modelo_llm_arq_numparam;
-- DROP INDEX IF EXISTS idx_dataset_dominio;
-- DROP INDEX IF EXISTS idx_exp_dataset_dataset;
-- DROP INDEX IF EXISTS idx_experimento_modelo_loss;
-- DROP INDEX IF EXISTS idx_consumo_gpu_run;
-- DROP INDEX IF EXISTS idx_consumo_gpu_gpu;
-- DROP INDEX IF EXISTS idx_experimento_modelo;
-- DROP INDEX IF EXISTS idx_evaluacion_benchmark_score;
-- DROP INDEX IF EXISTS idx_evaluacion_modelo;
-- DROP INDEX IF EXISTS idx_modelo_llm_org;
-- DROP INDEX IF EXISTS idx_dataset_id;
-- DROP INDEX IF EXISTS idx_experimento_id_modelo;