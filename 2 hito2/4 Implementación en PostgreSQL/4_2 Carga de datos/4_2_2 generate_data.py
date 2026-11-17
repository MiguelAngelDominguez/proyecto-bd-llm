import csv, random, os, datetime

import argparse
BASE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(BASE, "..", ".."))
SEED_MODEL = os.path.join(ROOT, "..", "1_Modelo_LLM.csv")
SEED_GPU = os.path.join(ROOT, "..", "3_Catalogo_GPU.csv")

parser = argparse.ArgumentParser()
parser.add_argument("--total", type=int, default=10000, help="Total de filas objetivo")
parser.add_argument("--outdir", type=str, default=os.path.join(ROOT, "data_out", "csv"), help="Directorio de salida")
args = parser.parse_args()

factor = args.total / 10000.0
N_MODEL = int(round(1500 * factor))
N_EVAL = int(round(750 * factor))
N_ITEM = max(100, int(round(100 * factor)))
N_RESP = int(round(1000 * factor))
N_RB = int(round(600 * factor))

OUT = args.outdir
os.makedirs(OUT, exist_ok=True)
os.makedirs(OUT, exist_ok=True)

random.seed(42)

def read_csv(path):
    with open(path, newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))

seed_models = read_csv(SEED_MODEL)
seed_gpus = read_csv(SEED_GPU)

# ---------- organizacion ----------
orgs_raw = []
seen = set()
for r in seed_models:
    o = r["organizacion_desarrolladora"].strip()
    if o and o not in seen:
        seen.add(o)
        orgs_raw.append(o)
# pad to 20
while len(orgs_raw) < 20:
    orgs_raw.append(f"Org Sintetica {len(orgs_raw)+1}")
orgs_raw = orgs_raw[:20]

org_rows = []
for i, name in enumerate(orgs_raw, start=1):
    org_rows.append({
        "id_organizacion": i,
        "nombre": name,
        "pais": random.choice(["United States","China","United Kingdom","France","Germany","Canada","Japan","South Korea","Israel","Singapore"]),
        "tipo": random.choice(["Creador","Evaluador","Ambos"]),
        "fecha_fundacion": f"{random.randint(1990,2022)}-{random.randint(1,12):02d}-{random.randint(1,28):02d}",
    })

# ---------- gpu ----------
gpu_rows = []
for i in range(1, 21):
    seed = seed_gpus[(i-1) % len(seed_gpus)]
    name = seed["modelo_hardware"]
    fabricante = seed["fabricante"] if seed["fabricante"] else random.choice(["NVIDIA","AMD","Google","Intel"])
    gpu_rows.append({
        "id_gpu": i,
        "modelo_gpu": name if i <= len(seed_gpus) else f"GPU Sintetica {i}",
        "fabricante": fabricante,
        "proveedor_cloud": seed["proveedor_cloud"] if random.random() > 0.3 else "",
        "memoria_vram": random.choice([16,24,40,48,80,96,128,144,192]),
        "num_nucleos": random.choice([3072,5120,6912,9216,10752,14592,16896,18432]),
        "costo_por_hora": round(random.uniform(0.5, 8.0), 4),
    })

# ---------- benchmark ----------
benchmarks = [
    ("MMLU","5.0","Knowledge","Multiple choice",5700,"Massive Multitask Language Understanding"),
    ("HellaSwag","1.0","Commonsense","Multiple choice",10042,"Commonsense reasoning"),
    ("ARC-Challenge","1.0","Reasoning","Multiple choice",1172,"AI2 Reasoning Challenge"),
    ("GSM8K","1.0","Math","Open-ended",1319,"Grade school math word problems"),
    ("HumanEval","1.0","Code","Code generation",164,"Python code synthesis"),
    ("TruthfulQA","1.0","Truthfulness","Multiple choice",817,"Truthfulness in QA"),
    ("WinoGrande","1.0","Commonsense","Multiple choice",1267,"Winograd schema challenge"),
    ("MATH","1.0","Math","Open-ended",5000,"Competition mathematics"),
    ("GPQA","1.0","Science","Multiple choice",448,"Graduate-level science QA"),
    ("BIG-Bench Hard","1.0","Reasoning","Mixed",6511,"Challenging BIG-Bench tasks"),
]
bench_rows = []
for i,(n,v,c,m,ni,d) in enumerate(benchmarks, start=1):
    bench_rows.append({
        "id_benchmark": i,
        "nombre": n,
        "version": v,
        "categoria": c,
        "metodo": m,
        "num_items": ni,
        "descripcion": d,
        "autor": random.choice([o["nombre"] for o in org_rows]),
    })

