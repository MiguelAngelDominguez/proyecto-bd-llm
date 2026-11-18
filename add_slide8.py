import shutil
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from copy import deepcopy

src = r"D:\.Drive\UTEC\Ciclo 03\Base de Datos 1\Proyecto_!\exposicion_bd1_llm.pptx.pptx"
out = r"D:\.Drive\UTEC\Ciclo 03\Base de Datos 1\Proyecto_!\exposicion_bd1_llm.pptx.pptx"

prs = Presentation(src)
template = prs.slides[5]  # slide 6

# Duplicate slide by copying all shapes
new_slide = prs.slides.add_slide(template.slide_layout)
# Remove default shapes (none for Blank layout, but just in case)
for sh in list(new_slide.shapes):
    new_slide.shapes._spTree.remove(sh.element)

for sh in template.shapes:
    new_el = deepcopy(sh.element)
    new_slide.shapes._spTree.append(new_el)

# Modify text boxes
for sh in new_slide.shapes:
    if sh.has_text_frame:
        txt = sh.text
        if "Protocolo" in txt:
            for pgh in sh.text_frame.paragraphs:
                for run in pgh.runs:
                    run.text = "Conclusiones y escala"
        elif "Warm-up" in txt:
            for pgh in sh.text_frame.paragraphs:
                for run in pgh.runs:
                    run.text = ""
            # add bullets
            tf = sh.text_frame
            tf.text = "Los índices dependen del patrón de consulta."
            p = tf.add_paragraph()
            p.text = "Solo Q1 mejora (~2.2× en 1M); Q2–Q5 no mejoran (agregaciones sobre toda la tabla)."
            p = tf.add_paragraph()
            p.text = "Más allá de 1M: materialized views y particionamiento."
            p = tf.add_paragraph()
            p.text = "PostgreSQL es adecuado para millones de registros, pero requiere optimización específica."
        elif txt.strip() == "6":
            for pgh in sh.text_frame.paragraphs:
                for run in pgh.runs:
                    run.text = "8"

prs.save(out)
print("saved", out)
PY