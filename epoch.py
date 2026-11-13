import pandas as pd
import numpy as np

# 1. Cargar el CSV completo desde la fuente
url = "https://epoch.ai/data/all_ai_models.csv"
print("Descargando CSV oficial...")
df = pd.read_csv(url)

# 2. Filtrar únicamente Modelos de Lenguaje (LLMs)
df_llm = df[df['Domain'].astype(str).str.contains('Language', case=False, na=False)].copy()
df_llm.reset_index(drop=True, inplace=True)
df_llm['id_modelo'] = df_llm.index + 1

# =========================================================================
# LIMPIEZA PREVIA DE COLUMNAS NUMÉRICAS (Evita TypeErrors)
# =========================================================================
columnas_numericas = [
    'Parameters', 'Citations', 'Training dataset size (total)',
    'Epochs', 'Batch size', 'Training compute (FLOP)',
    'Training compute lower bound', 'Training compute upper bound',
    'Finetune compute (FLOP)', 'Post-training compute (FLOP)',
    'Hardware quantity', 'Training time (hours)', 'Training chip-hours',
    'Training power draw (W)', 'Training compute cost (2023 USD)',
    'Hardware utilization (MFU)', 'Hardware utilization (HFU)'
]

for col in columnas_numericas:
    if col in df_llm.columns:
        df_llm[col] = pd.to_numeric(df_llm[col], errors='coerce')

def to_bool(val):
    if pd.isnull(val): return False
    s = str(val).strip().lower()
    return s in ['yes', 'true', '1.0', '1']

print(f"-> Procesando {len(df_llm)} LLMs con conversión numérica segura...")

# =========================================================================
# TABLA 1: Modelo_LLM
# =========================================================================
tabla_modelo_llm = pd.DataFrame({
    'id_modelo': df_llm['id_modelo'],
    'nombre': df_llm['Model'].fillna('Sin nombre'),
    'organizacion_desarrolladora': df_llm['Organization'].fillna('Comunidad / Desconocido'),
    'tipo_organizacion': df_llm['Organization categorization'].fillna('No especificado'),
    'pais_origen': df_llm['Country (of organization)'].fillna('No especificado'),
    'fecha_publicacion': df_llm['Publication date'],
    'autores': df_llm['Authors'].fillna('No detallado'),
    'numero_parametros_billon': df_llm['Parameters'].apply(lambda x: round(x / 1e9, 4) if pd.notnull(x) and x > 0 else None),
    'notas_parametros': df_llm['Parameters notes'].fillna(''),
    'modelo_base': df_llm['Base model'].fillna('N/A'),
    'es_modelo_base': df_llm['Foundation model'].apply(to_bool),
    'es_open_source': df_llm['Open model weights?'].apply(to_bool),
    'accesibilidad_modelo': df_llm['Model accessibility'].fillna('Privado / Desconocido'),
    'accesibilidad_codigo': df_llm['Training code accessibility'].fillna('No publicado'),
    'notas_accesibilidad': df_llm['Accessibility notes'].fillna(''),
    'hf_developer_id': df_llm['Hugging Face developer id'].fillna('N/A'),
    'es_frontier_model': df_llm['Frontier model'].apply(to_bool),
    'criterio_notabilidad': df_llm['Notability criteria'].fillna('General'),
    'notas_notabilidad': df_llm['Notability criteria notes'].fillna(''),
    'resumen_abstract': df_llm['Abstract'].fillna(''),
    'referencia_titulo': df_llm['Reference'].fillna(''),
    'url_referencia': df_llm['Link'].fillna(''),
    'url_archivada': df_llm['Archived links'].fillna(''),
    'citaciones_academicas': df_llm['Citations'].fillna(0).astype(int),
    'ultima_actualizacion_csv': df_llm['Last modified']
})

# =========================================================================
# TABLA 2: Dataset_Entrenamiento
# =========================================================================
tabla_dataset = pd.DataFrame({
    'id_dataset': df_llm['id_modelo'],
    'id_modelo': df_llm['id_modelo'],
    'dominio': df_llm['Domain'],
    'tarea_principal': df_llm['Task'].fillna('Language modeling'),
    'tokens_totales': df_llm['Training dataset size (total)'].apply(lambda x: int(x) if pd.notnull(x) and x > 0 else None),
    'notas_dataset': df_llm['Dataset size notes'].fillna(''),
    'datos_evaluacion_benchmark': df_llm['WikiText and Penn Treebank data'].fillna('')
})

# =========================================================================
# TABLA 3: Catalogo_GPU
# =========================================================================
hardware_unicos = df_llm['Training hardware'].dropna().unique()

