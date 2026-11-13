import os
import pandas as pd

# Configuración básica de pandas
pd.set_option('display.max_columns', None)
pd.set_option('display.width', 1000)

# Mapeo de Entidades con sus columnas clave para la vista preliminar horizontal
archivos_entidades = {
    "1. Modelo_LLM": (
        "1_Modelo_LLM.csv", 
        ['id_modelo', 'nombre', 'organizacion_desarrolladora', 'fecha_publicacion', 'numero_parametros_billon', 'es_open_source']
    ),
    "2. Dataset_Entrenamiento": (
        "2_Dataset_Entrenamiento.csv", 
        ['id_dataset', 'id_modelo', 'tarea_principal', 'tokens_totales', 'datos_evaluacion_benchmark']
    ),
    "3. Catalogo_GPU": (
        "3_Catalogo_GPU.csv", 
        ['id_gpu', 'modelo_hardware', 'fabricante', 'proveedor_cloud', 'centro_de_datos']
    ),
    "4. Experimento_Entrenamiento": (
        "4_Experimento_Entrenamiento.csv", 
        ['id_experimento', 'id_modelo', 'enfoque_entrenamiento', 'computo_pretraining_flop', 'formato_numerico']
    ),
    "5. Consumo_GPU_Rendimiento": (
        "5_Consumo_GPU_Rendimiento.csv", 
        ['id_consumo', 'id_gpu', 'cantidad_gpus', 'horas_entrenamiento', 'consumo_energetico_kwh', 'costo_total_usd_2023']
    )
}

print("=" * 95)
print(" VISUALIZADOR Y AUDITOR DE ENTIDADES BASE DE DATOS ")
print("=" * 95 + "\n")

for nombre_entidad, (ruta_csv, cols_clave) in archivos_entidades.items():
    if not os.path.exists(ruta_csv):
        print(f"❌ [ALERTA] No se encontró el archivo: '{ruta_csv}'\n")
        continue

    df = pd.read_csv(ruta_csv)
    total_filas, total_cols = df.shape

    print("=" * 95)
    print(f"📊 ENTIDAD: {nombre_entidad.upper()} ({total_filas} filas | {total_cols} columnas)")
    print("=" * 95)

    # -------------------------------------------------------------------------
    # BLOQUE 1: REPORTE COMPLETO DE ESTRUCTURA Y COBERTURA (Todas las columnas)
    # -------------------------------------------------------------------------
    resumen = pd.DataFrame({
        'Columna / Campo': df.columns,
        'Tipo': df.dtypes.astype(str).values,
        'No Nulos': df.notnull().sum().values,
        'Nulos': df.isnull().sum().values,
        '% Llenado': ((df.notnull().sum().values / total_filas) * 100).round(1)
    })
    resumen['% Llenado'] = resumen['% Llenado'].astype(str) + '%'

    print("\n[ 1. ESTRUCTURA Y AUDITORÍA DE CAMPOS TOTALES ]")
    print(resumen.to_string(index=False))

    # -------------------------------------------------------------------------
    # BLOQUE 2: VISTA PREVIA COMPACTA HORIZONTAL (Solo columnas representativas)
    # -------------------------------------------------------------------------
    df_preview = df[cols_clave].head(3).copy()
    
    # Recortar texto horizontal a máximo 28 caracteres
    for col in df_preview.columns:
        if df_preview[col].dtype == 'object':
            df_preview[col] = df_preview[col].astype(str).apply(
                lambda x: (x[:25] + '...') if len(x) > 28 else x
            )

    print(f"\n[ 2. MUESTRA RESUMIDA (Primeros 3 registros - Columnas Clave) ]")
    print(df_preview.to_string(index=False))

    # -------------------------------------------------------------------------
    # BLOQUE 3: FICHA TÉCNICA VERTICAL (Primer registro completo ordenado)
    # -------------------------------------------------------------------------
    print(f"\n[ 3. FICHA TÉCNICA EN DETALLE (Muestra de Registro 1 completo) ]")
    row1 = df.iloc[0]
    for campo, valor in row1.items():
        val_str = str(valor)
        if len(val_str) > 65:
            val_str = val_str[:62] + "..."
        print(f"  • {campo:<30} : {val_str}")

    print("\n" + "-" * 95 + "\n")