import pandas as pd

# 1. Cargar el CSV original
url = "https://epoch.ai/data/all_ai_models.csv"
print("Descargando CSV original para auditar Entidad 1: Modelo_LLM...")
df_raw = pd.read_csv(url)

# 2. Filtrar por modelos de lenguaje (LLMs)
df_llm = df_raw[df_raw['Domain'].astype(str).str.contains('Language', case=False, na=False)].copy()
total_llms = len(df_llm)

# 3. Definir mapeo Atributo Entidad SQL <-> Columna CSV Original
mapeo_modelo_llm = {
    'id_modelo': '(Generado como Autoincremental / PK)',
    'nombre': 'Model',
    'organizacion_desarrolladora': 'Organization',
    'tipo_organizacion': 'Organization categorization',
    'pais_origen': 'Country (of organization)',
    'fecha_publicacion': 'Publication date',
    'autores': 'Authors',
    'numero_parametros_billon': 'Parameters',
    'notas_parametros': 'Parameters notes',
    'modelo_base': 'Base model',
    'es_modelo_base': 'Foundation model',
    'es_open_source': 'Open model weights?',
    'accesibilidad_modelo': 'Model accessibility',
    'accesibilidad_codigo': 'Training code accessibility',
    'notas_accesibilidad': 'Accessibility notes',
    'hf_developer_id': 'Hugging Face developer id',
    'es_frontier_model': 'Frontier model',
    'criterio_notabilidad': 'Notability criteria',
    'notas_notabilidad': 'Notability criteria notes',
    'resumen_abstract': 'Abstract',
    'referencia_titulo': 'Reference',
    'url_referencia': 'Link',
    'url_archivada': 'Archived links',
    'citaciones_academicas': 'Citations',
    'ultima_actualizacion_csv': 'Last modified'
}

print("\n" + "=" * 100)
print(f" TEST DE AUDITORÍA Y DISPONIBILIDAD: ENTIDAD 1 (Modelo_LLM)")
print(f" Universo analizado: {total_llms} registros de LLMs")
print("=" * 100)

auditoria = []

for atributo_sql, col_csv in mapeo_modelo_llm.items():
    if col_csv.startswith('('):
        # Campos generados internamente
        auditoria.append({
            'Atributo SQL': atributo_sql,
            'Columna CSV Fuente': col_csv,
            'Existe en CSV': 'SI (Sintético)',
            'Llenados': total_llms,
            '% Cobertura': '100.0%',
            'Muestra Ejemplo 1': '1',
            'Muestra Ejemplo 2': '2'
        })
        continue

    existe = col_csv in df_llm.columns
    if existe:
        no_nulos = df_llm[col_csv].dropna().count()
        porcentaje = round((no_nulos / total_llms) * 100, 2)
        muestras = df_llm[col_csv].dropna().unique()
        ej1 = str(muestras[0])[:30] if len(muestras) > 0 else "N/A"
        ej2 = str(muestras[1])[:30] if len(muestras) > 1 else "N/A"
        
        auditoria.append({
            'Atributo SQL': atributo_sql,
            'Columna CSV Fuente': col_csv,
            'Existe en CSV': 'SI',
            'Llenados': no_nulos,
            '% Cobertura': f"{porcentaje}%",
            'Muestra Ejemplo 1': ej1,
            'Muestra Ejemplo 2': ej2
        })
    else:
        auditoria.append({
            'Atributo SQL': atributo_sql,
            'Columna CSV Fuente': col_csv,
            'Existe en CSV': 'NO',
            'Llenados': 0,
            '% Cobertura': '0.0%',
            'Muestra Ejemplo 1': 'N/A',
            'Muestra Ejemplo 2': 'N/A'
        })

df_resultado = pd.DataFrame(auditoria)

# Configuración de impresión limpia en consola
pd.set_option('display.max_columns', None)
pd.set_option('display.width', 1000)
pd.set_option('display.max_colwidth', 32)

print(df_resultado.to_string(index=False))
print("\n" + "=" * 100)