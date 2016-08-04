;; libconfig/tests/write.lisp Time-stamp: <2016-08-03 20:18 EDT by Oleg SHALAEV http://chalaev.com >
(ql:quickload :libconfig)

;; I appreciate libconfig because it is compatible with many data types:
(let ((my-hash (make-hash-table)))
  (setf (gethash 'oneEntry my-hash) "one")
  (setf (gethash 'anotherEntry my-hash) 3/17)
  (libconfig:with-write-config-file "write.conf"
    (libconfig:write-structure "intNumber" 5)
    (libconfig:write-structure "booleanTrue" t)
    (libconfig:write-structure "booleanFalse" 'nil)
    (libconfig:write-structure "aHashTable" my-hash)
    (libconfig:write-structure "aString" "yohoho hahaha")
    (libconfig:write-structure "anArray" '(1 2 3 4))
    (libconfig:write-structure "floatNumber" 1.2345); error is introduced when float is transformed to double
    (libconfig:write-structure "doubleNumber" 1.2345d0)))

;; check what we wrote into the file:
(libconfig:with-read-config-file "write.conf"
  (format t "aHashTable[anotherEntry]=~f,~%" (gethash 'ANOTHERENTRY (libconfig:read-setting "aHashTable")))
  (format t "intNumber=~d,~%" (libconfig:read-setting "intNumber"))
  (format t "aString=~s.~%" (libconfig:read-setting "aString")))

(quit)
