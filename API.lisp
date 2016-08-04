;; -*-coding: utf-8;-*-
;; libconfig/API.lisp Time-stamp: <2016-07-03 13:12 EDT by Oleg SHALAEV http://chalaev.com >
;; see /usr/include/libconfig.h
(in-package #:libconfig)
(cffi:defcfun ("config_init" init-conf-object) :void (cfgP :pointer))
(cffi:defcfun ("config_destroy" %ConfigDestroy) :void (cfgP :pointer)); frees memory
(cffi:defcfun ("config_read_file" %configReadFile)  :int  (cfgP :pointer) (configFileName :string))
(cffi:defcfun ("config_write_file" %configWriteFile)  :int  (cfgP :pointer) (configFileName :string))

;; Function: config_setting_t * config_setting_add (config_setting_t * parent, const char * name, int type)
(cffi:defcfun ("config_setting_add" %config-add-setting) :pointer (cfgP :pointer) (property :string) (type CStype))
;; Function: int config_setting_remove (config_setting_t * parent, const char * name)
(cffi:defcfun ("config_setting_remove" config-remove-setting) :int (cfgP :pointer) (property :string))

(cffi:defcfun ("config_setting_get_elem" setting-nth) :pointer (cfgP :pointer) (index :int))
(cffi:defcfun ("config_setting_get_member" %getGroupMember) :pointer (cfgP :pointer) (property :string))
(cffi:defcfun ("config_setting_get_int"  %getInt) :int  (cfgP :pointer))
(cffi:defcfun ("config_setting_get_int64" %getLong) :long  (cfgP :pointer))
(cffi:defcfun ("config_setting_get_float" %getFloat) :double (cfgP :pointer))
(cffi:defcfun ("config_setting_get_string" %getString) :string (cfgP :pointer))
(cffi:defcfun ("config_setting_get_bool" %getBool) :boolean (cfgP :pointer))

;; Function: config_setting_t * config_lookup (const config_t * config, const char * path)
(cffi:defcfun ("config_lookup" config-lookup) :pointer (cfgP :pointer) (property :string))
;; Function: config_setting_t * config_setting_lookup (const config_setting_t * setting, const char * path)

;;======================== libconfig-dev version incompatibility: ver.1.4.9 vs ver.1.5.0
(if (and (= verAPI-major 1) (< verAPI-minor 5)); config_lookup_from was renamed into config_setting_lookup
    (cffi:defcfun ("config_lookup_from" config-lookup-from) :pointer (cfgP :pointer) (property :string))
    (cffi:defcfun ("config_setting_lookup" config-lookup-from) :pointer (cfgP :pointer) (property :string)))

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

;; begin new block 2016-08-03
;; Function: config_setting_t * config_setting_set_int_elem (config_setting_t * setting, int index, int value)
;; Function: config_setting_t * config_setting_set_int64_elem (config_setting_t * setting, int index, long long value)
;; Function: config_setting_t * config_setting_set_float_elem (config_setting_t * setting, int index, double value)
;; Function: config_setting_t * config_setting_set_bool_elem (config_setting_t * setting, int index, int value)
;; Function: config_setting_t * config_setting_set_string_elem (config_setting_t * setting, int index, const char * value)
(cffi:defcfun ("config_setting_set_int_elem" %config-set-int-elem) :pointer (cs :pointer) (i :int) (value :int)); tested 2016-08-03
(cffi:defcfun ("config_setting_set_int64_elem" %config-set-int64-elem) :pointer (cs :pointer) (i :int) (value :long))
(cffi:defcfun ("config_setting_set_float_elem" %config-set-float-elem) :pointer (cs :pointer) (i :int) (value :double))
(cffi:defcfun ("config_setting_set_bool_elem" %config-set-bool-elem) :pointer (cs :pointer) (i :int) (value :boolean))
(cffi:defcfun ("config_setting_set_string_elem" %config-set-string-elem) :pointer (cs :pointer) (i :int) (value :string))
;; end new block 2016-08-03

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
