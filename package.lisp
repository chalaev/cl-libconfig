;; libconfig/package.lisp Time-stamp: <2015-11-10 18:44 EST by Oleg SHALAEV http://chalaev.com >

;; TODO: do not export functions which do not appear in the tests/*.lisp

;;
;; The functions below are classified as "high-level" and "low-level".
;; The low-level ones I try to do as short as possible on the cost of safety (error handling).
;; For the high-level functions I try to provide error handling.
;; Naming is a serious issue: I have to name the functions once and forever…
(defpackage libconfig
    (:nicknames :libconfig)
    (:use :common-lisp :cffi)
    (:export
     #:write-new #:config-lookup-from ; tmp
     #:conf-entry-not-found #:conf-file-read-error #:config-parse-error ; conditions
     #:with-read-config-file #:with-write-config-file #:read-setting #:write-new
     #:create-conf-from-file #:config_lookup #:read-structure ; high-level macros and functions
     #:destroy-conf-object
     #:read-conf-file #:explain-error ; low-level functions
     #:read-conf-string #:create-empty-conf
     #:read-subconf-string #:read-subconf-int #:read-subconf-long #:read-subconf-float #:read-subconf-bool
     #:setting-type #:setting-name #:setting-length #:setting-nth)) ; low-level functions

(cffi:define-foreign-library libconfig (t (:default "libconfig")))
(cffi:use-foreign-library libconfig)
