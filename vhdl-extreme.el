;; find packages in a given project
;; insert a special file named .extreme in to the project top
(require 's)
(require 'f)




;;(setq excludeVhdlSearchPaths "*/mb/pcores/*") ;; TODO : bunu eklemen lazim daha guzel bir sekilde


(defun upOneLevel (pathStr)
  "Return dir."
  (interactive)
  (expand-file-name (directory-file-name (file-name-directory pathStr)))
)

(defun findProjectTop ()
  "Is the given path includes a file named .extreme"
  (interactive)
  (let ((my-current-dir ))
    (setq my-current-dir (expand-file-name 
			  (directory-file-name (file-name-directory (buffer-file-name)))))
    (while (not (file-exists-p (concat my-current-dir "/.extreme")))
      (setq my-current-dir (upOneLevel my-current-dir))
      )
    my-current-dir
    )
)

(defun getExtremeFile ()
  "Return .extreme path"
  (interactive)
  (let ((projectPath (findProjectTop)))
    (setq extremePath (concat projectPath "/.extreme"))
    extremePath
    ))


(defun findLibraries ()
  "Find all the libraries used in a file"
  (interactive)
  (save-excursion
    (let ((libs '("work")))
      (goto-char (point-min))
      (while (re-search-forward "^ *library " nil t nil)
	(forward-char)
	(unless (or (string= (whdl-get-name) "ieee") (string= (whdl-get-name) "work"))
	  (push (whdl-get-name) libs)))
      libs)
    ))

(defun findPackages ()
  "Find all the packages used in a file"
  (interactive)
  (save-excursion
    (let ((libs (findLibraries)) (packages '()))
      (dolist (lib libs)
 	(goto-char (point-min))
	 (while (re-search-forward (concat "^ *use  *" lib "\.") nil t nil)
	   (forward-char)
	   (push (list lib (whdl-get-name)) packages))
   )
      packages
      ;; (goto-char (point-min))
      ;; (dolist (pack packages) (insert (concat (first pack) "." (cdr pack) "\n")))
      )))

;;;(popup-tip "heeeeyt")


(defun readLines (filePath)
  "Read lines from file into list"
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))


(defun assignPackagePaths ()
  "Package paths"
  (let ((lines (readLines (getExtremeFile)))
        (usedPackages (findPackages))
        (packagePaths '())
        (topPath '())
        )
    (dolist (pack usedPackages)
      (setq fileName (concat (nth 1 pack) ".vhd"))
      (setq libName (first pack))
      (dolist (line lines)
        (if (string= (s-trim (first (split-string line ":"))) libName)
            (setq topPath (s-trim (nth 1 (split-string line ":"))) )
          )
        ) ;; lines dolist
      ;; TODO : hic library tanimlanmadigi durumda work ile calisilabilmeli
      (if (not (eq topPath nil))
          (progn

            (if (eq system-type 'gnu/linux) 

                (setq fileFullPathList (split-string (s-trim (shell-command-to-string
                          (concat "find " topPath " -iname " fileName) )) "\n"))

              ;; TODO : f-files cok yavas aslinda bunu mod haline getirip dosya acildiginda
              ;; asenkron olarak yapman lazim
              (setq fileFullPathList
                  (f-files topPath (lambda (file) (equal (downcase (f-filename file))
                                                         (downcase fileName))) t))
              )
            (dolist (fileFullPath fileFullPathList)
              (setq packagePaths (append packagePaths (list fileFullPath))))
            ))
      ) ;; packages dolist
    packagePaths
    )
  )

(defun searchForDefinition (searchTerm)
  "ddd"
  (let ((packagePaths (assignPackagePaths))
        (found) (foundDef))
    (save-excursion
      (setq found (whdl-process-file searchTerm))
      (if (not (not found))
	  (setq foundDef (list (buffer-file-name) found (progn (goto-char found) (whdl-get-name))))
	(dolist (package packagePaths)
	  (with-current-buffer (find-file-noselect package)
	    (save-excursion
	      (setq found (whdl-process-file searchTerm))
	      (if (not (not found))
		  (setq foundDef (list package found (progn (goto-char found) (whdl-get-name))))
      ))))))
    foundDef
    ))

(defun searchForTheWordUnderPoint ()
  "clear"
  (interactive)
  (let ((x (searchForDefinition (whdl-get-name)) )
	(def-line)
	(line-num))
    (save-excursion
    (with-current-buffer (find-file-noselect (first x))
      (save-excursion
      (progn (goto-char (nth 1 x))
	     (setq line-num (line-number-at-pos))
	     (setq def-line (get-current-line))
	     )))
    (popup-tip 
     (s-concat "\n" (first x) ":" (number-to-string line-num) " \n\n" (s-lex-format "${def-line}" ) "\n")
     :width 80)
    )))

(defun goForTheWordUnderPoint ()
  "clear"
  (interactive)
  (let ((x (searchForDefinition (whdl-get-name)) )
       )
    (progn
      (find-file (first x))
      (goto-char (nth 1 x))
      )))


(defun get-current-line ()
  "Returns current line as string"
  (interactive)
  (let (p1 p2)
    (setq p1 (line-beginning-position))
    (setq p2 (line-end-position))
    (buffer-substring-no-properties p1 p2))
)


(defun grep-in-vhdl ()
"custom grep"
(interactive)
(let ((word (read-from-minibuffer "Type: " nil nil)))
  (grep (concat "grep -nHRi --include=*.vhd " word))
)
)

(defun list-todos-in-vhdl ()
(interactive)
(grep "grep -nHRi --include=*.vhd TODO")
)


(defun vvhdl-create-signal-at-point ()
  "Creates the signal, asks for user input for types."
  (interactive)
  (let ((mySym (thing-at-point 'symbol)))
    (vvhdl-goto-uncommented-arch)
    (move-end-of-line nil)
    (insert (format "\n  signal %s : " mySym))
    (let ((new-type (read-from-minibuffer "Type: " nil vhdl-minibuffer-local-map)))
      (insert new-type)
      )
    (let ((new-init (read-from-minibuffer "Init: " nil vhdl-minibuffer-local-map)))
      (if (string-match new-init "")
	  (insert ";")
	(insert " := " new-init ";"))
      )
)
  )


(defun vvhdl-create-std-logic ()
  "Creates std-logic"
  (interactive)
  (let ((mySym (thing-at-point 'symbol)))
    (vvhdl-goto-uncommented-arch)
    (move-end-of-line nil)
    (insert (format "\n  signal %s : std_logic := '0';" mySym))
    )
  )

(defun vvhdl-find-all-occurrences-of-signal-point ()
  "Call occur with word under point."
  (interactive)
  (let ((mySym (thing-at-point 'symbol))) 
    (occur mySym)
    )
)

(defun vvhdl-is-string-uncommented-arch (testStr)
  "Test given string"
  (interactive)
  (let (p1 p2)
    (setq p1 (string-match "--" testStr))
    (setq p2 (string-match "architecture" testStr))
    (or (and (eq p1 nil) (not (eq p2 nil))) (and (not (eq p2 nil)) (< p2 p1) )  )
    )
  )

(defun vvhdl-goto-uncommented-arch ()
  "Search until an uncommented architecture is found"
  (interactive)
  (beginning-of-buffer)
  (while (not (vvhdl-is-string-uncommented-arch (get-current-line)))
    (search-forward "architecture")
    )
)


(defun isPointUnderComment (myPoint)
""
(save-excursion
  (goto-char myPoint)
  (let ((lineNumber (line-number-at-pos)))
    (if (re-search-backward "--" nil t nil)
	(= (line-number-at-pos) lineNumber) ()
	)
    ))
)

(defun componentAyikla ()
""
(save-excursion
  (let  ((current) (endPoint) (ikiNokta) (componentName) (packageName))
    (setq current (point))
    (setq endPoint (re-search-forward "[\\. a-z0-9A-Z_]*" nil t nil))    
    (re-search-backward ":" nil t nil)
    (if (and (= (re-search-forward "[ \n\t]+\\(entity[ \n\t]+[a-z0-9A-Z_]*\\.\\)?[a-z0-9A-Z_]*" nil t nil) endPoint) 
	 (not (areWeInsideConstantSignalDeclaration)) 
	 (not (areWeInsideParens)) 
	 (not (progn (goto-char current) (string= (whdl-get-name) "for")))
	 (not (progn (goto-char current) (string= (whdl-get-name) "if")))
	 )
	(if (progn (re-search-backward ":" nil t nil) 
		   (re-search-forward "[ \n\t]+[a-z0-9A-Z_]" nil t nil)
		   (string= (whdl-get-name) "entity")) 
	    (noktayaGit)  ;; entity li instantiation
	  (list "work" (progn (re-search-backward ":" nil t nil) 
			      (re-search-forward "[ \n\t]+[a-z0-9A-Z_]" nil t nil)
			      (whdl-get-name))))  ;; entity siz instantiation
      nil)
)))


(defun areWeInsideFuncProcBody ()
""
(save-excursion
  (let ((fName) (bodyEnd) (bodyBeginning) (currentPoint (point)))    
    (re-search-backward "^ *\\(function\\|impure function\\|procedure\\)" nil t nil)
    (re-search-forward "^ *\\(function\\|impure function\\|procedure\\)[ \n\t]+" nil t nil)
    (setq fName (whdl-get-name))    
    (setq bodyBeginning (re-search-forward "\\()[ \n\t]+return[ \n\t]+[a-z0-9A-Z_]*\\)?[ \n\t]+is" nil t nil))
    (if fName (setq bodyEnd (re-search-forward (concat "^ *end[ \n\t]+" fName ";") nil t nil)))
    (if (and bodyEnd bodyBeginning fName
	     (< currentPoint bodyEnd)
	     (> currentPoint bodyBeginning)
	     )
	fName ()
	)
    )))


(defun noktayaGit () 
  "entity package.component noktasina git"
  (save-excursion
    (let  ( (nokta) (componentName) (packageName))
      (setq nokta (re-search-forward "\\." nil t nil))
      (forward-char)
      (setq componentName (whdl-get-name))
      (goto-char nokta)
      (backward-char)
      (setq packageName (whdl-get-name))
      (list packageName componentName)
      )))

(defun areWeInsideConstantSignalDeclaration ()
  "Determine if we are inside signal declaration"
  (save-excursion
    (let ((currentPoint (point)) (endPoint) (startPoint))      
      (setq startPoint 
	    (re-search-backward "^ *\\(signal\\|constant\\)[ \n\t]+" nil t nil))
      (setq endPoint 
	    (re-search-forward "^ *\\(signal\\|constant\\)[ \n\t]+[a-z0-9A-Z_, \n]+[ \n\t]+:[ \n\t]+[a-z0-9A-Z_]+[^;]*;" 
			       nil t nil))   
      (if (and startPoint endPoint (< startPoint currentPoint) (> endPoint currentPoint)) 
	  (and (not (isPointUnderComment startPoint)) (not (isPointUnderComment endPoint)))
	())
      )))




(defun areWeInsideParens ()
  "Determine if we are inside parens"
  (interactive)
  (save-excursion
    (let ((current-point (point)) (new-point))
      (setq new-point (progn (my-up-list) (point)))
      (/= new-point current-point)
	)
  )
)

(defun vhdl-extreme-search-for-component (lib-path component-name)
  (let (
        (vhdl-file-list (f-files lib-path nil t))
        (counter 0)
        selected-file
        entity-name
        found)
    (while (and (nth counter vhdl-file-list) (not found))
      (setq selected-file (nth counter vhdl-file-list))
      (if (f-ext? selected-file "vhd")
          (with-current-buffer (find-file-noselect selected-file)
            (save-excursion
              (setq entity-name (s-downcase (whdl-get-entity-or-package-name)))
              (if (s-equals? (s-downcase component-name) entity-name)
                  (setq found t)
                )
              ))
          )
      (setq counter (1+ counter))
      )
    (if found
        selected-file
      nil))
  )

(defun vhdl-extreme-get-component-lib-under-point ()
    "Assumes point is on an instance name"
    (let (
          (current-point (point))
          prev-double-dots
          prev-dot  )
      (save-excursion
        (setq prev-dot (re-search-backward "\\." nil t nil))
        (setq prev-double-dots (re-search-backward "\\:" nil t nil))
        (if (and (< prev-double-dots prev-dot) (< prev-dot current-point))
            t nil
            )
        )
      )
    )

(defun my-up-list ()
  (interactive)
  (let ((s (syntax-ppss)))
    (when (nth 3 s)
      (goto-char (nth 8 s))))
  (ignore-errors (up-list)))

(provide 'vhdl-extreme)
;; TODO : package'in birinde re-search-forward denemeleri yap, component, function, procedure, constant,tye la falan baslamali ve commentli olmamali regexp hadi bakam
