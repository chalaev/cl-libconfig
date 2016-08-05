;; libconfig/package.lisp Time-stamp: <2016-05-18 10:16 EDT by Oleg SHALAEV http://chalaev.com >
;; The functions below are classified as "high-level" and "low-level".
;; The low-level ones I try to do as short as possible on the cost of safety (error handling).
;; For the high-level functions I try to provide error handling.
(defpackage libconfig
    ;; (:nicknames :cl-libconfig)
    (:use :common-lisp :cffi)
    (:export
     #:with-read-config-file #:with-write-config-file #:with-rw-config-file
     #:read-file #:read-setting #:write-structure  #:remove-setting
     #:conf-file-read-error #:config-parse-error)) ; conditions

(cffi:define-foreign-library libconfig (t (:default "libconfig")))
(cffi:use-foreign-library libconfig)