# ---------- item_benchmark (10 por benchmark = 100) ----------
item_rows = []
iid = 1
items_per_bench = max(1, N_ITEM // len(bench_rows))
for b in bench_rows:
    for j in range(items_per_bench):
        item_rows.append({
            "id_item": iid,
            "id_benchmark": b["id_benchmark"],
            "prompt_pregunta": f"Pregunta de ejemplo {j+1} para {b['nombre']}",
            "respuesta_esperada": f"Respuesta de referencia {j+1}",
        })
        iid += 1

# ---------- modelo_llm (1500) ----------
model_rows = []
for i in range(1, N_MODEL+1):
    seed = random.choice(seed_models)
    creator_orgs = [o["id_organizacion"] for o in org_rows if o["tipo"] in ("Creador","Ambos")]
    org_id = random.choice(creator_orgs)
    base = None
    if random.random() < 0.3 and i > 1:
        base = random.randint(1, i-1)
    arch = random.choice(["Transformer","MoE","SSM","Hybrid","Encoder-Decoder"])
    tipo = random.choice(["Base","Chat","Instruct","Code","Multimodal"])
    params_raw = seed.get("numero_parametros_billon","")
    try:
        params_b = float(params_raw) if params_raw not in ("", None) else random.uniform(0.1, 70.0)
    except:
        params_b = random.uniform(0.1, 70.0)
    num_param = int(params_b * 1e9) if params_b and params_b > 0 else random.randint(100_000_000, 70_000_000_000)
    model_rows.append({
        "id_modelo": i,
        "nombre": f"{seed['nombre']} (var {i})",
        "version": f"v{random.randint(1,4)}.{random.randint(0,9)}",
        "arquitectura": arch,
        "tipo_modelo": tipo,
        "num_param": num_param,
        "longitud_token": random.choice([2048,4096,8192,32768,128000]),
        "tipo_token": random.choice(["BPE","SentencePiece","Tiktoken"]),
        "estado": random.choice(["Activo","Inactivo","En Pruebas","Obsoleto"]),
        "id_organizacion": org_id,
        "id_modelo_base": base if base is not None else "",
    })

# ---------- dataset (1500) ----------
dataset_rows = []
for i in range(1, N_MODEL+1):
    m = model_rows[i-1]
    seed = random.choice(seed_models)
    dominio = seed.get("dominio") or "Language"
    tokens = seed.get("tokens_totales","")
    try:
        toks = int(float(tokens)) if tokens not in ("", None) else random.randint(1_000_000, 10_000_000_000)
    except:
        toks = random.randint(1_000_000, 10_000_000_000)
    dataset_rows.append({
        "id_dataset": i,
        "nombre": f"Dataset {i}",
        "version": f"v{random.randint(1,3)}.{random.randint(0,9)}",
        "dominio": dominio,
        "formato_datos": random.choice(["Texto","JSON","Parquet","CSV"]),
        "tamanio": round(random.uniform(1.0, 500.0), 2),
        "num_registros": random.randint(1000, 10_000_000),
        "licencias": random.choice(["MIT","Apache-2.0","CC-BY-4.0","Propietaria","Desconocida"]),
        "fuente_origen": random.choice(["Hugging Face","Kaggle","Propio","Web scrape","Sintetico"]),
    })

# ---------- experimento (1500) ----------
exp_rows = []
for i in range(1, N_MODEL+1):
    m = model_rows[i-1]
    estado = random.choice(["Finalizado","Finalizado","Finalizado","En ejecución","Error","Cancelado"])
    fecha_inicio = datetime.datetime(2020,1,1) + datetime.timedelta(days=random.randint(0,1800))
    fecha_fin = ""
    loss = ""
    if estado != "En ejecución":
        dur = random.randint(3600, 30*86400)
        fecha_fin = fecha_inicio + datetime.timedelta(seconds=dur)
        loss = round(random.uniform(0.5, 5.0), 6) if estado == "Finalizado" else round(random.uniform(0.5, 5.0), 6)
    exp_rows.append({
        "id_run": i,
        "nombre": f"Run {i}",
        "id_modelo": m["id_modelo"],
        "tipo_entrenamiento": random.choice(["Preentrenamiento","Fine-tuning","RLHF","Destilación"]),
        "optimizador": random.choice(["AdamW","Adam","Lion","Adafactor","SGD"]),
        "precision_calculo": random.choice(["FP32","FP16","BF16","INT8"]),
        "num_epocas": random.randint(1, 20),
        "tam_batch": random.choice([8,16,32,64,128,256]),
        "tasa_aprendizaje": f"{random.uniform(1e-5, 1e-3):.8f}",
        "estado_ejecucion": estado,
        "fecha_inicio": fecha_inicio.strftime("%Y-%m-%d %H:%M:%S"),
        "fecha_fin": fecha_fin.strftime("%Y-%m-%d %H:%M:%S") if fecha_fin else "",
        "loss_final": loss,
    })

# ---------- experimento_dataset (1500) ----------
ed_rows = [{"id_run": i, "id_dataset": i, "fase_uso": random.choice(["Entrenamiento","Validación","Prueba","Fine-tuning"])} for i in range(1, N_MODEL+1)]

# ---------- experimento_gpu (1500) ----------
eg_rows = []
for i in range(1, N_MODEL+1):
    g = random.choice(gpu_rows)
    horas = round(random.uniform(1.0, 500.0), 2)
    eg_rows.append({
        "id_run": i,
        "id_gpu": g["id_gpu"],
        "horas_uso": horas,
        "consumo_energetico": round(horas * random.uniform(0.2, 0.7), 2),
    })

# ---------- evaluacion (750) ----------
eval_rows = []
eid = 1
for _ in range(N_EVAL):
    m = random.choice(model_rows)
    b = random.choice(bench_rows)
    eval_orgs = [o for o in org_rows if o["tipo"] in ("Evaluador","Ambos")]
    org = random.choice(eval_orgs)
    eval_rows.append({
        "id_evaluacion": eid,
        "id_modelo": m["id_modelo"],
        "id_benchmark": b["id_benchmark"],
        "id_organizacion_evaluadora": org["id_organizacion"],
        "fecha_evaluacion": f"202{random.randint(3,5)}-{random.randint(1,12):02d}-{random.randint(1,28):02d}",
        "resultado_metrica": round(random.uniform(0.0, 1.0), 4),
    })
    eid += 1

# ---------- respuesta_modelo (1000) ----------
# map benchmark -> items
items_by_bench = {}
for it in item_rows:
    items_by_bench.setdefault(it["id_benchmark"], []).append(it)

resp_rows = []
rid = 1
seen_resp = set()
while len(resp_rows) < N_RESP:
    ev = random.choice(eval_rows)
    bench_id = ev["id_benchmark"]
    if bench_id not in items_by_bench or not items_by_bench[bench_id]:
        continue
    it = random.choice(items_by_bench[bench_id])
    key = (ev["id_evaluacion"], it["id_item"])
    if key in seen_resp:
        continue
    seen_resp.add(key)
    resp_rows.append({
        "id_respuesta": rid,
        "id_evaluacion": ev["id_evaluacion"],
        "id_benchmark": bench_id,
        "id_item": it["id_item"],
        "output_generado": f"Respuesta generada {rid}",
        "es_correcta": random.choice([True, False]),
        "tokens_output": random.randint(10, 500),
        "latencia": round(random.uniform(0.1, 5.0), 4),
    })
    rid += 1

# ---------- resultado_benchmark (600) ----------
rb_rows = []
seen_rb = set()
while len(rb_rows) < N_RB:
    e = random.choice(exp_rows)
    b = random.choice(bench_rows)
    key = (e["id_run"], b["id_benchmark"])
    if key in seen_rb:
        continue
    seen_rb.add(key)
    rb_rows.append({
        "id_run": e["id_run"],
        "id_benchmark": b["id_benchmark"],
        "valor": round(random.uniform(0.0, 100.0), 4),
        "metrica": round(random.uniform(0.0, 1.0), 2),
        "fecha": f"202{random.randint(3,5)}-{random.randint(1,12):02d}-{random.randint(1,28):02d}",
    })

# ---------- write CSVs ----------
def write_csv(name, rows, fieldnames):
    path = os.path.join(OUT, name)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, extrasaction='ignore')
        w.writeheader()
        for r in rows:
            w.writerow(r)
    print(f"{name}: {len(rows)} rows")

