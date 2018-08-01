  (require 'popup)
  (require 'vhdl-goto-def)
  (require 'vhdl-extreme)

  (setq vhdl-compiler "ModelSim")
  (setq vhdl-compiler-alist (quote (("Cadence Leapfrog" "cv" "-work \\1 -file" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "leapfrog" ("duluth: \\*E,[0-9]+ (\\(.+\\),\\([0-9]+\\)):" 1 2 0) ("" 0) ("\\1/entity" "\\2/\\1" "\\1/configuration" "\\1/package" "\\1/body" downcase)) ("Cadence NC" "ncvhdl" "-work \\1" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "ncvhdl" ("ncvhdl_p: \\*E,\\w+ (\\(.+\\),\\([0-9]+\\)|\\([0-9]+\\)):" 1 2 3) ("" 0) ("\\1/entity/pc.db" "\\2/\\1/pc.db" "\\1/configuration/pc.db" "\\1/package/pc.db" "\\1/body/pc.db" downcase)) ("Ikos" "analyze" "-l \\1" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "ikos" ("E L\\([0-9]+\\)/C\\([0-9]+\\):" 0 1 2) ("^analyze +\\(.+ +\\)*\\(.+\\)$" 2) nil) ("ModelSim" "vcom" "-2002 -work \\1" "make" "-f \\1" nil "vlib \\1; vmap \\2 \\1" "./" "work/" "Makefile" "modelsim" ("\\(ERROR\\|WARNING\\|\\*\\* Error\\|\\*\\* Warning\\)[^:]*: \\(.+\\)(\\([0-9]+\\)):" 2 3 0) ("" 0) ("\\1/_primary.dat" "\\2/\\1.dat" "\\1/_primary.dat" "\\1/_primary.dat" "\\1/body.dat" downcase)) ("LEDA ProVHDL" "provhdl" "-w \\1 -f" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "provhdl" ("\\([^ 	
]+\\):\\([0-9]+\\): " 1 2 0) ("" 0) ("ENTI/\\1.vif" "ARCH/\\1-\\2.vif" "CONF/\\1.vif" "PACK/\\1.vif" "BODY/BODY-\\1.vif" upcase)) ("QuickHDL" "qvhcom" "-work \\1" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "quickhdl" ("\\(ERROR\\|WARNING\\)[^:]*: \\(.+\\)(\\([0-9]+\\)):" 2 3 0) ("" 0) ("\\1/_primary.dat" "\\2/\\1.dat" "\\1/_primary.dat" "\\1/_primary.dat" "\\1/body.dat" downcase)) ("Savant" "scram" "-publish-cc -design-library-name \\1" "make" "-f \\1" nil "mkdir \\1" "./" "work._savant_lib/" "Makefile" "savant" ("\\([^ 	
]+\\):\\([0-9]+\\): " 1 2 0) ("" 0) ("\\1_entity.vhdl" "\\2_secondary_units._savant_lib/\\2_\\1.vhdl" "\\1_config.vhdl" "\\1_package.vhdl" "\\1_secondary_units._savant_lib/\\1_package_body.vhdl" downcase)) ("Simili" "vhdlp" "-work \\1" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "simili" ("\\(Error\\|Warning\\): \\w+: \\(.+\\): (line \\([0-9]+\\)): " 2 3 0) ("" 0) ("\\1/prim.var" "\\2/_\\1.var" "\\1/prim.var" "\\1/prim.var" "\\1/_body.var" downcase)) ("Speedwave" "analyze" "-libfile vsslib.ini -src" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "speedwave" ("^ *ERROR[[0-9]+]::File \\(.+\\) Line \\([0-9]+\\):" 1 2 0) ("" 0) nil) ("Synopsys" "vhdlan" "-nc -work \\1" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "synopsys" ("\\*\\*Error: vhdlan,[0-9]+ \\(.+\\)(\\([0-9]+\\)):" 1 2 0) ("" 0) ("\\1.sim" "\\2__\\1.sim" "\\1.sim" "\\1.sim" "\\1__.sim" upcase)) ("Synopsys Design Compiler" "vhdlan" "-nc -spc -work \\1" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "synopsys_dc" ("\\*\\*Error: vhdlan,[0-9]+ \\(.+\\)(\\([0-9]+\\)):" 1 2 0) ("" 0) ("\\1.syn" "\\2__\\1.syn" "\\1.syn" "\\1.syn" "\\1__.syn" upcase)) ("Synplify" "n/a" "n/a" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "synplify" ("@[EWN]:\"\\(.+\\)\":\\([0-9]+\\):\\([0-9]+\\):" 1 2 3) ("" 0) nil) ("Vantage" "analyze" "-libfile vsslib.ini -src" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "vantage" ("\\*\\*Error: LINE \\([0-9]+\\) \\*\\*\\*" 0 1 0) ("^ *Compiling \"\\(.+\\)\" " 1) nil) ("VeriBest" "vc" "vhdl" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "veribest" ("^ +\\([0-9]+\\): +[^ ]" 0 1 0) ("" 0) nil) ("Viewlogic" "analyze" "-libfile vsslib.ini -src" "make" "-f \\1" nil "mkdir \\1" "./" "work/" "Makefile" "viewlogic" ("\\*\\*Error: LINE \\([0-9]+\\) \\*\\*\\*" 0 1 0) ("^ *Compiling \"\\(.+\\)\" " 1) nil))))
 ;; (setq vhdl-end-comment-column 100)
 (setq vhdl-file-header "--! @file
--! @brief <title string>
--! @details <cursor>
-------------------------------------------------------------------------------
-- File       : <filename>
-- Project    : <project>
-- Author     : <author>
-- Company    : <company>
-- Created    : <date>
-- Last update: <date>
-- Platform   : <platform>
-- Standard   : <standard>
<copyright>-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- <date>  1.0      <login>	Created
------------------------------------------------------------------------------- 

")


;;  (setq vhdl-indent-comment-like-next-code-line nil)
;; (setq vhdl-inline-comment-column 70)

 (setq vhdl-reset-active-high t)
 (setq vhdl-reset-kind (quote none))
 (add-to-list 'auto-mode-alist '("[.]do$" . tcl-mode))

(global-set-key (kbd "C-c v d") 'searchForTheWordUnderPoint)
(global-set-key (kbd "C-c v c") 'vvhdl-create-std-logic)


(defun my-vhdl-hook ()
  "defines the tags-table-list"
  (when (eq major-mode 'vhdl-mode)
    (setq tags-table-list
          '("~/Documents/"))   )
  )

(add-hook 'vhdl-mode-hook 'my-vhdl-hook)



(provide 'my-vhdl)
