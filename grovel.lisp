;; libconfig/grovel.lisp Time-stamp: <2015-11-07 21:50 EST by Oleg SHALAEV http://chalaev.com >
(in-package #:libconfig)

(define "_GNU_SOURCE")
(include "libconfig.h")
(cc-flags "-lconfig")

;;(cenum (config-error-t :define-constants t)
(cenum config-error-t
       ((:config-err-none "CONFIG_ERR_NONE"))
       ((:config-err-file-io "CONFIG_ERR_FILE_IO"))
       ((:config-err-parse "CONFIG_ERR_PARSE")))

(cenum CStype ; these constants do not need exporting, they are anyway available after the package is loaded
	 ((:config-type-none "CONFIG_TYPE_NONE"))
	 ((:config-type-group "CONFIG_TYPE_GROUP"))
	 ((:config-type-int "CONFIG_TYPE_INT"))
	 ((:config-type-int64 "CONFIG_TYPE_INT64"))
	 ((:config-type-float "CONFIG_TYPE_FLOAT"))
	 ((:config-type-string "CONFIG_TYPE_STRING"))
	 ((:config-type-bool "CONFIG_TYPE_BOOL"))
	 ((:config-type-array "CONFIG_TYPE_ARRAY"))
	 ((:config-type-list "CONFIG_TYPE_LIST")))

;; (constant (config-type-none "CONFIG_TYPE_NONE"))
;; (constant (config-type-group "CONFIG_TYPE_GROUP"))
;; (constant (config-type-int "CONFIG_TYPE_INT"))
;; (constant (config-type-int64 "CONFIG_TYPE_INT64"))
;; (constant (config-type-float "CONFIG_TYPE_FLOAT"))
;; (constant (config-type-string "CONFIG_TYPE_STRING"))
;; (constant (config-type-bool "CONFIG_TYPE_BOOL"))
;; (constant (config-type-array "CONFIG_TYPE_ARRAY"))
;; (constant (config-type-list "CONFIG_TYPE_LIST"))

(cstruct config-setting-t "config_setting_t"
	 (type "type" :type CStype)
;;	 (config-error-t "config_error_t" :type config-error-t)
	 (name "name" :type (:pointer :string)))

(cstruct config-t "config_t"
	 (root "root"  :type (:pointer (:struct config-setting-t)))
	 (error-type "error_type" :type config-error-t)
	 (error-line "error_line" :type :int)
	 (error-file "error_file" :type (:pointer :string))
	 (error-text "error_text" :type (:pointer :string)))

(constant (config-true "CONFIG_TRUE")) ; these constants do not need exporting, they are anyway available after the package is loaded
(constant (config-false "CONFIG_FALSE"))

(constant (verAPI-major "LIBCONFIG_VER_MAJOR"))
(constant (verAPI-minor "LIBCONFIG_VER_MINOR"))
;; (constant (verAPI-revision "LIBCONFIG_VER_REVISION"))