tabla_gpu = pd.DataFrame({
    'id_gpu': range(1, len(hardware_unicos) + 1),
    'modelo_hardware': hardware_unicos,
    'fabricante': ['NVIDIA' if 'nvidia' in str(h).lower() else 'Google' if 'tpu' in str(h).lower() else 'AMD' if 'amd' in str(h).lower() else 'Otro' for h in hardware_unicos],
    'proveedor_cloud': df_llm.groupby('Training hardware')['Training cloud compute vendor'].first().reindex(hardware_unicos).fillna('On-Premise / No especificado').values,
    'centro_de_datos': df_llm.groupby('Training hardware')['Training data center'].first().reindex(hardware_unicos).fillna('No especificado').values
})

mapa_gpu = dict(zip(tabla_gpu['modelo_hardware'], tabla_gpu['id_gpu']))
df_llm['id_gpu_fk'] = df_llm['Training hardware'].map(mapa_gpu)

# =========================================================================
# TABLA 4: Experimento_Entrenamiento
# =========================================================================
tabla_experimento = pd.DataFrame({
    'id_experimento': df_llm['id_modelo'],
    'id_modelo': df_llm['id_modelo'],
    'enfoque_entrenamiento': df_llm['Approach'].fillna('Pre-training general'),
    'computo_pretraining_flop': df_llm['Training compute (FLOP)'],
    'notas_computo': df_llm['Training compute notes'].fillna(''),
    'metodo_estimacion_computo': df_llm['Training compute estimation method'].fillna('No especificado'),
    'cota_inferior_flop': df_llm['Training compute lower bound'],
    'cota_superior_flop': df_llm['Training compute upper bound'],
    'supera_1e23_flop': df_llm['Possibly over 1e23 FLOP'].apply(to_bool),
    'computo_finetune_flop': df_llm['Finetune compute (FLOP)'],
    'notas_finetune': df_llm['Finetune compute notes'].fillna(''),
    'computo_post_training_flop': df_llm['Post-training compute (FLOP)'],
    'notas_post_training': df_llm['Post-training compute notes'].fillna(''),
    'epocas': df_llm['Epochs'].apply(lambda x: round(x, 2) if pd.notnull(x) else None),
    'tamaño_batch': df_llm['Batch size'].apply(lambda x: int(x) if pd.notnull(x) else None),
    'notas_batch_size': df_llm['Batch size notes'].fillna(''),
    'formato_numerico': df_llm['Numerical format'].fillna('No especificado'),
    'nivel_confianza_datos': df_llm['Confidence'].fillna('Uncertain')
})

# =========================================================================
# TABLA 5: Consumo_GPU_Rendimiento
# =========================================================================
watts = df_llm['Training power draw (W)'].fillna(0)
horas = df_llm['Training time (hours)'].fillna(0)
kwh_vectorial = ((watts * horas) / 1000).round(2)

tabla_consumo_gpu = pd.DataFrame({
    'id_consumo': df_llm['id_modelo'],
    'id_experimento': df_llm['id_modelo'],
    'id_gpu': df_llm['id_gpu_fk'].fillna(-1).astype(int),
    'cantidad_gpus': df_llm['Hardware quantity'].fillna(1).astype(int),
    'horas_entrenamiento': df_llm['Training time (hours)'],
    'notas_tiempo_entrenamiento': df_llm['Training time notes'].fillna(''),
    'chip_hours': df_llm['Training chip-hours'],
    'potencia_watts': df_llm['Training power draw (W)'],
    'consumo_energetico_kwh': kwh_vectorial.replace(0, np.nan),
    'costo_total_usd_2023': df_llm['Training compute cost (2023 USD)'],
    'eficiencia_mfu': df_llm['Hardware utilization (MFU)'],
    'eficiencia_hfu': df_llm['Hardware utilization (HFU)'],
    'notas_utilizacion': df_llm['Utilization notes'].fillna('')
})

# =========================================================================
# EXPORTACIÓN DE CSVs
# =========================================================================
tabla_modelo_llm.to_csv("1_Modelo_LLM.csv", index=False)
tabla_dataset.to_csv("2_Dataset_Entrenamiento.csv", index=False)
tabla_gpu.to_csv("3_Catalogo_GPU.csv", index=False)
tabla_experimento.to_csv("4_Experimento_Entrenamiento.csv", index=False)
tabla_consumo_gpu.to_csv("5_Consumo_GPU_Rendimiento.csv", index=False)

print("\n ARCHIVOS CSV GENERADOS EXITOSAMENTE Y SIN ERRORES:")
print(" -> 1_Modelo_LLM.csv")
print(" -> 2_Dataset_Entrenamiento.csv")
print(" -> 3_Catalogo_GPU.csv")
print(" -> 4_Experimento_Entrenamiento.csv")
print(" -> 5_Consumo_GPU_Rendimiento.csv")