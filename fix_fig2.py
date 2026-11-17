p = r"D:\.Drive\UTEC\Ciclo 03\Base de Datos 1\Proyecto_!\Proyecto_BD.tex"
s = open(p, encoding='utf-8').read()

# 1. Remove misplaced narrative from landscape figure
bad = "\\**Analisis de resultados:** solo Q1 se beneficia claramente de los indices (~2-3x en 100k/1M). Q2-Q5 no mejoran porque son agregaciones sobre toda la tabla (Seq Scan mas eficiente). El grafico muestra la tendencia lineal del tiempo vs. volumen.\n\n"
i = s.find(bad)
print("found bad:", i)
if i != -1:
    s = s.replace(bad, "", 1)

# 2. Fix image path
old_path = "\\includegraphics[width=0.9\\textwidth]{chart_tiempos.png}"
new_path = "\\includegraphics[width=0.9\\textwidth]{2 hito2/5 Optimización y Experimentación/5_6 Resultados/chart_tiempos.png}"
assert old_path in s, "old path not found"
s = s.replace(old_path, new_path, 1)

# 3. Insert narrative before the chart figure
needle = "chart_tiempos.png"
i = s.find(needle)
assert i != -1
j = s.rfind("\\begin{figure}[H]", 0, i)
narr = "\\textbf{Análisis de resultados:} solo Q1 se beneficia claramente de los índices (~2-3x en 100k/1M). Q2–Q5 no mejoran porque son agregaciones sobre toda la tabla (Seq Scan más eficiente). El gráfico muestra la tendencia lineal del tiempo vs. volumen.\n\n"
if "Análisis de resultados: solo Q1" not in s:
    s = s[:j] + narr + s[j:]

open(p, 'w', encoding='utf-8').write(s)
print("done")