(TeX-add-style-hook
 "bibliography"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("memoir" "12pt" "article" "oneside")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("babel" "spanish" "spanish.mexico" "") ("fontenc" "T1") ("inputenc" "utf8") ("libertinus" "osf") ("DejaVuSansMono" "scaled=0.7") ("microtype" "babel=true" "verbose=false" "tracking=true" "expansion=true" "protrusion=true" "final" "draft=false") ("csquotes" "autostyle=false" "style=british") ("geometry" "margin=3cm") ("biblatex" "style=authoryear-comp" "giveninits=true" "uniquename=init" "mincrossrefs=20" "")))
   (TeX-run-style-hooks
    "latex2e"
    "memoir"
    "memoir12"
    "ifluatex"
    "fontspec"
    "babel"
    "fontenc"
    "inputenc"
    "libertinus"
    "DejaVuSansMono"
    "AlegreyaSans"
    "microtype"
    "csquotes"
    "latexcolors"
    "geometry"
    "graphicx"
    "biblatex"
    "enumitem")
   (TeX-add-symbols
    "elipsis"
    "elipsisb")
   (LaTeX-add-bibliographies
    "SalgadoInIsagogem"))
 :latex)

