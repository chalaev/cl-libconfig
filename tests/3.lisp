;; libconfig/tests/4.lisp Time-stamp: <2016-05-19 22:39 EDT by Oleg SHALAEV http://chalaev.com >
;; reading data from a real-life configuration file
(ql:quickload :libconfig)
(defun print-hash-entry (key value) (format t "The value associated with the key ~S is ~S~%" key value))

(defparameter allData (libconfig:read-file "3.conf"))
(type-of allData); => hash table
(loop for key being the hash-keys of allData do (print key))
(maphash #'print-hash-entry allData)

(quit)
