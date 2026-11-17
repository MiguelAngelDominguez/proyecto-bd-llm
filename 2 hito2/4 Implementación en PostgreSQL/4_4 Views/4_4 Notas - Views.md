# 4.4 Views

## Objetivo
Documentar las vistas de usuario implementadas, correspondiente al punto **4.4** de la rúbrica (Hito 2).

## Archivo de la carpeta
- `4_4_1 views.sql`: 3 vistas.

---

## 1. Pensamiento general
Las vistas abstraen consultas frecuentes para investigadores/analistas:
- Resumen de modelos con su organización.
- Consumo de recursos por experimento.
- Mejor resultado por benchmark.

---

## 2. Vista 1: `v_modelo_resumen`

### Código
```sql
CREATE OR REPLACE VIEW v_modelo_resumen AS
SELECT m.id_modelo, m.nombre, m.arquitectura, m.num_param, m.estado,
       o.nombre AS organizacion, o.pais
FROM modelo_llm m
JOIN organizacion o ON o.id_organizacion = m.id_organizacion;
```

### Bloques
- **SELECT:** proyecta campos clave del modelo + organización.
- **FROM/JOIN:** une `modelo_llm` con `organizacion` por FK.
- **Uso:** listado rápido de modelos con su org creadora.

---

## 3. Vista 2: `v_consumo_por_experimento`

### Código
```sql
CREATE OR REPLACE VIEW v_consumo_por_experimento AS
SELECT e.id_run, e.nombre AS experimento, m.nombre AS modelo,
       COUNT(eg.id_gpu) AS num_gpus,
       SUM(eg.horas_uso) AS horas_totales,
       SUM(eg.horas_uso * g.costo_por_hora) AS costo_estimado_usd,
       SUM(eg.consumo_energetico) AS kwh_total
FROM experimento e
JOIN modelo_llm m ON m.id_modelo = e.id_modelo
LEFT JOIN consumo_gpu eg ON eg.id_run = e.id_run
LEFT JOIN gpu g ON g.id_gpu = eg.id_gpu
GROUP BY e.id_run, e.nombre, m.nombre;
```

### Bloques
- **FROM/JOIN:** une experimento → modelo (INNER).
- **LEFT JOIN consumo_gpu:** incluye experimentos sin GPU (num_gpus = 0).
- **LEFT JOIN gpu:** obtiene costo_por_hora para calcular costo.
- **GROUP BY:** agrega por experimento.
- **Agregaciones:**
  - `COUNT(eg.id_gpu)`: número de GPUs usadas.
  - `SUM(eg.horas_uso)`: horas totales.
  - `SUM(eg.horas_uso * g.costo_por_hora)`: costo estimado en USD.
  - `SUM(eg.consumo_energetico)`: kWh total.

### Corrección aplicada
- Se cambió `experimento_gpu` por `consumo_gpu` (nombre real en el esquema).

---

## 4. Vista 3: `v_mejor_benchmark`

### Código (corregido)
```sql
CREATE OR REPLACE VIEW v_mejor_benchmark AS
SELECT b.nombre AS benchmark, m.nombre AS modelo,
       e.resultado_metrica AS valor, e.fecha_evaluacion AS fecha
FROM evaluacion e
JOIN benchmark b ON b.id_benchmark = e.id_benchmark
JOIN modelo_llm m ON m.id_modelo = e.id_modelo
WHERE (e.id_benchmark, e.resultado_metrica) IN (
    SELECT id_benchmark, MAX(resultado_metrica)
    FROM evaluacion
    GROUP BY id_benchmark
);
```

### Bloques
- **FROM/JOIN:** une evaluacion → benchmark → modelo.
- **WHERE (subquery):** filtra solo las evaluaciones con el máximo `resultado_metrica` por benchmark.
- **Corrección aplicada:** se reescribió sobre `evaluacion` porque `resultado_benchmark` no existe en el esquema real.

---

## 5. Ejecución

```bash
psql -U postgres -d proyectobd -f "4 Implementación en PostgreSQL/4_4 Views/4_4_1 views.sql"
```

## 6. Verificación

```sql
SELECT viewname FROM pg_views WHERE schemaname = 'public' ORDER BY viewname;
```

Resultado esperado: `v_consumo_por_experimento`, `v_mejor_benchmark`, `v_modelo_resumen`.

## Nota para el informe (LaTeX)
Explicar el propósito de cada vista (resumen de modelos, consumo por experimento, mejor resultado por benchmark) y las correcciones de nombres de tablas. Incluir ejemplos de salida.


## 7. Verificación en la BD
`sql
SELECT viewname FROM pg_views WHERE schemaname='public' ORDER BY viewname;
`
Resultado: _consumo_por_experimento, _mejor_benchmark, _modelo_resumen.
