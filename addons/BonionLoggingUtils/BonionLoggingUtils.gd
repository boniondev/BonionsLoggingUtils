class_name BonionLoggingUtils extends GDScript

## A class used to print logs. Must be instantiated by using [method GDScript.new] to be used.[br]
## Logs will be stored in user://BonionLoggingUtils_logs/.[br]
## This class also creates and uses user://BonionLoggingUtils_config.json
## to store and retrieve the following data:[br]
## - MAXLOGFILES: When the number of logs goes past this number,
## the oldest one is deleted before making a new one.[br]
## - AUTOSAVEONEXIT: If this is true, the log will only be saved before the instantiated object of this class
## dereferenced, deleted, or freed from memory in any way.[br]
## - printTICKS: Whether to print the current ticks since the engine started when printing the log.[br]
## - printTIME: Whether to print the current time when printing the log.[br]

const _PERSISTENTPATH  : String = "user://BonionLoggingUtils_config.json"
var _buffer            : String

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _buffer != null and _buffer != "" and _AUTOSAVEONEXIT:
			var file = FileAccess.open(_LOGFILESPATH + "latest.log", FileAccess.WRITE_READ)
			file.store_string(_buffer)
			file.close()

func _init() -> void:
	var persistentfile : FileAccess = FileAccess.open(_PERSISTENTPATH,FileAccess.READ_WRITE)
	if persistentfile != null:
		var configdata : Dictionary = JSON.parse_string(persistentfile.get_as_text()) as Dictionary
		_MAXLOGFILES    = configdata.get_or_add("MAXLOGFILES" , 5)
		_AUTOSAVEONEXIT = configdata.get_or_add("AUTOSAVEONEXIT", true)
		_printTICKSMSEC = configdata.get_or_add("printTICKSMSEC", true)
		_printTIME      = configdata.get_or_add("printTIME", true)
		_logginglevel   = configdata.get_or_add("logginglevel", 0)
		persistentfile.close()
	else:
		persistentfile = FileAccess.open(_PERSISTENTPATH, FileAccess.WRITE)
		var configdata : Dictionary = {
			"MAXLOGFILES"    : 5,
			"AUTOSAVEONEXIT" : true,
			"printTICKSMSEC" : true,
			"printTIME"      : true,
			"logginglevel"   : 0,
		}
		persistentfile.store_string(JSON.stringify(configdata, "\t"))
		persistentfile.close()
		_check_dir()
	_sortlogs()

enum _JSONINDEX {
	MAXLOGFILES,
	AUTOSAVEONEXIT,
	printTICKSMSEC,
	printTIME,
	logginglevel,
}
func _update_json(index : int, value : Variant) -> void:
	var persistentfile : FileAccess = FileAccess.open(_PERSISTENTPATH,FileAccess.READ_WRITE) 
	var configdata : Dictionary = JSON.parse_string(persistentfile.get_as_text()) as Dictionary
	match index:
		_JSONINDEX.MAXLOGFILES:
			configdata.set("MAXLOGFILES", value)
		_JSONINDEX.AUTOSAVEONEXIT:
			configdata.set("AUTOSAVEONEXIT", value)
		_JSONINDEX.printTICKSMSEC:
			configdata.set("printTICKSMSEC", value)
		_JSONINDEX.printTIME:
			configdata.set("printTIME", value)
		_JSONINDEX.logginglevel:
			configdata.set("logginglevel", value)
	persistentfile.seek(0)
	persistentfile.store_string(JSON.stringify(configdata))
	persistentfile.close()

#region Directory creation and checking

func _make_dir(path : String) -> int:
	var err : int = DirAccess.make_dir_absolute(path)
	if err != OK:
		printerr("BonionLoggingUtils could not create directory " + path)
		return err
	else:
		return OK


func _check_dir() -> int:
	var exists : bool = DirAccess.dir_exists_absolute(_LOGFOLDERPATH)
	if !exists:
		return _make_dir(_LOGFOLDERPATH)
	else:
		return OK
#endregion


#region Logging
const      _LOGFOLDERNAME              : String = "BonionLoggingUtils_logs"
const      _LOGFOLDERPATH              : String = "user://" + _LOGFOLDERNAME
const      _LOGFILESPATH               : String = _LOGFOLDERPATH + "/"
static var _AUTOSAVEONEXIT             : bool   = true
var        _MAXLOGFILES                : int    = 5
var        _printTICKSMSEC             : bool   = true
var        _printTIME                  : bool   = true
var        _logginglevel               : int    = 0


