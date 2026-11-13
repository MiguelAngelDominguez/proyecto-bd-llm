-- Q3: Experimentos con menor loss final por modelo (top 3)
WITH ranked AS (
  SELECT e.id_run, m.nombre AS modelo, e.loss_final, e.num_epocas, e.tasa_aprendizaje,
         ROW_NUMBER() OVER (PARTITION BY e.id_modelo ORDER BY e.loss_final ASC NULLS LAST) AS rn
  FROM experimento e JOIN modelo_llm m ON m.id_modelo=e.id_modelo
  WHERE e.estado_ejecucion='Finalizado'
)
SELECT * FROM ranked WHERE rn <= 3;