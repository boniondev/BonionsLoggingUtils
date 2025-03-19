class_name BonionFileUtils extends GDScript

static var _SAVEFOLDERNAME    : String = "BonionFileUtils_saves"
static var _SAVEFOLDERPATH    : String = "user://" + _SAVEFOLDERNAME
static var _SAVEFILEPATH      : String = _SAVEFOLDERPATH + "/"

func check_all() -> void:
	check_dir(_DIRTYPE.LOG)
	check_dir(_DIRTYPE.CONFIG)


#region Directory creation and checking

enum _DIRTYPE{
	SAVE,
	LOG,
	CONFIG
}

static func make_dir(path : String) -> int:
	var err : int = DirAccess.make_dir_absolute(path)
	if err != OK:
		printerr("BonionFileUtils could not create directory " + path)
		return err
	else:
		return OK


static func check_dir(which : int) -> int:
	var path : String
	match which:
		_DIRTYPE.SAVE:
			path = _SAVEFOLDERPATH
		_DIRTYPE.LOG:
			path = _LOGFOLDERPATH
		_DIRTYPE.CONFIG:
			path = _CONFIGFOLDERPATH
	var exists : bool = DirAccess.dir_exists_absolute(path)
	if !exists:
		return make_dir(path)
	else:
		return OK
#endregion


#region Logging
const _LOGFOLDERNAME              : String = "BonionFileUtils_logs"
const _LOGFOLDERPATH              : String = "user://" + _LOGFOLDERNAME
const _LOGFILESPATH               : String = _LOGFOLDERPATH + "/"
static var   _MAXLOGFILES         : int    = 5

func setMAXLOGFILES(number : int) -> void:
	_MAXLOGFILES = number

enum LOGSEVERITY {
	## Every event that occurs frequently or recursively
	DEBUG,
	## An event that is useful to log but doesn't happen often, I.E one time signal emits
	INFO,
	## An event that was not supposed to happen, but doesn't affect the game in any way
	WARNING,
	## An event that affects things under the hood and may or may not cause problems
	ALERT,
	## An event that stops the game from working or requires immediate action. Usually preludes the closing of the game.
	ERROR
}
var _LOGSEVERITYDICT : Dictionary = {
	LOGSEVERITY.DEBUG   : "DEBUG",
	LOGSEVERITY.INFO    : "INFO",
	LOGSEVERITY.WARNING : "WARNING",
	LOGSEVERITY.ALERT   : "ALERT",
	LOGSEVERITY.ERROR   : "ERROR",
}

enum FILENAME {
	
}
var FILENAMEDICT : Dictionary = {
	
}

## @experimental
func add_log_new(contents : String, severity : int, filename : String) -> void:
	check_dir(_DIRTYPE.LOG)
	var file : FileAccess
	var path : String
	if FileAccess.file_exists(_LOGFILESPATH + ".log"):
		path = _LOGFILESPATH + ".log"
		file = FileAccess.open(path,FileAccess.READ_WRITE)
		file.seek_end()
	else:
		path = _LOGFILESPATH + filename + ".log"
		file = FileAccess.open(path,FileAccess.WRITE)
	if file == null:
		printerr("BonionFileUtils could not write to " + path)
		return
	file.store_string(str(Time.get_ticks_msec()) + "|")
	file.store_string("[" + Time.get_time_string_from_system() + "]" + "|")
	file.store_string(_LOGSEVERITYDICT.get(severity) + "|")
	file.store_string(contents)
	file.store_string("\n")
	file.close()

#endregion


#region Configuration file handling and creation
const _CONFIGFOLDERNAME  : String = "BonionFileUtils_configs"
const _CONFIGFOLDERPATH  : String = "user://" + _CONFIGFOLDERNAME
const _CONFIGFILESPATH   : String = _CONFIGFOLDERPATH + "/"

const _SYSTEMSETTINGSFILENAME : String = "systemsettings.json"


#endregion
