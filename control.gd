extends Control

func _ready() -> void:
	var logger : BonionLoggingUtils = BonionLoggingUtils.new()
	logger.add_log("Testing!",logger.LOGSEVERITY.DEBUG)
	logger.add_log("Testing!",logger.LOGSEVERITY.INFO)
	logger.add_log("Testing!",logger.LOGSEVERITY.ERROR)
	logger.set_logginglevel(logger.LOGSEVERITY.INFO)
	logger.add_log("This shouldn't appear now!", logger.LOGSEVERITY.DEBUG)
	logger.add_log("This should!", logger.LOGSEVERITY.INFO)
	logger = null
