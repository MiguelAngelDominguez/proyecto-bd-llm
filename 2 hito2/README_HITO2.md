# Hito 2 — Base de datos (proyectobd)

Estructura organizada según la rúbrica del curso.

## Estado por sección
- 4.1 Creación de tablas: ✅ OK (DDL + esquema real con constraints/triggers)
- 4.2 Carga de datos: ✅ OK (10.000 filas cargadas en proyectobd)
- 4.3 Simulación de datos faltantes: ✅ OK (nulos semánticos en CSV)
- 4.4 Views: ✅ OK (3 vistas creadas y probadas)
- 4.5 Procedimientos almacenados: ✅ OK (2 procedimientos creados y probados)
- 4.6 Triggers: ✅ OK (6 triggers activos)
- 5.1 Consultas SQL: ✅ OK (5 consultas adaptadas y probadas en 4 volúmenes)
- 5.2 Metodología: ✅ OK
- 5.3 Optimización de consultas: ✅ OK (índices + planes por consulta)
- 5.4 Plataforma de Pruebas: ✅ OK
- 5.5 Medición de tiempos: ✅ OK (sin/con índices en 4 volúmenes)
- 5.6 Resultados: ✅ OK (tablas por consulta)
- 5.7 Análisis y Discusión: ✅ OK
- 6 Conclusiones: Pendiente
- 7 Anexos (video): Pendiente (guía en `7_1/`)

## Cómo regenerar todo

### 1. Generar datos
```bash
cd "4 Implementación en PostgreSQL/4_2 Carga de datos"
python "4_2_2 generate_data.py" --total 10000 --outdir "../../data_out/csv"
python "4_2_2 generate_data.py" --total 1000 --outdir "../../data_out/dumps_1k/csv"
python "4_2_2 generate_data.py" --total 100000 --outdir "../../data_out/dumps_100k/csv"
python "4_2_2 generate_data.py" --total 1000000 --outdir "../../data_out/dumps_1M/csv"
```

### 2. Validar datos
```bash
cd "4 Implementación en PostgreSQL/4_3 Simulación de Datos Faltantes"
python "4_3_1 validate_data.py"
```

### 3. Crear BD y cargar esquema
```bash
psql -U postgres -c "CREATE DATABASE proyectobd;"
psql -U postgres -d proyectobd -f "4 Implementación en PostgreSQL/4_1 Creación de Tablas en PostgreSQL/4_1_2 Esquema real con constraints y triggers.sql"
```

### 4. Cargar datos
```bash
psql -U postgres -d proyectobd -f "4 Implementación en PostgreSQL/4_2 Carga de datos/4_2_1 load_proyectobd.sql"
```

### 5. Crear views y procedures
```bash
psql -U postgres -d proyectobd -f "4 Implementación en PostgreSQL/4_4 Views/4_4_1 views.sql"
psql -U postgres -d proyectobd -f "4 Implementación en PostgreSQL/4_5 Procedimientos Almacenados/4_5_1 procedures.sql"
```

### 6. Ejecutar consultas
```bash
psql -U postgres -d proyectobd -f "5 Optimización y Experimentación/5_1 Consultas SQL para el experimento/5_1_2 Implementación de consultas en SQL/5_1_2_1 queries.sql"
```

### 7. Crear índices y medir
```bash
psql -U postgres -d proyectobd -f "5 Optimización y Experimentación/5_3 Optimización de consultas/5_3_0 indices.sql"
psql -U postgres -d proyectobd -f "5 Optimización y Experimentación/5_5 Medición de tiempos/5_5_2 Con índices/measure_with_indexes.sql"
psql -U postgres -d proyectobd -f "5 Optimización y Experimentación/5_3 Optimización de consultas/5_3_0 drop_indexes.sql"
psql -U postgres -d proyectobd -f "5 Optimización y Experimentación/5_5 Medición de tiempos/5_5_1 Sin índices/measure_no_indexes.sql"
```

## Notas
- Los archivos `.csv` y los dumps (`.sql`) **no se suben al repositorio** (se regeneran con los scripts).
- El generador usa `random.seed(42)`, por lo que los datos son **reproducibles** en cualquier máquina.
- La contraseña de PostgreSQL en los ejemplos es `admin` (ajustar según tu configuración).
- Para otros volúmenes (1k/100k/1M), repetir los pasos 3–7 con las BDs correspondientes (`proyectobd_1k`, `proyectobd_100k`, `proyectobd_1m`).