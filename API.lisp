;; -*-coding: utf-8;-*-
;; libconfig/API.lisp Time-stamp: <2015-11-03 14:43 EST by Oleg SHALAEV http://chalaev.com >
;; see /usr/include/libconfig.h
(in-package #:libconfig)
;; for every function I write a short comment indicating where it is used
(cffi:defcfun ("config_init" init-conf-object) :void (cfgP :pointer))
(cffi:defcfun ("config_destroy" %ConfigDestroy) :void (cfgP :pointer))
(cffi:defcfun ("config_read_file" %configReadFile)  :int  (cfgP :pointer) (configFileName :string))
(cffi:defcfun ("config_write_file" %configWriteFile)  :int  (cfgP :pointer) (configFileName :string))

;; Function: config_setting_t * config_setting_add (config_setting_t * parent, const char * name, int type)
(cffi:defcfun ("config_setting_add" %config-add-setting) :pointer (cfgP :pointer) (property :string) (type CStype))
;; Function: int config_setting_remove (config_setting_t * parent, const char * name)
(cffi:defcfun ("config_setting_remove" %config-remove-setting) :int (cfgP :pointer) (property :string))

(cffi:defcfun ("config_setting_get_elem" setting-nth) :pointer (cfgP :pointer) (index :int))
(cffi:defcfun ("config_setting_get_member" %getGroupMember) :pointer (cfgP :pointer) (property :string))
(cffi:defcfun ("config_setting_get_int"  %getInt) :int  (cfgP :pointer))
(cffi:defcfun ("config_setting_get_int64" %getLong) :long  (cfgP :pointer))
(cffi:defcfun ("config_setting_get_float" %getFloat) :double (cfgP :pointer))
(cffi:defcfun ("config_setting_get_string" %getString) :string (cfgP :pointer))
(cffi:defcfun ("config_setting_get_bool" %getBool) :boolean (cfgP :pointer))

;; Function: config_setting_t * config_lookup (const config_t * config, const char * path)
;;(cffi:defcfun ("config_lookup" config-lookup) :pointer (cfgP :pointer) (property :string)); ; memory fault !!!
;;     This function locates the setting in the configuration config specified by the path path. It returns a pointer to the config_setting_t structure on success, or NULL if the setting was not found.

;; Function: config_setting_t * config_setting_lookup (const config_setting_t * setting, const char * path)
(cffi:defcfun ("config_lookup_from" config-lookup-from) :pointer (cfgP :pointer) (property :string))
;; This function locates a setting by a path path relative to the setting setting. It returns a pointer to the config_setting_t structure on success, or NULL if the setting was not found.

;; I do not understand why one needs config_setting_lookup_string function, if there are config_setting_get_* ? →
;; These functions look up the value of the child setting named name of the setting setting. They store the value
;; at value and return CONFIG_TRUE on success. If the setting was not found or if the type of the value did not
;; match the type requested, they leave the data pointed to by value unmodified and return CONFIG_FALSE. →
(cffi:defcfun ("config_setting_lookup_string" %CSlookupString)  :int (cfgP :pointer) (property :string) (value :pointer))
(cffi:defcfun ("config_setting_lookup_int" %CSlookupInt)  :int (cfgP :pointer) (property :string) (value :pointer))
(cffi:defcfun ("config_setting_lookup_int64" %CSlookupLong)  :int (cfgP :pointer) (property :string) (value :pointer))
(cffi:defcfun ("config_setting_lookup_float" %CSlookupFloat)  :int (cfgP :pointer) (property :string) (value :pointer))
(cffi:defcfun ("config_setting_lookup_bool" %CSlookupBool)  :int (cfgP :pointer) (property :string) (value :pointer))

(defconstant psi (cffi-sys:%foreign-type-size :pointer))

;; todo -- error treatment: what if
;; a) the property type does not coincide with the fuction called or
;; b) the value has wrong type?
(cffi:defcfun ("config_setting_set_int" %config-set-int) :int (cfgP :pointer) (value :int)); tested
(cffi:defcfun ("config_setting_set_string" %config-set-string) :int (cfgP :pointer) (value :string))
;;Function: int config_setting_set_string (config_setting_t * setting, const char * value)
(cffi:defcfun ("config_setting_set_int64" %config-set-int64) :int (cfgP :pointer) (value :long))
(cffi:defcfun ("config_setting_set_float" %config-set-float) :int (cfgP :pointer) (value :double))
(cffi:defcfun ("config_setting_set_bool" %config-set-bool) :int (cfgP :pointer) (value :boolean))

;;==================
;; the following functions duplicate functionality of the above defined ones:
;; These functions look up the value of the setting in the configuration config specified by the path path. They store the value of the setting at value and return
;; CONFIG_TRUE on success. If the setting was not found or if the type of the value did not match the type requested, they leave the data pointed to by value
;; unmodified and return CONFIG_FALSE. →
(cffi:defcfun ("config_lookup_string" %lookupString) :int (cfgP :pointer) (property :string) (value :pointer))
(cffi:defcfun ("config_lookup_int"    %lookupInt) :int (cfgP :pointer) (property :string) (value :pointer))
(cffi:defcfun ("config_lookup_int64" %lookupLong) :int (cfgP :pointer) (property :string) (value :pointer))
(cffi:defcfun ("config_lookup_float" %lookupFloat)   :int (cfgP :pointer) (property :string) (value :pointer))
(cffi:defcfun ("config_lookup_bool" %lookupBool)    :int (cfgP :pointer) (property :string) (value :pointer))
;; usage example:
;; (defparameter cfg (libconfig:create-conf-from-file "test-3.conf"))
;; (libconfig:read-conf-string cfg "material")
;; (libconfig:destroy-conf-object cfg)


;;==============
;; STYLE-WARNING:
;; bare references to struct types are deprecated. Please use
;; (:POINTER (:STRUCT CONFIG-T)) or
;; (:STRUCT CONFIG-T) instead.

;; (defun config-error (cfgStruc) (warn "config-error is not yet written")); to be written

;; http://www.hyperrealm.com/libconfig/libconfig_manual.html
;; Function: void config_set_options (config_t *config, int options)
;; Function: int config_get_options (config_t *config)
;; ...... etc.
