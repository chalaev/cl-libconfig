;; The code below is cut from another project.
;; Macro with-read-config-file allows reading parameters of different types.
;; If the requested parameter is unspecified in the configuration file
;; the default value is used.

(ql:quickload :libconfig)

(defconstant homeDir (user-homedir-pathname))

(handler-case ; see comments in 2.conf
(libconfig:with-read-config-file "2.conf"
  (defparameter hosts  (libconfig:read-setting "hosts" :default (list hostname)))
  (setf *logLevel*  (libconfig:read-setting "logLevel" :default 0))
  (defparameter *log-file*  (libconfig:read-setting "logFile" :default "/tmp/esy-test-libconfig.log"))
  (defparameter maxFilesPerDir  (libconfig:read-setting "maxFilesPerDir" :default 50))
  (defparameter maxFileSize  (libconfig:read-setting "maxFileSize" :default "1m"))
  (defparameter maxDirRecursion  (libconfig:read-setting "maxDirRecursion" :default 7))
  (defparameter rootdirs   (libconfig:read-setting "rootdirs"        :default '(homeDir)))
  (defparameter importantFiles (libconfig:read-setting "importantFiles"  :default '("*.txt$" "*.org$" "*.tex$" "*.lisp$")))
  (defparameter importantGroups (libconfig:read-setting "importantGroups" :default '("important")))
  (defparameter junkGroups      (libconfig:read-setting "junkGroups" :default '("tmp")))
  (defparameter junkFiles       (libconfig:read-setting "junkFiles" :default '("tmp*" "*.tmp$" "*.lock$" "*.log$" "*.aux$"))))
  (libconfig:conf-file-read-error () (format t "could not read config file~%"))); if the file is unreadable
