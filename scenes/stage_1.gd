extends Control

@onready var image_container: GridContainer = $VBoxContainer/Images

@export var images : Array[Texture2D]

func _ready() -> void:
	_choose_images()

func _choose_images() -> void:
	
