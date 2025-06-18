extends Node2D

@onready var music_player = $music_player
@onready var ending_label = $CenterContainer/VBoxContainer/EndingLabel

func _ready():
	music_player.stream = load("res://Audio/music/EndGame.wav")
	music_player.play()
	
	var ending_number = GlobalProgress.last_ending_number
	if ending_number > 0:
		ending_label.text = "Ending: %d/6" % ending_number
	else:
		ending_label.text = "Unknown Ending"

func _on_retry_pressed():
	GlobalProgress.reset_progress()
	get_tree().change_scene_to_file("res://scenes/Menus/main.tscn")

func _on_quit_to_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/StartMenu.tscn")
