import os
path = r"D:\.Drive\UTEC\Ciclo 03\Base de Datos 1\Proyecto_!\Proyecto_BD.tex"
s = open(path, encoding='utf-8').read()

marker = '\\subsection{Carga de datos}'
idx = s.find(marker)
assert idx != -1, "marker not found"
prefix = s[:idx].rstrip()

# The content is in a separate file to avoid huge inline string
content_path = r"D:\.Drive\UTEC\Ciclo 03\Base de Datos 1\Proyecto_!\latex_content.txt"
content = open(content_path, encoding='utf-8').read()

s = prefix + '\n\n' + content.lstrip('\n') + '\n'
open(path, 'w', encoding='utf-8').write(s)
print("done")