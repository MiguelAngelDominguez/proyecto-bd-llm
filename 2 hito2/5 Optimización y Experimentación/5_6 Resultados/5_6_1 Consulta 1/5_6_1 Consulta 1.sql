-- Q1: Modelo con mayor numero de parametros por arquitectura
WITH ranked AS (
  SELECT nombre, arquitectura, num_param,
         RANK() OVER (PARTITION BY arquitectura ORDER BY num_param DESC) AS rnk
  FROM modelo_llm
)
SELECT arquitectura, nombre, num_param
FROM ranked WHERE rnk = 1;