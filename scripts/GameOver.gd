extends Node2D

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/main.tscn")
	

func _on_quit_to_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/StartMenu.tscn")
