extends Node

@onready var menu_container: VBoxContainer = $UI/PanelContainer/MarginContainer/MenuContainer
@onready var game_container: VBoxContainer = $UI/PanelContainer/MarginContainer/GameContainer
@onready var end_container: VBoxContainer = $UI/PanelContainer/MarginContainer/EndContainer
@onready var explain_container: VBoxContainer = $UI/PanelContainer/MarginContainer/ExplainContainer
@onready var countdown_container: VBoxContainer = $UI/PanelContainer/MarginContainer/CountdownContainer

@onready var word_label: Label = $UI/PanelContainer/MarginContainer/GameContainer/Word
@onready var words2_container: HBoxContainer = $UI/PanelContainer/MarginContainer/GameContainer/HBoxContainer
@onready var word3: RichTextLabel = $UI/PanelContainer/MarginContainer/GameContainer/Word3

@export var images : Dictionary = { "Palavra" : Texture2D.new()}
@export var images_buttons : Array[TextureButton]

var words : Array
var incorrect_words : Array

var correct : TextureButton
var incorrects : Array[TextureButton]

var correct_image : Texture2D
var incorrect_images : Array[Texture2D]

var choosen_word : String
var incorrect_word : String

var score : int
var accerts : int
var errors : int

var on_game : bool

func _ready() -> void:
	var loaded = SaveSystem._load("GAME")
	
	if loaded.highscore > 0:
		%Highscore.show()
		%Highscore.text = "[shake freq=5.0]HIGHSCORE: " + str(loaded.highscore) + "[/shake]"
	else:
		%Highscore.hide()

func _process(_delta: float) -> void:
	if not %Countdown.is_stopped():
		%CountdownLabel.text = str(round(%Countdown.time_left))
	
	if on_game:
		%Timer.text = str(round(%Time.time_left))

func _start() -> void:
	menu_container.hide()
	end_container.hide()
	explain_container.hide()
	
	%Time.start()
	%Countdown.start()
	
	countdown_container.show()

func _game_loop() -> void:
	_choose_word()
	_choose_image()

func _choose_word() -> void:
	words.clear()
	
	for i in images:
		words.append(i)
	
	choosen_word = words.pick_random()
	
	incorrect_words.clear()
	for i in words:
		if i != choosen_word:
			incorrect_words.append(i)
	
	if score >= 100 and score < 140:
		word3.show()
		words2_container.hide()
		word_label.hide()
		
		for i in images_buttons:
			var a = randi_range(0, 3)
			
			match a:
				0:
					i.flip_v = false
					i.flip_h = false
				1:
					i.flip_v = true
					i.flip_h = false
				2:
					i.flip_v = false
					i.flip_h = true
				3:
					i.flip_v = true
					i.flip_h = true
		
		word3.text = "[tornado radius=10.0 freq=1.0 connected=1]" + choosen_word.to_upper() + "[/tornado]"
	elif (score >= 50 and score < 100) or (score >= 140):
		word3.hide()
		words2_container.show()
		word_label.hide()
		
		incorrect_word = incorrect_words.pick_random()
		
		var correct_label = words2_container.get_children().pick_random()
		correct_label.text = choosen_word.to_upper()
		correct_label.label_settings.font_color = Color.GREEN
		
		for i in words2_container.get_children():
			if i != correct_label:
				i.text = incorrect_word.to_upper()
				i.label_settings.font_color = Color.RED
		
		for i in images_buttons:
			i.flip_v = false
			i.flip_h = false
	else:
		word3.hide()
		words2_container.hide()
		word_label.show()
		
		word_label.text = choosen_word.to_upper()
		
		for i in images_buttons:
			i.flip_v = false
			i.flip_h = false

func _choose_image() -> void:
	correct_image = images[choosen_word]
	
	incorrect_images.clear()
	for i in images:
		if i != choosen_word:
			incorrect_images.append(images[i])
	
	correct = images_buttons.pick_random()
	
	incorrects.clear()
	for i in images_buttons:
		if i != correct:
			incorrects.append(i)
	
	if correct.pressed.is_connected(incorrect_answer):
		correct.pressed.disconnect(incorrect_answer)
	elif correct.pressed.is_connected(correct_answer):
		correct.pressed.disconnect(correct_answer)
	
	correct.pressed.connect(correct_answer)
	correct.texture_normal = images[choosen_word]
	
	for i in incorrects:
		var incorrect_image = incorrect_images.pick_random()
		incorrect_images.erase(incorrect_image)
		
		i.texture_normal = incorrect_image
		
		if i.pressed.is_connected(incorrect_answer):
			i.pressed.disconnect(incorrect_answer)
		elif i.pressed.is_connected(correct_answer):
			i.pressed.disconnect(correct_answer)
		
		i.pressed.connect(incorrect_answer)

func correct_answer() -> void:
	if not on_game:
		return
	
	score += 5
	accerts += 1
	
	_game_loop()

func incorrect_answer() -> void:
	if not on_game:
		return
	
	score -= 5
	errors += 1
	
	_game_loop()

func _on_time_timeout() -> void:
	on_game = false
	
	$SFX.stop_sfx_loop()
	$SFX.play_sfx($SFX.Congratulations)
	
	var save = SaveSystem._load("GAME")
	if score > save.highscore:
		%New.show()
		
		SaveSystem._save("GAME", "highscore", score)
	else:
		%New.hide()
	
	menu_container.hide()
	end_container.show()
	game_container.hide()
	explain_container.hide()
	
	%Score.text = "PONTOS: " + str(score)
	%Rights.text = "ACERTOS: " + str(accerts)
	%Errors.text = "ERROS: " + str(errors)

func _on_start_pressed() -> void:
	_start()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_how_pressed() -> void:
	menu_container.hide()
	explain_container.show()

func _on_countdown_timeout() -> void:
	game_container.show()
	countdown_container.hide()
	
	on_game = true
	score = 0
	errors = 0
	accerts = 0
	
	$SFX.play_sfx_loop($SFX.ClockTicking)
	
	_game_loop()
