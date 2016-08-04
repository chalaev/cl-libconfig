;; libconfig/tests/read.lisp Time-stamp: <2016-08-03 19:02 EDT by Oleg SHALAEV http://chalaev.com > 
(ql:quickload :libconfig)

;; Simplest usage: read one non-nested parameter from a simple config file:
(libconfig:with-read-config-file "read-1.conf"
  (format t "material= ~s.~%" (libconfig:read-setting "material"  :default "GaAs"))); default value is used if the setting is not found
;;  ==> material= "CdTe".

;; Somewhat more advanced usage with exception handling.
;; The code below is cut from another project, see
;; https://github.com/chalaev/esy/blob/master/start.lisp
(handler-case ; there will be an exception (condition) in case "read-2.conf" is unreadable
(libconfig:with-read-config-file "read-2.conf" ; see comments in read-2.conf
  (defparameter hosts  (libconfig:read-setting "hosts" :default (list "workstation")))
  (defparameter *logLevel*  (libconfig:read-setting "logLevel" :default 0))
  (defparameter *log-file*  (libconfig:read-setting "logFile" :default "/tmp/esy-test-libconfig.log"))
  (defparameter maxFilesPerDir  (libconfig:read-setting "maxFilesPerDir" :default 50))
  (defparameter maxFileSize  (libconfig:read-setting "maxFileSize" :default "1m"))
  (defparameter maxDirRecursion  (libconfig:read-setting "maxDirRecursion" :default 7))
  (defparameter importantFiles (libconfig:read-setting "importantFiles"  :default '("*.txt$" "*.org$" "*.tex$" "*.lisp$")))
  (defparameter importantGroups (libconfig:read-setting "importantGroups" :default '("important")))
  (defparameter junkGroups      (libconfig:read-setting "junkGroups" :default '("tmp")))
  (defparameter junkFiles       (libconfig:read-setting "junkFiles" :default '("tmp*" "*.tmp$" "*.lock$" "*.log$" "*.aux$"))))
  (libconfig:conf-file-read-error () (format t "could not read config file~%"))); complain if the file is unreadable

(quit)
