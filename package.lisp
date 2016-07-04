;; libconfig/package.lisp Time-stamp: <2016-05-18 10:16 EDT by Oleg SHALAEV http://chalaev.com >
;; The functions below are classified as "high-level" and "low-level".
;; The low-level ones I try to do as short as possible on the cost of safety (error handling).
;; For the high-level functions I try to provide error handling.
(defpackage libconfig
    ;; (:nicknames :cl-libconfig)
    (:use :common-lisp :cffi)
    (:export
     #:read-file
     #:write-new #:config-lookup #:config-lookup-from  ; tmp
     #:conf-entry-not-found #:conf-file-read-error #:config-parse-error ; conditions
     #:with-read-config-file #:with-write-config-file #:read-setting #:write-new
     #:create-conf-from-file #:read-structure ; high-level macros and functions
     #:destroy-conf-object
     #:read-conf-file #:explain-error ; low-level functions
     #:read-conf-string #:read-conf-float #:create-empty-conf
     #:read-subconf-string #:read-subconf-int #:read-subconf-long #:read-subconf-float #:read-subconf-bool
     #:setting-type #:setting-name #:setting-length #:setting-nth)) ; low-level functions

(cffi:define-foreign-library libconfig (t (:default "libconfig")))
(cffi:use-foreign-library libconfig)
