;Time-stamp: <2015-09-15 22:21 EDT by Oleg SHALAEV http://chalaev.com >
(eval-when (:load-toplevel :execute)
  (asdf:operate 'asdf:load-op 'cffi-grovel))

(asdf:defsystem "libconfig"
  :description "CL libconfig interface"
  :long-description  "Common Lisp libconfig interface (requires file libconfig.h from the debian package libconfig-dev). For now has been tested only on linux Debian (jessie and stretch)."
  :author "Oleg Shalaev http://chalaev.com"
  :mailto "chalaev@gmail.com"
  :licence "Public Domain"
  :version "0"
  :defsystem-depends-on ("cffi-grovel")
  :depends-on ("cffi")
  :serial t
  :components ((:file "package")
	       (cffi-grovel:grovel-file "grovel")
	       (:file "API")
	       (:file "libconfig")))
