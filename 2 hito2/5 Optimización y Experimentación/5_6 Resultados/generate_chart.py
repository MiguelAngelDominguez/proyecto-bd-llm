import csv, os
import matplotlib.pyplot as plt

base = os.path.dirname(os.path.abspath(__file__))
csv_path = os.path.join(base, "resultados_tiempos.csv")
out_path = os.path.join(base, "chart_tiempos.png")

volumes = []
data = {}
with open(csv_path, newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        vol = int(row["volumen"])
        q = row["consulta"]
        sin_t = float(row["sin_indices_ms"])
        con_t = float(row["con_indices_ms"])
        if vol not in volumes:
            volumes.append(vol)
        data.setdefault(q, {})[vol] = (sin_t, con_t)

volumes = sorted(set(volumes))
queries = sorted(data.keys())

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

for q in queries:
    vals = [data[q][v][0] for v in volumes]
    ax1.plot(volumes, vals, marker='o', label=q)
ax1.set_xscale('log')
ax1.set_xlabel('Volumen de datos (filas)')
ax1.set_ylabel('Tiempo de ejecución (ms)')
ax1.set_title('Sin índices')
ax1.legend()
ax1.grid(True, which='both', linestyle='--', alpha=0.5)

for q in queries:
    vals = [data[q][v][1] for v in volumes]
    ax2.plot(volumes, vals, marker='o', label=q)
ax2.set_xscale('log')
ax2.set_xlabel('Volumen de datos (filas)')
ax2.set_ylabel('Tiempo de ejecución (ms)')
ax2.set_title('Con índices')
ax2.legend()
ax2.grid(True, which='both', linestyle='--', alpha=0.5)

fig.suptitle('Comparación de tiempos de ejecución: 5 consultas vs. volumen de datos', fontsize=14)
plt.tight_layout()
plt.savefig(out_path, dpi=150)
print("Chart saved to", out_path)