;; libconfig/libconfig.lisp Time-stamp: <2016-07-03 13:44 EDT by Oleg SHALAEV http://chalaev.com >
;; Please report bugs/suggestions to chalaev@gmail.com
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

(define-condition conf-entry-not-found (error) ((message :initarg :message :reader message)))
(define-condition conf-file-read-error (error) ((message :initarg :message :reader message)))
(define-condition config-parse-error   (error) ((message :initarg :message :reader message)))
;; ← to do: make these condition classes more sophisticated

(defun read-conf-file (fileName cfg)
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
    (read-conf-file fileName cfg)
    cfg))
;; Syntax: (create-conf-from-file fileName)
;; Creates configuration object (see libconfig manual) and reads conf-file into this object.
;; Returns this configuration object.

(defun destroy-conf-object (cfg)  "frees the memory allocated for the config-t object"
  (%ConfigDestroy cfg)
  (cffi-sys:foreign-free cfg))

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

(defun read-structure (cfgS); high-level reader, reads any structures, including nested
  (let ((stt (cffi:foreign-slot-value cfgS '(:struct config-setting-t) 'type)))
    (if
     (or
      (equal stt :config-type-list); may be I should change "equal"→"=" here
      ;; (equal stt :config-type-none)
      (equal stt :config-type-array))
     (loop for i from 0 for element = (setting-nth cfgS i) while (not (cffi-sys:null-pointer-p element)) collect (read-structure element))
     (case stt
       (:config-type-group
	(let ((table (make-hash-table :test 'equal))); add ":synchronized t" (experimental feature for multithreading) here?
	  (loop for i from 0 for element = (setting-nth cfgS i) while (not (cffi-sys:null-pointer-p element))
	     do (setf (gethash (intern (string-upcase (setting-name element))) table) (read-structure element)))
	  table))
       (:config-type-float (%getFloat cfgS))
       (:config-type-int (%getInt cfgS))
       (:config-type-int64 (%getLong cfgS))
       (:config-type-string (%getString cfgS))
       (:config-type-bool (%getBool cfgS))
       (otherwise  (error "libconfig: unknown structure type ~a" stt)))))); tested 2016-07-02

(defmacro with-read-config-file (name &rest body)
  (setf cfg (gensym)) (setf root (gensym)) ; unique variable names, also used in other macros
  `(let* ((,cfg (create-conf-from-file ,name));; will raise exception on error
	  (,root (%config-root-setting ,cfg)))
     (progn ,@body)
    (destroy-conf-object ,cfg)))

(defmacro read-setting (parName &key (default)); to be used from inside of with-read-config-file
  `(let ((confstruc (config-lookup-from ,root ,parName)))
     (if (cffi-sys:null-pointer-p confstruc)
	 ,default
	 (read-structure confstruc))))

(defun read-file (fName); high-level reader, reads whole file
  (read-structure (%config-root-setting (create-conf-from-file fName)))); tested 2016-06-01
;; ← should it (destroy-conf-object cfg) ?

(defmacro with-write-config-file (name &rest body)
  (setf root (gensym))
  `(let* ((cfg (create-empty-conf));; will raise exception on error
	  (,root (%config-root-setting cfg)))
       (progn ,@body)
       (write-conf-file ,name cfg)
       (destroy-conf-object cfg)))

(defmacro with-rw-config-file (name &rest body)
  (setf cfg (gensym)) (setf root (gensym)) ; unique variable names, also used in other macros
  `(let* ((,cfg (create-conf-from-file ,name));; will raise exception on error
	  (,root (%config-root-setting ,cfg)))
       (progn ,@body)
       (write-conf-file ,name ,cfg)
       (destroy-conf-object ,cfg)))

(defun new-list-elem (parent val)
  "adds i-th element to the parent list"
  (typecase val
    (integer (%config-set-int-elem    parent -1 val))
    (boolean (%config-set-bool-elem   parent -1 val))
    (string  (%config-set-string-elem parent -1 val))
    (cons ; new list element is a list itself
     (let ((child (%config-add-parent parent 'nil :config-type-list)))
       (loop for i from 0 to (1- (length value)) do
	    (new-list-elem child (nth i value)))))
    (hash-table ; new list element is a hash table
     (let ((child (%config-add-parent parent 'nil :config-type-group)))
       (maphash #'(lambda (k v) (new-group-elem child (remove #\Space (format 'nil " ~S" key)) val)) value)))
    (otherwise ; single-float or double-float or ratio
     (%config-set-float-elem  parent -1 (coerce val 'double-float)))))

(defun new-group-elem (parent key value)
  "adds named (by the string key) element to the parent group"
  (let* ((Cstr (cffi:foreign-string-alloc key))
	  (child (config-lookup-from parent Cstr)) (res))
    (unless (cffi-sys:null-pointer-p child) (config-remove-setting parent Cstr))
    (setf child (%config-add-setting parent Cstr
       (typecase value
	 (integer :config-type-int)
	 (string :config-type-string)
	 (boolean :config-type-bool)
	 (cons :config-type-list)
	 (hash-table :config-type-group)
	 (otherwise  :config-type-float)))) ; single-float or double-float or ratio
    (typecase value
      (integer  (%config-set-int child value))
      (boolean (%config-set-bool child value))
      (string
       (foreign-string-free Cstr); reusing Cstr
       (setf Cstr (cffi:foreign-string-alloc value))
       (%config-set-string child Cstr))
      (cons
       (loop for i from 0 to (1- (length value)) do
		  (new-list-elem child (nth i value))))
      (hash-table
       (maphash #'(lambda (key val)
		    (new-group-elem child (remove #\Space (format 'nil " ~S" key)) val)) value))
      (otherwise  ; single-float or double-float or ratio
       (%config-set-float child (coerce value 'double-float))))))

(defmacro write-structure (parName val) ; to be used instead of simple-write
  "writes arbitrary data to the config file"
  `(new-group-elem ,root ,parName ,val))

(defmacro remove-setting (parName) ; to be used instead of simple-write
  "removes a setting from the config file"
  `(config-remove-setting  ,root ,parName))
