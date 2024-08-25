extends Node

const FILE_PATH = "user://config.ini"

var config = ConfigFile.new()

var saved = {
	"highscore" : 0
}

func _ready() -> void:
	check_file()

func check_file() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		for save in saved:
			config.set_value("GAME", save, saved[save])
		
		config.save(FILE_PATH)
	else:
		config.load(FILE_PATH)

func _save(section : String, key : String, value):
	config.set_value(section, key, value)
	
	config.save(FILE_PATH)

func _load(section : String):
	var settings = {}
	
	for key in config.get_section_keys(section):
		settings[key] = config.get_value(section, key)
	
	return settings
