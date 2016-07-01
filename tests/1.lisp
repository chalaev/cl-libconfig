;; libconfig/tests/1.lisp Time-stamp: <2016-06-01 18:06 EDT by Oleg SHALAEV http://chalaev.com >
;; reading data from a real-life configuration file also used by a C++ program
;; TODO: test with http://www.hyperrealm.com/libconfig/test.cfg.txt

(defparameter homeDir (namestring (user-homedir-pathname)))
(ql:quickload :libconfig)

(libconfig:with-read-config-file "1.conf"
  (format t "This is the configuration file for ~s.~%" (libconfig:read-setting "material"  :default "GaAs")))
;;  ==> This is the configuration file for "CdTe".

;; The following creates a simple config file ~/tmp.conf:
(libconfig:with-write-config-file (concatenate 'string homeDir "tmp.conf")
  (libconfig:write-new "param1" 1.234 :type :config-type-float); transformed into double float
  (libconfig:write-new "param2" "I am a string" :type :config-type-string)
  (libconfig:write-new "param3" 3 :type :config-type-int))

(libconfig:with-read-config-file (concatenate 'string homeDir "tmp.conf")
  (format t "Let us check what we wrote (param2): ~s.~%" (libconfig:read-setting "param2")))

(quit)
