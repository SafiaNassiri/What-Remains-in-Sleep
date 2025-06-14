extends Node2D

@onready var main_menu = $CenterContainer/VBoxContainer
@onready var controls_panel = $CenterContainer/ControlsPanel

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_controls_pressed():
	main_menu.visible = false
	controls_panel.visible = true

func _on_back_pressed():
	controls_panel.visible = false
	main_menu.visible = true
