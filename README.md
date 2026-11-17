# Proyecto BD I — Entrenamiento de Modelos LLM / IA Generativa

Proyecto del curso **CS2041 Base de Datos I** (UTEC, Ciclo 2026-2).  
Tema: Entrenamiento de Modelos LLM — Modelos LLM, Datasets de entrenamiento, Experimentos/runs, Consumo de GPUs y Evaluaciones de benchmark.

---

## Requisitos

- **Python** 3.10+ (solo stdlib: `csv`, `random`, `os`, `datetime`, `argparse`)
- **PostgreSQL** 18 (`psql` en PATH o ruta completa)
- **Git** (opcional, para clonar)

No se requiere `pandas` ni ninguna librería externa.

---

## Estructura del proyecto

```
Proyecto_!/
├── 2 hito2/                          # Todo el Hito 2
│   ├── 4 Implementación en la base de datos/
│   │   ├── 4_1 Creación de Tablas en PostgreSQL/
│   │   ├── 4_2 Carga de datos/
│   │   ├── 4_3 Simulación de Datos Faltantes/
│   │   ├── 4_4 Views/
│   │   ├── 4_5 Procedimientos Almacenados/
│   │   └── 4_6 Triggers/
│   ├── 5 Optimización y Experimentación/
│   │   ├── 5_1 Consultas SQL para el experimento/
│   │   ├── 5_2 Metodología del experimento/
│   │   ├── 5_3 Optimización de consultas/
│   │   ├── 5_4 Plataforma de Pruebas/
│   │   ├── 5_5 Medición de tiempos/
│   │   ├── 5_6 Resultados/
│   │   └── 5_7 Análisis y Discusión/
│   ├── 6 Conclusiones/
│   ├── 7 Anexos/7_1 Video experimentación 1M/
│   ├── data_out/                     # CSVs y dumps (generados, no subidos)
│   └── README_HITO2.md
├── Proyecto_BD.tex                   # Informe LaTeX (Hito 1)
├── subContexteo/                     # Documentos de contexto
├── test/                             # Scripts de auditoría
├── view_csv.py                       # Visualizador de CSVs
└── README.md                         # Este archivo
```

---

## Pasos para reproducir todo

### 1. Generar datos

```bash
cd "2 hito2/4 Implementación en PostgreSQL/4_2 Carga de datos"

# 10k (BD principal)
python "4_2_2 generate_data.py" --total 10000 --outdir "../../data_out/csv"

# 1k
python "4_2_2 generate_data.py" --total 1000 --outdir "../../data_out/dumps_1k/csv"

# 100k
python "4_2_2 generate_data.py" --total 100000 --outdir "../../data_out/dumps_100k/csv"

# 1M
python "4_2_2 generate_data.py" --total 1000000 --outdir "../../data_out/dumps_1M/csv"
```

> **Nota:** El generador usa `random.seed(42)`, por lo que los CSVs son **deterministas** (mismo resultado en cualquier máquina).

### 2. Validar datos

```bash
cd "2 hito2/4 Implementación en PostgreSQL/4_3 Simulación de Datos Faltantes"
python "4_3_1 validate_data.py"
```

### 3. Crear BD y cargar esquema

```bash
# Crear BD
psql -U postgres -c "CREATE DATABASE proyectobd;"

# Cargar esquema (tablas + constraints + triggers)
psql -U postgres -d proyectobd -f "2 hito2/4 Implementación en PostgreSQL/4_1 Creación de Tablas en PostgreSQL/4_1_3 Esquema corregido (según LaTeX).sql"
```

### 4. Cargar datos

```bash
psql -U postgres -d proyectobd -f "2 hito2/4 Implementación en PostgreSQL/4_2 Carga de datos/4_2_1 load_proyectobd.sql"
```

### 5. Crear views y procedures

```bash
psql -U postgres -d proyectobd -f "2 hito2/4 Implementación en PostgreSQL/4_4 Views/4_4_1 views.sql"
psql -U postgres -d proyectobd -f "2 hito2/4 Implementación en PostgreSQL/4_5 Procedimientos Almacenados/4_5_1 procedures.sql"
```

### 6. Ejecutar consultas

```bash
psql -U postgres -d proyectobd -f "2 hito2/5 Optimización y Experimentación/5_1 Consultas SQL para el experimento/5_1_2 Implementación de consultas en SQL/5_1_2_1 queries.sql"
```

### 7. Crear índices y medir

```bash
# Crear índices
psql -U postgres -d proyectobd -f "2 hito2/5 Optimización y Experimentación/5_3 Optimización de consultas/5_3_0 indices.sql"

# Medir con índices
psql -U postgres -d proyectobd -f "2 hito2/5 Optimización y Experimentación/5_5 Medición de tiempos/5_5_2 Con índices/measure_with_indexes.sql"

# Eliminar índices y medir sin índices
psql -U postgres -d proyectobd -f "2 hito2/5 Optimización y Experimentación/5_3 Optimización de consultas/5_3_0 drop_indexes.sql"
psql -U postgres -d proyectobd -f "2 hito2/5 Optimización y Experimentación/5_5 Medición de tiempos/5_5_1 Sin índices/measure_no_indexes.sql"
```

### 8. Para otros volúmenes (1k/100k/1M)
Repetir pasos 3–7 con las bases de datos `proyectobd_1k`, `proyectobd_100k`, `proyectobd_1m` y sus respectivos CSVs en `data_out/dumps_*/csv/`.

---

## Notas
- Los archivos `.csv` y los dumps (`.sql`) **no se suben al repositorio** (se regeneran con los scripts).
- El generador usa `random.seed(42)`, por lo que los datos son **reproducibles** en cualquier máquina.
- La contraseña de PostgreSQL en los ejemplos es `admin` (ajustar según tu configuración).