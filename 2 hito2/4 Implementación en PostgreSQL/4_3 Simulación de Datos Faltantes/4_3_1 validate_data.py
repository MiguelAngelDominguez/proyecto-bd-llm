import csv, os, datetime

BASE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(BASE, "..", ".."))
D = os.path.join(ROOT, "data_out", "csv")

def read(name):
    with open(os.path.join(D, name), newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))

def ids(rows, col):
    return set(r[col] for r in rows)

org = read("organizacion.csv")
model = read("modelo_llm.csv")
dataset = read("dataset.csv")
exp = read("experimento.csv")
gpu = read("gpu.csv")
bench = read("benchmark.csv")
evalu = read("evaluacion.csv")
item = read("item_benchmark.csv")
resp = read("respuesta_modelo.csv")
ed = read("experimento_dataset.csv")
eg = read("experimento_gpu.csv")
rb = read("resultado_benchmark.csv")

errors = []
def check_pk(rows, col, label):
    vals = [r[col] for r in rows]
    if len(vals) != len(set(vals)):
        errors.append(f"PK duplicada en {label}.{col}")

def check_fk(rows, fk_col, parent_ids, label, parent_label):
    bad = [r[fk_col] for r in rows if r[fk_col] not in ("",) and r[fk_col] not in parent_ids]
    if bad:
        errors.append(f"FK invalida en {label}.{fk_col}: {len(bad)} (ej: {bad[:5]})")

# PKs simples
for rows,col,label in [(org,"id_organizacion","organizacion"),(model,"id_modelo","modelo_llm"),(dataset,"id_dataset","dataset"),
 (exp,"id_run","experimento"),(gpu,"id_gpu","gpu"),(bench,"id_benchmark","benchmark"),
 (evalu,"id_evaluacion","evaluacion"),(resp,"id_respuesta","respuesta_modelo")]:
    check_pk(rows,col,label)

# PKs compuestas
if len(set((r["id_benchmark"],r["id_item"]) for r in item)) != len(item):
    errors.append("PK compuesta duplicada en item_benchmark")
if len(set((r["id_run"],r["id_dataset"],r["fase_uso"]) for r in ed)) != len(ed):
    errors.append("PK compuesta duplicada en experimento_dataset")
if len(set((r["id_run"],r["id_gpu"]) for r in eg)) != len(eg):
    errors.append("PK compuesta duplicada en experimento_gpu")
if len(set((r["id_run"],r["id_benchmark"]) for r in rb)) != len(rb):
    errors.append("PK compuesta duplicada en resultado_benchmark")

org_ids = ids(org,"id_organizacion")
model_ids = ids(model,"id_modelo")
dataset_ids = ids(dataset,"id_dataset")
exp_ids = ids(exp,"id_run")
gpu_ids = ids(gpu,"id_gpu")
bench_ids = ids(bench,"id_benchmark")
eval_ids = ids(evalu,"id_evaluacion")
item_keys = set((r["id_benchmark"],r["id_item"]) for r in item)

check_fk(model,"id_organizacion",org_ids,"modelo_llm","organizacion")
check_fk(dataset,"id_dataset",dataset_ids,"dataset","dataset")  # trivial
check_fk(exp,"id_modelo",model_ids,"experimento","modelo_llm")
check_fk(ed,"id_run",exp_ids,"experimento_dataset","experimento")
check_fk(ed,"id_dataset",dataset_ids,"experimento_dataset","dataset")
check_fk(eg,"id_run",exp_ids,"experimento_gpu","experimento")
check_fk(eg,"id_gpu",gpu_ids,"experimento_gpu","gpu")
check_fk(evalu,"id_modelo",model_ids,"evaluacion","modelo_llm")
check_fk(evalu,"id_benchmark",bench_ids,"evaluacion","benchmark")
check_fk(evalu,"id_organizacion_evaluadora",org_ids,"evaluacion","organizacion")
check_fk(resp,"id_evaluacion",eval_ids,"respuesta_modelo","evaluacion")
check_fk(resp,"id_benchmark",bench_ids,"respuesta_modelo","benchmark")
# composite FK (id_benchmark, id_item) -> item_benchmark
bad_item = [(r["id_benchmark"],r["id_item"]) for r in resp if (r["id_benchmark"],r["id_item"]) not in item_keys]
if bad_item:
    errors.append(f"FK compuesta invalida en respuesta_modelo: {len(bad_item)}")
check_fk(rb,"id_run",exp_ids,"resultado_benchmark","experimento")
check_fk(rb,"id_benchmark",bench_ids,"resultado_benchmark","benchmark")
check_fk(item,"id_benchmark",bench_ids,"item_benchmark","benchmark")

# id_modelo_base optional
bad_base = [r["id_modelo_base"] for r in model if r["id_modelo_base"] not in ("",) and r["id_modelo_base"] not in model_ids]
if bad_base:
    errors.append(f"id_modelo_base invalido: {len(bad_base)}")

# UNIQUE (id_evaluacion, id_item) en respuesta_modelo
if len(set((r["id_evaluacion"],r["id_item"]) for r in resp)) != len(resp):
    errors.append("UNIQUE (id_evaluacion, id_item) violado en respuesta_modelo")

# UNIQUE (id_evaluacion, id_benchmark) en evaluacion (verificar no duplicados)
if len(set((r["id_evaluacion"],r["id_benchmark"]) for r in evalu)) != len(evalu):
    errors.append("UNIQUE (id_evaluacion, id_benchmark) violado en evaluacion")

# ranges
for r in model:
    if r["num_param"] and int(r["num_param"]) <= 0: errors.append("num_param <=0")
    if r["longitud_token"] and int(r["longitud_token"]) <= 0: errors.append("longitud_token <=0")
for r in gpu:
    if int(r["memoria_vram"]) <= 0: errors.append("memoria_vram <=0")
    if int(r["num_nucleos"]) <= 0: errors.append("num_nucleos <=0")
    if float(r["costo_por_hora"]) <= 0: errors.append("costo_por_hora <=0")
for r in bench:
    if int(r["num_items"]) <= 0: errors.append("num_items <=0")

# fechas
for r in exp:
    if r["fecha_fin"]:
        try:
            a = datetime.datetime.strptime(r["fecha_inicio"], "%Y-%m-%d %H:%M:%S")
            b = datetime.datetime.strptime(r["fecha_fin"], "%Y-%m-%d %H:%M:%S")
            if b < a: errors.append(f"fecha_fin < fecha_inicio en run {r['id_run']}")
        except Exception as e:
            errors.append(f"fecha invalida run {r['id_run']}: {e}")

print("=== VALIDACION ===")
print("Tablas:", {"org":len(org),"model":len(model),"dataset":len(dataset),"exp":len(exp),"gpu":len(gpu),"bench":len(bench),"eval":len(evalu),"item":len(item),"resp":len(resp),"ed":len(ed),"eg":len(eg),"rb":len(rb)})
print("Total:", len(org)+len(model)+len(dataset)+len(exp)+len(gpu)+len(bench)+len(evalu)+len(item)+len(resp)+len(ed)+len(eg)+len(rb))
if errors:
    print("ERRORES:", len(errors))
    for e in errors[:30]:
        print(" -", e)
else:
    print("Sin errores de integridad.")