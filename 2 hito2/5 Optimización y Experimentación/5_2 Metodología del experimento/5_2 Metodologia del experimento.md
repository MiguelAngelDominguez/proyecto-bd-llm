# 5.2 Metodología del experimento

## Objetivo
Definir el protocolo de medición para comparar el rendimiento de las 5 consultas con y sin índices.

---

## 1. Protocolo de medición

### Warm-up
- Ejecutar cada consulta **una vez** y descartar el resultado (calentar caché de PostgreSQL).

### Repeticiones
- **5 ejecuciones** por consulta.
- Se toma el **tiempo medio** de las 5 ejecuciones.

### Métrica
- Tiempo de ejecución en **milisegundos (ms)** reportado por `EXPLAIN (ANALYZE, TIMING)`.

### Limpieza de caché
- `DISCARD ALL;` entre ejecuciones (dentro de la sesión).
- Reiniciar la sesión entre volúmenes para evitar contaminación de caché.

### Orden de ejecución
- Aleatorio para evitar sesgo por caché.

---

## 2. Escenarios de prueba

### Sin índices (5.5.1)
- Se eliminan todos los índices creados (solo PKs permanecen).
- Se ejecutan las 5 consultas en los 4 volúmenes.
- Se registra el tiempo de cada ejecución.

### Con índices (5.5.2)
- Se crean los índices del script `5_3_0 indices.sql`.
- Se ejecutan las 5 consultas en los 4 volúmenes.
- Se registra el tiempo de cada ejecución.

---

## 3. Volúmenes probados

| Volumen | Filas totales | BD |
|---|---|---|
| 1k | ~1.135 | `proyectobd_1k` |
| 10k | 10.000 | `proyectobd` |
| 100k | ~99.550 | `proyectobd_100k` |
| 1M | ~995.050 | `proyectobd_1m` |

---

## 4. Comandos utilizados

### Medición sin índices
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```

### Medición con índices
```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) <consulta>;
```

### Limpieza de caché
```sql
DISCARD ALL;
```

---

## 5. Consideraciones
- Las mediciones se realizaron en la misma máquina (plataforma de pruebas: 5.4).
- Se usó `EXPLAIN (ANALYZE, TIMING)` como métrica estándar de PostgreSQL.
- Los resultados se guardaron en archivos `.txt` por volumen.

## Nota para el informe (LaTeX)
Explicar el protocolo y justificar el uso de EXPLAIN ANALYZE. Incluir la tabla de volúmenes y la metodología de medición.