;; libconfig/tests/change.lisp Time-stamp: <2016-08-03 20:18 EDT by Oleg SHALAEV http://chalaev.com >

(ql-util:copy-file "read-1.conf" "change.conf")
(ql:quickload :libconfig)

(libconfig:with-rw-config-file "change.conf"
  (format t "material= ~s.~%" (libconfig:read-setting "material"  :default "GaAs"))
  (libconfig:remove-setting "kpAmplitudes")
  (libconfig:write-structure "anArray" '(10 20 30 40)))

(quit)
