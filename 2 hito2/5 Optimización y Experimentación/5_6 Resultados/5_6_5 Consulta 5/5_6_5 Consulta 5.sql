-- Q5: Mejor resultado por benchmark y modelo (top 3)
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