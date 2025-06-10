extends Control

func _ready() -> void:
	var logger : BonionLoggingUtils = BonionLoggingUtils.new()
	logger.add_log("Testing!",logger.LOGSEVERITY.DEBUG)
	logger.add_log("Testing!",logger.LOGSEVERITY.INFO)
	logger.add_log("Testing!",logger.LOGSEVERITY.ERROR)
	logger.add_log("Testing!",logger.LOGSEVERITY.WARNING)
	logger.add_log("Testing!",logger.LOGSEVERITY.ALERT)