write_csv("organizacion.csv", org_rows, ["id_organizacion","nombre","pais","tipo","fecha_fundacion"])
write_csv("modelo_llm.csv", model_rows, ["id_modelo","nombre","version","arquitectura","tipo_modelo","num_param","longitud_token","tipo_token","estado","id_organizacion","id_modelo_base"])
write_csv("dataset.csv", dataset_rows, ["id_dataset","nombre","version","dominio","formato_datos","tamanio","num_registros","licencias","fuente_origen"])
write_csv("experimento.csv", exp_rows, ["id_run","nombre","id_modelo","tipo_entrenamiento","optimizador","precision_calculo","num_epocas","tam_batch","tasa_aprendizaje","estado_ejecucion","fecha_inicio","fecha_fin","loss_final"])
write_csv("gpu.csv", gpu_rows, ["id_gpu","modelo_gpu","fabricante","proveedor_cloud","memoria_vram","num_nucleos","costo_por_hora"])
write_csv("benchmark.csv", bench_rows, ["id_benchmark","nombre","version","categoria","metodo","num_items","descripcion","autor"])
write_csv("evaluacion.csv", eval_rows, ["id_evaluacion","id_modelo","id_benchmark","id_organizacion_evaluadora","fecha_evaluacion","resultado_metrica"])
write_csv("item_benchmark.csv", item_rows, ["id_benchmark","id_item","prompt_pregunta","respuesta_esperada"])
write_csv("respuesta_modelo.csv", resp_rows, ["id_respuesta","id_evaluacion","id_benchmark","id_item","output_generado","es_correcta","tokens_output","latencia"])
write_csv("experimento_dataset.csv", ed_rows, ["id_run","id_dataset","fase_uso"])
write_csv("experimento_gpu.csv", eg_rows, ["id_run","id_gpu","horas_uso","consumo_energetico"])
write_csv("resultado_benchmark.csv", rb_rows, ["id_run","id_benchmark","valor","metrica","fecha"])

# total
total = (len(org_rows)+len(model_rows)+len(dataset_rows)+len(exp_rows)+len(gpu_rows)+len(bench_rows)+
         len(eval_rows)+len(item_rows)+len(resp_rows)+len(ed_rows)+len(eg_rows)+len(rb_rows))
print("TOTAL ROWS:", total)