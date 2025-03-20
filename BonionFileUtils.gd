class_name BonionFileUtils extends GDScript

static var _SAVEFOLDERNAME    : String = "BonionFileUtils_saves"
static var _SAVEFOLDERPATH    : String = "user://" + _SAVEFOLDERNAME
static var _SAVEFILEPATH      : String = _SAVEFOLDERPATH + "/"

static var _PERSISTENTPATH : String = "user://persistent.bonion"

func check_all() -> void:
	check_dir(_DIRTYPE.LOG)
	check_dir(_DIRTYPE.CONFIG)

enum MODE {
	SAVE,
	LOG,
	CONFIG,
}

func _init(mode : int) -> void:
	match mode:
		MODE.SAVE:
			pass
		MODE.LOG:
			var persistentfile : FileAccess = FileAccess.open(_PERSISTENTPATH,FileAccess.READ_WRITE)
			if persistentfile != null:
				var notfound : bool = true
				while persistentfile.get_position() < persistentfile.get_length():
					# I found something, is it a dictionary?
					var dict : = persistentfile.get_var() as Dictionary
					if dict:
						# It's a dictionary, but is it the right one?
						if dict.get("NAME") == "LOG":
							# It's the right one! I grab what I need, or use a default value
							_MAXLOGFILES = dict.get_or_add("MAXLOGFILES", 5)
							notfound = false
							break # I stop looking
				# If I haven't found it still, I make it
				if notfound:
					var dict : Dictionary = {
						"NAME"        : "LOG",
						"MAXLOGFILES" :     5,
					}
					persistentfile.store_var(dict)
			persistentfile.close()
		MODE.CONFIG:
			pass

#region Directory creation and checking

enum _DIRTYPE{
	SAVE,
	LOG,
	CONFIG
}

func make_dir(path : String) -> int:
	var err : int = DirAccess.make_dir_absolute(path)
	if err != OK:
		printerr("BonionFileUtils could not create directory " + path)
		return err
	else:
		return OK


func check_dir(which : int) -> int:
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
var  _MAXLOGFILES               : int    = 5

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

## @experimental
func add_log(contents : String, severity : int) -> void:
	var file : FileAccess
	var path : String = _LOGFILESPATH + "latest.log"
	if FileAccess.file_exists(path):
		_sortlogs()
	file = FileAccess.open(path,FileAccess.WRITE)
	if file == null:
		printerr("BonionFileUtils could not write to " + path)
		return
	else:
		file.store_string(str(Time.get_ticks_msec()) + "|")
		file.store_string("[" + Time.get_time_string_from_system() + "]" + "|")
		file.store_string(_LOGSEVERITYDICT.get(severity) + "|")
		file.store_string(contents)
		file.store_string("\n")
	file.close()

func _sortlogs() -> void:
	var files : PackedStringArray = DirAccess.get_files_at(_LOGFILESPATH)
	var pathtolatest : String = _LOGFILESPATH + "latest.log"
	if files.size() > 0 and files.has("latest.log"):
		DirAccess.rename_absolute(pathtolatest, _LOGFILESPATH + Time.get_time_string_from_unix_time(FileAccess.get_modified_time(pathtolatest)))
	files = DirAccess.get_files_at(_LOGFILESPATH)
	if files.size() > 4:
		DirAccess.remove_absolute(_LOGFILESPATH + files[files.size()-1])
#endregion


#region Configuration file handling and creation
const _CONFIGFOLDERNAME  : String = "BonionFileUtils_configs"
const _CONFIGFOLDERPATH  : String = "user://" + _CONFIGFOLDERNAME
const _CONFIGFILESPATH   : String = _CONFIGFOLDERPATH + "/"

const _SYSTEMSETTINGSFILENAME : String = "systemsettings.json"


#endregion
