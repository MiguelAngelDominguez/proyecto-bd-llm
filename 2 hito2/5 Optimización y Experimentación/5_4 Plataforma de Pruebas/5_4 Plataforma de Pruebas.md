# 5.4 Plataforma de Pruebas

## Hardware
- CPU: Intel(R) Core(TM) i5-10400F CPU @ 2.90GHz
- RAM: 16 GB (17041965056 bytes)
- Disco: D: (647 GB, 27 GB libres) — datos en SSD recomendado

## Software
- PostgreSQL 18.6 (x86_64-windows, msvc-19.44.35229, 64-bit)
- OS: Windows
- Cliente: psql (`C:\Program Files\PostgreSQL\18\bin\psql.exe`)

## Configuración relevante
- `shared_buffers`: default
- `work_mem`: default
- `max_connections`: default

## Volúmenes probados
- 1.000 (1k)
- 10.000 (10k)
- 100.000 (100k)
- 1.000.000 (1M)

## Nota para el informe (LaTeX)
Incluir estos datos como plataforma de pruebas. La configuración es la default de PostgreSQL 18.