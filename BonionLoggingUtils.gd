class_name BonionLoggingUtils extends GDScript

const _PERSISTENTPATH  : String = "user://BonionLoggingUtils_config.json"
var _file              : FileAccess

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _file != null and _AUTOSAVEONEXIT:
			_file.close()

func _init() -> void:
	var persistentfile : FileAccess = FileAccess.open(_PERSISTENTPATH,FileAccess.READ_WRITE)
	if persistentfile != null:
		var notfound : bool = true
		while persistentfile.get_position() < persistentfile.get_length():
			var dict : = persistentfile.get_var() as Dictionary
			if dict:
				if dict.get("NAME") == "LOG":
					_MAXLOGFILES = dict.get_or_add("MAXLOGFILES", 5)
					notfound = false
					_AUTOSAVEONEXIT = dict.get_or_add("AUTOSAVEONEXIT", true)
					break
		if notfound:
			var dict : Dictionary = {
				"NAME"          : "LOG",
				"MAXLOGFILES"   :     5,
				"AUTOSAVEONEXIT":  true,
			}
			persistentfile.store_var(dict)
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
var        _MAXLOGFILES                : int    = 5
static var _AUTOSAVEONEXIT             : bool   = true

func setMAXLOGFILES(number : int) -> void:
	_MAXLOGFILES = number

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
	## Catastrophic events that stop the execution of the game in its tracks. Use this to inform yourself or the player what went wrong if you make it so the game closes. 
	ERROR
}
var _LOGSEVERITYDICT : Dictionary = {
	LOGSEVERITY.DEBUG   : "DEBUG",
	LOGSEVERITY.INFO    : "INFO",
	LOGSEVERITY.WARNING : "WARNING",
	LOGSEVERITY.ALERT   : "ALERT",
	LOGSEVERITY.ERROR   : "ERROR",
}

## The logger will save to disk before it gets deleted from memory, but you may disable it if you wish. Remember to use [method save_log] if you disable autosaving
func setAUTOSAVE(value : bool) -> bool:
	_AUTOSAVEONEXIT = value
	return _AUTOSAVEONEXIT

## Writes the current log buffer to disk. You don't need to call this method unless you turn off autosave.
func save_log() -> bool:
	if _file != null:
		_file.flush()
		return true
	else:
		return false

## @experimental
func add_log(contents : String, severity : int) -> void:
	var path : String = _LOGFILESPATH + "latest.log"
	if FileAccess.file_exists(path):
		_sortlogs()
	if _file == null:
		_file = FileAccess.open(path,FileAccess.WRITE)
	if _file == null:
		printerr("BonionLoggingUtils could not write to " + path)
		return
	else:
		_file.store_string(str(Time.get_ticks_msec()) + "|")
		_file.store_string("[" + Time.get_time_string_from_system() + "]" + "|")
		_file.store_string(_LOGSEVERITYDICT.get(severity) + "|")
		_file.store_string(contents)
		_file.store_string("\n")

func _sortlogs() -> void:
	var files : PackedStringArray = DirAccess.get_files_at(_LOGFILESPATH)
	var pathtolatest : String = _LOGFILESPATH + "latest.log"
	if files.size() > 0 and files.has("latest.log"):
		DirAccess.rename_absolute(pathtolatest, _LOGFILESPATH + Time.get_time_string_from_unix_time(FileAccess.get_modified_time(pathtolatest)))
	files = DirAccess.get_files_at(_LOGFILESPATH)
	if files.size() > 4:
		DirAccess.remove_absolute(_LOGFILESPATH + files[files.size()-1])
#endregion
