(defun read-conf-string (cfgStruc paramName); moved here from libconfig.lisp
  (cffi:with-foreign-pointer-as-string (ant 255)
    (cffi:with-foreign-pointer (buf psi); pointer to a pointer
      (if (= config-false (%lookupString cfgStruc paramName buf))
	(case (cffi:foreign-slot-value cfgStruc '(:struct config-t) 'error-type)
	  (:config-err-file-io (error 'conf-file-read-error "could not read config file"))
	  (:config-err-parse   (error 'config-parse-error  "parse error on config file ~s, line ~d: ~s"
				      (cffi:foreign-slot-value cfgStruc '(:struct config-t) 'error-file)
				      (cffi:foreign-slot-value cfgStruc '(:struct config-t) 'error-line)
				      (cffi:foreign-slot-value cfgStruc '(:struct config-t) 'error-text)))
	  (otherwise  (error "unspecified libconfig error, perhaps the specified parameter not found" )))
	(setf ant (cffi:mem-ref buf :pointer))))))

;; usage example:
;; (defparameter cfg (libconfig:create-conf-from-file "test-3.conf"))
;; (libconfig:read-conf-string cfg "material")
;; (libconfig:destroy-conf-object cfg)
