-- =====================================================================
-- Carga de datos en proyectobd (Hito 2, seccion 4.2)
-- Ejecutar: psql -U <usuario> -d proyectobd -f hito2/load_proyectobd.sql
-- (desde la carpeta raiz del proyecto)
-- =====================================================================

TRUNCATE TABLE respuesta_modelo, experimento_dataset, consumo_gpu, evaluacion, item_benchmark, experimento, dataset, modelo_llm, organizacion, gpu, benchmark CASCADE;

ALTER TABLE respuesta_modelo DISABLE TRIGGER trg_validar_respuesta;

\copy organizacion(id_organizacion,nombre,pais,tipo,fecha_fundacion) FROM './data_out/csv/organizacion.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy modelo_llm(id_modelo,nombre,version,arquitectura,tipo_modelo,num_param,longitud_token,tipo_token,estado,id_organizacion,id_modelo_base) FROM './data_out/csv/modelo_llm.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy dataset(id_dataset,nombre,version,fase_uso,dominio,formato_datos,tamanio,num_registros,licencia,fuente_origen) FROM './data_out/csv/dataset.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy experimento(id_run,nombre,id_modelo,tipo_entrenamiento,optimizador,precision_calculo,num_epocas,tam_batch,tasa_aprendizaje,estado_ejecucion,fecha_inicio,fecha_fin,segundos,loss_final) FROM './data_out/csv/experimento.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy gpu(id_gpu,modelo_gpu,fabricante,proveedor_cloud,memoria_vram,num_nucleos,costo_por_hora) FROM './data_out/csv/gpu.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy benchmark(id_benchmark,nombre,version,categoria,metodo,num_items,descripcion) FROM './data_out/csv/benchmark.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy evaluacion(id_evaluacion,id_modelo,id_benchmark,id_organizacion_evaluadora,fecha_evaluacion,resultado_metrica) FROM './data_out/csv/evaluacion.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy item_benchmark(id_item,id_benchmark,prompt_pregunta,respuesta_esperada) FROM './data_out/csv/item_benchmark.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy respuesta_modelo(id_respuesta,id_evaluacion,id_item,output_generado,es_correcta,tokens_output,latencia) FROM './data_out/csv/respuesta_modelo.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy experimento_dataset(id_run,id_dataset) FROM './data_out/csv/experimento_dataset.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy consumo_gpu(id_run,id_gpu,horas_uso,consumo_energetico) FROM './data_out/csv/experimento_gpu.csv' WITH (FORMAT csv, HEADER true, NULL '');

ALTER TABLE respuesta_modelo ENABLE TRIGGER trg_validar_respuesta;