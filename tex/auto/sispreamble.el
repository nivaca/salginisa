(TeX-add-style-hook
 "sispreamble"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("book" "letterpaper" "12pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("babel" "english" "spanish" "spanish.mexico" "latin") ("microtype" "babel=true" "verbose=false" "tracking=true" "expansion=true" "protrusion=true" "final" "draft=false") ("csquotes" "autostyle=false" "style=british") ("reledmac" "final") ("biblatex" "style=authoryear-comp" "giveninits=true" "uniquename=init" "mincrossrefs=20" "")))
   (TeX-run-style-hooks
    "latex2e"
    "book"
    "bk12"
    "fontspec"
    "babel"
    "microtype"
    "csquotes"
    "latexcolors"
    "geometry"
    "fancyhdr"
    "amssymb"
    "gitinfo2"
    "imakeidx"
    "reledmac"
    "biblatex")
   (TeX-add-symbols
    '("missingContent" 1)
    '("fenestra" 1)
    '("corruption" 1)
    '("added" 1)
    '("no" 1)
    '("del" 1)
    '("hand" 1)
    '("metatext" 1)
    '("secluded" 1)
    '("suppliedInVacuo" 1)
    '("supplied" 1)
    '("worktitle" 1)
    '("lemmaQuote" 1)
    '("name" 1)
    "lacuna"
    "Afootnoterule"
    "Bfootnoterule")
   (LaTeX-add-bibliographies
    "bib/SalgadoInIsagogem"))
 :latex)

