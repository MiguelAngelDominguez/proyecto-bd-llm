EXPLAIN
WITH ranked AS (
  SELECT nombre, arquitectura, num_param,
         RANK() OVER (PARTITION BY arquitectura ORDER BY num_param DESC) AS rnk
  FROM modelo_llm
)
SELECT arquitectura, nombre, num_param
FROM ranked WHERE rnk = 1;

EXPLAIN
SELECT d.dominio, COUNT(ed.id_run) AS num_experimentos, AVG(d.num_registros) AS avg_registros
FROM dataset d
JOIN experimento_dataset ed ON ed.id_dataset = d.id_dataset
GROUP BY d.dominio
ORDER BY num_experimentos DESC
LIMIT 5;

EXPLAIN
WITH ranked AS (
  SELECT e.id_run, m.nombre AS modelo, e.loss_final, e.num_epocas, e.tasa_aprendizaje,
         ROW_NUMBER() OVER (PARTITION BY e.id_modelo ORDER BY e.loss_final ASC NULLS LAST) AS rn
  FROM experimento e JOIN modelo_llm m ON m.id_modelo=e.id_modelo
  WHERE e.estado_ejecucion='Finalizado'
)
SELECT * FROM ranked WHERE rn <= 3;

EXPLAIN
SELECT e.id_run, m.nombre AS modelo, SUM(cg.horas_uso) AS horas_totales,
       SUM(cg.horas_uso*g.costo_por_hora) AS costo_usd,
       SUM(cg.consumo_energetico) AS kwh
FROM experimento e
JOIN modelo_llm m ON m.id_modelo=e.id_modelo
JOIN consumo_gpu cg ON cg.id_run=e.id_run
JOIN gpu g ON g.id_gpu=cg.id_gpu
GROUP BY e.id_run, m.nombre
ORDER BY costo_usd DESC;

EXPLAIN
WITH ranked AS (
  SELECT b.nombre AS benchmark, m.nombre AS modelo, e.resultado_metrica AS valor,
         e.fecha_evaluacion AS fecha,
         RANK() OVER (PARTITION BY b.id_benchmark ORDER BY e.resultado_metrica DESC) AS rnk
  FROM evaluacion e
  JOIN benchmark b ON b.id_benchmark=e.id_benchmark
  JOIN modelo_llm m ON m.id_modelo=e.id_modelo
)
SELECT benchmark, modelo, valor, fecha, rnk
FROM ranked WHERE rnk <= 3;