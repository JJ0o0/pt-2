extends Node

@export var ClockTicking : AudioStream
@export var Congratulations : AudioStream

@export_group("Button")
@export var ClickSound : AudioStream
@export var HoverSound : AudioStream

var all_children

var loop_player

func _ready() -> void:
	all_children = get_all_children($"../UI")
	
	button_signals()

func button_signals() -> void:
	for i in all_children:
		if i is Button or i is TextureButton:
			i.mouse_entered.connect(play_sfx.bind(HoverSound))
			i.button_down.connect(play_sfx.bind(ClickSound))

func play_sfx(sfx : AudioStream):
	var player = AudioStreamPlayer.new()
	player.stream = sfx
	
	add_child(player)
	player.play()
	
	player.finished.connect(func(): player.queue_free())

func play_sfx_loop(sfx : AudioStream):
	loop_player = AudioStreamPlayer.new()
	loop_player.stream = sfx
	
	add_child(loop_player)
	loop_player.play()
	
	loop_player.finished.connect(func(): loop_player.play())

func stop_sfx_loop():
	loop_player.queue_free()

func get_all_children(in_node, arr:=[]):
	arr.push_back(in_node)
	
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	
	return arr
