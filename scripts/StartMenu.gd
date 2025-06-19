extends Node2D

@onready var small_confirm = preload("res://scenes/Menus/SmallConfirmDialog.tscn").instantiate()

@onready var main_menu = $CenterContainer/VBoxContainer
@onready var controls_panel = $CenterContainer/ControlsPanel
@onready var music_player = $music_player
@onready var reset_save = $ResetButton

func _ready():
	music_player.stream = load("res://Audio/music/EndGame.wav")
	music_player.play()
	
	small_confirm.confirmed.connect(_do_reset_progress)
	small_confirm.canceled.connect(_on_cancel_canceled)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/main.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_controls_pressed():
	main_menu.visible = false
	controls_panel.visible = true

func _on_back_pressed():
	controls_panel.visible = false
	main_menu.visible = true

func _on_reset_button_pressed():
	add_child(small_confirm)
	small_confirm.set_text("Are you sure you want to erase all progress?")
	small_confirm.popup_centered()

func _do_reset_progress():
	GlobalProgress.reset_endings()
	GlobalProgress.reset_progress()
	print("Progress reset!")

func _on_cancel_canceled():
	print("Reset canceled")
