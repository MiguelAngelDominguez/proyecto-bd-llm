-- =====================================================================
-- HITO 2 - Views de usuario
-- Archivo: 05_views.sql
-- =====================================================================

CREATE OR REPLACE VIEW v_modelo_resumen AS
SELECT m.id_modelo, m.nombre, m.arquitectura, m.num_param, m.estado,
       o.nombre AS organizacion, o.pais
FROM modelo_llm m
JOIN organizacion o ON o.id_organizacion = m.id_organizacion;

CREATE OR REPLACE VIEW v_consumo_por_experimento AS
SELECT e.id_run, e.nombre AS experimento, m.nombre AS modelo,
       COUNT(eg.id_gpu) AS num_gpus,
       SUM(eg.horas_uso) AS horas_totales,
       SUM(eg.horas_uso * g.costo_por_hora) AS costo_estimado_usd,
       SUM(eg.consumo_energetico) AS kwh_total
FROM experimento e
JOIN modelo_llm m ON m.id_modelo = e.id_modelo
LEFT JOIN consumo_gpu eg ON eg.id_run = e.id_run
LEFT JOIN gpu g ON g.id_gpu = eg.id_gpu
GROUP BY e.id_run, e.nombre, m.nombre;

CREATE OR REPLACE VIEW v_mejor_benchmark AS
SELECT b.nombre AS benchmark, m.nombre AS modelo,
       e.resultado_metrica AS valor, e.fecha_evaluacion AS fecha
FROM evaluacion e
JOIN benchmark b ON b.id_benchmark = e.id_benchmark
JOIN modelo_llm m ON m.id_modelo = e.id_modelo
WHERE (e.id_benchmark, e.resultado_metrica) IN (
    SELECT id_benchmark, MAX(resultado_metrica)
    FROM evaluacion
    GROUP BY id_benchmark
);
