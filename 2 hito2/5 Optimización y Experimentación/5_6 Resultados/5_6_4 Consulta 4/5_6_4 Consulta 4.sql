-- Q4: Consumo total de horas GPU y costo por experimento
SELECT e.id_run, m.nombre AS modelo, SUM(cg.horas_uso) AS horas_totales,
       SUM(cg.horas_uso*g.costo_por_hora) AS costo_usd,
       SUM(cg.consumo_energetico) AS kwh
FROM experimento e
JOIN modelo_llm m ON m.id_modelo=e.id_modelo
JOIN consumo_gpu cg ON cg.id_run=e.id_run
JOIN gpu g ON g.id_gpu=cg.id_gpu
GROUP BY e.id_run, m.nombre
ORDER BY costo_usd DESC;