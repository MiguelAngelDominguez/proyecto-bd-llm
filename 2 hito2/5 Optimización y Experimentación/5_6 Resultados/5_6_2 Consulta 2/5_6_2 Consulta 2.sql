-- Q2: Datasets mas utilizados por dominio (top 5)
SELECT d.dominio, COUNT(ed.id_run) AS num_experimentos, AVG(d.num_registros) AS avg_registros
FROM dataset d
JOIN experimento_dataset ed ON ed.id_dataset = d.id_dataset
GROUP BY d.dominio
ORDER BY num_experimentos DESC
LIMIT 5;