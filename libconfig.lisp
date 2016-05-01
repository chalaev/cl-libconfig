;; Note: the file is in the middle of reconstruction, see write-new

;; libconfig/libconfig.lisp Time-stamp: <2015-11-03 18:46 EST by Oleg SHALAEV http://chalaev.com >
(in-package #:libconfig)

(defun %config-root-setting (cfgP)
  (cffi:foreign-slot-value cfgP '(:struct config-t) 'root))

(defun %config-setting-type (cfgP)
  (cffi:foreign-slot-value cfgP '(:struct config-setting-t) 'type))

(defun setting-name (subcfg)
  (values (cffi:foreign-string-to-lisp (cffi:foreign-slot-value subcfg '(:struct config-setting-t) 'name))))
(defun setting-type (subcfg)
  (cffi:foreign-slot-value bands-cfg '(:struct config-setting-t) 'type))
(defun setting-length (subcfg)
  (loop for i from 0 for element = (setting-nth subcfg i) while (not (cffi-sys:null-pointer-p element)) summing 1))

;; Let us define exceptions:
(define-condition conf-entry-not-found (error) ((message :initarg :message :reader message)))
(define-condition conf-file-read-error (error) ((message :initarg :message :reader message)))
(define-condition config-parse-error   (error) ((message :initarg :message :reader message)))
;; ← to do: make these condition classes more sophisticated

(defun read-conf-file (fileName cfg); reading config file
  (let ((fName (cffi:foreign-string-alloc fileName)))
    (when (= config-false (%configReadFile cfg fName))
      (case (cffi:foreign-slot-value cfg '(:struct config-t) 'error-type)
	(:config-err-file-io (error 'conf-file-read-error "could not read config file"))
	(:config-err-parse   (error 'config-parse-error  "parse error on config file ~s, line ~d: ~s"
				    (cffi:foreign-slot-value cfg '(:struct config-t) 'error-file)
				    (cffi:foreign-slot-value cfg '(:struct config-t) 'error-line)
				    (cffi:foreign-slot-value cfg '(:struct config-t) 'error-text)))
	(otherwise  (error "unknown libconfig error"))))
    (foreign-string-free fName)))

(defun write-conf-file (fileName cfg) "save configuration to the file"
       (let ((fName (cffi:foreign-string-alloc fileName)))
	 (when (= config-false (%configWriteFile cfg fName))
	   (case (cffi:foreign-slot-value cfg '(:struct config-t) 'error-type)
	     (:config-err-file-io (error 'conf-file-write-error "could not write config file"))
	     (:config-err-parse   (error 'config-parse-error  "parse error on config file ~s, line ~d: ~s"
					 (cffi:foreign-slot-value cfg '(:struct config-t) 'error-file)
					 (cffi:foreign-slot-value cfg '(:struct config-t) 'error-line)
					 (cffi:foreign-slot-value cfg '(:struct config-t) 'error-text)))
	     (otherwise  (error "unknown libconfig error"))))
	 (foreign-string-free fName)))

(defun create-empty-conf () "allocates memory for config-t, initializes it, and returns the pointer"
  (let ((cfg (cffi:foreign-alloc '(:struct config-t))))
    (init-conf-object cfg); this line returns no value
    cfg))

(defun create-conf-from-file (fileName)
  (let ((cfg (create-empty-conf)))
    (read-conf-file fileName cfg); this line returns nil value
    cfg))

(defun destroy-conf-object (cfg)  "frees the memory allocated for the config-t object"
  (%ConfigDestroy cfg)
  (cffi-sys:foreign-free cfg))


(defun read-conf-string (cfgStruc paramName); this function perhaps is not needed because its functionality is duplicated by (more general) read-structure
  (cffi:with-foreign-pointer-as-string (ant 255)
    (cffi:with-foreign-pointer (buf psi); pointer to a pointer
      (if (= config-false (%lookupString cfgStruc paramName buf))
	(case (cffi:foreign-slot-value cfg '(:struct config-t) 'error-type)
	  (:config-err-file-io (error 'conf-file-read-error "could not read config file"))
	  (:config-err-parse   (error 'config-parse-error  "parse error on config file ~s, line ~d: ~s"
				      (cffi:foreign-slot-value cfg '(:struct config-t) 'error-file)
				      (cffi:foreign-slot-value cfg '(:struct config-t) 'error-line)
				      (cffi:foreign-slot-value cfg '(:struct config-t) 'error-text)))
	  (otherwise  (error "unspecified libconfig error, perhaps the specified parameter not found" )))
	(setf ant (cffi:mem-ref buf :pointer))))))
;; ← нужны аналогичные функции д.б. для других типов данных

(defun read-subconf-string (cfgStruc paramName)
  (cffi:with-foreign-pointer-as-string (ant 255)
    (cffi:with-foreign-pointer (buf psi)
      (%CSlookupString cfgStruc paramName buf)
      (setf ant (cffi:mem-ref buf :pointer)))))
(defun read-subconf-int (cfgStruc paramName)
  (cffi:with-foreign-pointer (buf psi)
    (%CSlookupInt cfgStruc paramName buf)
    (cffi:mem-ref buf :int)))
(defun read-subconf-long (cfgStruc paramName)
  (cffi:with-foreign-pointer (buf psi)
    (%CSlookupLong cfgStruc paramName buf)
    (cffi:mem-ref buf :long)))
(defun read-subconf-float (cfgStruc paramName)
  (cffi:with-foreign-pointer (buf psi)
    (%CSlookupFloat cfgStruc paramName buf)
    (cffi:mem-ref buf :double)))
(defun read-subconf-bool (cfgStruc paramName)
  (cffi:with-foreign-pointer (buf psi)
    (%CSlookupBool cfgStruc paramName buf)
    (cffi:mem-ref buf :boolean)))

(defun read-structure (cfgS); high-level reader, reads any structures, including вложенные
  (let ((stt (cffi:foreign-slot-value cfgS '(:struct config-setting-t) 'type)))
    (case stt
      (:config-type-list
       (loop for i from 0 for element = (setting-nth cfgS i) while (not (cffi-sys:null-pointer-p element)) collect (read-structure element)))
      (:config-type-array
       (loop for i from 0 for element = (setting-nth cfgS i) while (not (cffi-sys:null-pointer-p element)) collect (read-structure element)))
      (:config-type-group
       (let ((table (make-hash-table :test 'equal)))
	 (loop for i from 0 for element = (setting-nth cfgS i) while (not (cffi-sys:null-pointer-p element))
	    do (setf (gethash (setting-name element) table) (read-structure element)))
	 table))
      (:config-type-float (%getFloat cfgS))
      (:config-type-int (%getInt cfgS))
      (:config-type-long (%getLong cfgS))
      (:config-type-string (%getString cfgS))
      (:config-type-bool (%getBool cfgS))
      (otherwise  (error "libconfig: unknown structure type ~a" stt)))))

(defmacro with-read-config-file (name &rest body)
  (setf cfg (gensym)); unique variable name, also used in other macros
  `(let ((cfg (create-conf-from-file ,name)));; will raise exception on error
    (progn ,@body)
    (destroy-conf-object cfg)))
;;************* предстоит реализовать следующие давно задуманные функции
;; (defun sections cFile &key (section 'nil)); по умолчанию исследуем корневой конфиг. каталог
;; ;если речь идёт не о корневой секции, то section -- это массив [секция,подсекция,подподсекция,...]
;; (defun entries cFile &key (section 'nil))
;; (defun getVarible  cFile varName &key (section 'nil))
;; (defun setVarible cFile varName &key (section 'nil))
;; (defun createSection cFile secName &key (section 'nil))
;; ; ещё функции:
;; (defun flush () "" ); записать изменения в конфигурации

(defmacro read-setting (parName &key (default)); to be used from inside of with-read-config-file
  `(let ((confstruc (config-lookup-from cfg ,parName)))
     (if (cffi-sys:null-pointer-p confstruc)
	 ,default
	 (read-structure confstruc))))

(defmacro with-write-config-file (name &rest body)
  (setf root (gensym))
  `(let* ((,cfg (create-empty-conf));; will raise exception on error
	  (,root (%config-root-setting ,cfg)))
       (progn ,@body)
       (write-conf-file ,name ,cfg)
       (destroy-conf-object ,cfg)))

(defmacro write-new (parName value &key type); to be used from inside of with-write-config-file
  ;; where parType is one of atomic config types, e.g., :config-type-int
  ;; if setting already exixsts, it will be overwritten
  "creates and writes the value"
  `(let* ((Cstr (cffi:foreign-string-alloc ,parName))
	  (setting (config-lookup-from ,root Cstr))
	  (res))
     (unless (cffi-sys:null-pointer-p setting)
       (unless (equal (%config-setting-type setting) ,type)
	 (%config-remove-setting ,root Cstr)))
     (when (cffi-sys:null-pointer-p setting)
       (setf setting (%config-add-setting ,root Cstr ,type)))
     (setf res
	   (case ,type
	     (:config-type-int (%config-set-int setting ,value))
	     (:config-type-int64 (%config-set-int64 setting ,value))
	     (:config-type-float
	      (if (sb-int:double-float-p ,value)
		  (%config-set-float setting ,value)
		  (%config-set-float setting (coerce ,value 'double-float))))
	     (:config-type-string
	      (progn
		(foreign-string-free Cstr)
		(setf Cstr (cffi:foreign-string-alloc ,value))
		(%config-set-string setting Cstr)))
	     (:config-type-bool  (%config-set-int setting ,value))))
;;	     (otherwise  (error "wrong parameter type" ))))
     (unless (= config-true res)
       (error 'config-parse-error "could not set set conf parameter"))
     (foreign-string-free Cstr)))