## Varying levels of log severities, along with guidelines as to how and when to use them.
enum LOGSEVERITY {
	## Events that occurs frequently or recursively.
	DEBUG,
	## Events that are useful to log but don't happen often.
	INFO,
	## Events that were not supposed to happen, but don't affect the game in any way.
	WARNING,
	## Events that may or may not affect the proper execution of the game.
	ALERT,
	## Catastrophic events that stop the execution of the game in its tracks.[br]
	##Use this to inform yourself or the player what went wrong if you make it so the game closes. 
	ERROR
}
var _LOGSEVERITYDICT : Dictionary = {
	LOGSEVERITY.DEBUG   : "DEBUG",
	LOGSEVERITY.INFO    : "INFO",
	LOGSEVERITY.WARNING : "WARNING",
	LOGSEVERITY.ALERT   : "ALERT",
	LOGSEVERITY.ERROR   : "ERROR",
}

#region Setters

## The logger will save to disk before it gets deleted from memory, but you may disable it if you wish.[br]
## Remember to use [method save_log] if you disable autosaving.[br]
## Set save to [code]true[/code] if you wish to enable this globally.
func setAUTOSAVEONEXIT(value : bool, save : bool = false) -> void:
	_AUTOSAVEONEXIT = value
	if save:
		_update_json(_JSONINDEX.AUTOSAVEONEXIT, value)

## Change the number of maximum log files.[br]
## Set save to [code]true[/code] if you wish to enable this globally.
func setMAXLOGFILES(number : int, save : bool = false) -> void:
	_MAXLOGFILES = number
	if save:
		_update_json(_JSONINDEX.MAXLOGFILES, number)

## Change whether or not to print the milliseconds since the engine started in the log.[br]
## Set save to [code]true[/code] if you wish to enable this globally.
func set_printTICKSMSEC(value : bool, save : bool = false) -> void:
	_printTICKSMSEC = value
	if save:
		_update_json(_JSONINDEX.printTICKSMSEC, value)

## Change whether or not to print the current time in the log.[br]
## Set save to [code]true[/code] if you wish to enable this globally.
func set_printTIME(value : bool, save : bool = false) -> void:
	_printTIME = value
	if save:
		_update_json(_JSONINDEX.printTIME, value)

## Change the logging level. Logs under this severity will NOT be printed.[br]
## Set save to [code]true[/code] if you wish to enable this globally.
func set_logginglevel(value : int, save : bool = false) -> void:
	_logginglevel = value
	if save:
		_update_json(_JSONINDEX.logginglevel, value)

#endregion

## Writes the current log buffer to disk. You don't need to call this method unless you turn off autosaving.
func save_log() -> bool:
	var file = FileAccess.open(_LOGFILESPATH + "latest.log", FileAccess.WRITE_READ)
	file.store_string(_buffer)
	file.close()
	_buffer = ""
	return true

## Adds a log to the buffer. Log text prints the milliseconds since the engine started, the current time, the [param severity] of the log, and the [param contents].
func add_log(contents : String, severity : int) -> void:
	if severity >= _logginglevel:
		if _printTICKSMSEC:
			_buffer = _buffer + str(Time.get_ticks_msec()) + "|"
		if _printTIME:
			_buffer = _buffer + "[" + Time.get_time_string_from_system() + "]" + "|"
		_buffer = _buffer + _LOGSEVERITYDICT.get(severity) + "|"
		_buffer = _buffer + contents
		_buffer = _buffer + "\n"

func _sortlogs() -> void:
	var files : PackedStringArray = DirAccess.get_files_at(_LOGFILESPATH)
	var pathtolatest : String = _LOGFILESPATH + "latest.log"
	if files.size() == _MAXLOGFILES:
		DirAccess.remove_absolute(_LOGFILESPATH + files[0])
	if files.size() > 0 and files.has("latest.log"):
		var err : Error = DirAccess.rename_absolute(pathtolatest, _LOGFILESPATH + "bonionlog" + Time.get_datetime_string_from_system().replace(":", ".") + ".log")
	files = DirAccess.get_files_at(_LOGFILESPATH)

#endregion
