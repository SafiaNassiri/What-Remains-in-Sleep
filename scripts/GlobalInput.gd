extends Node

var confirm_dialog: Window = null

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _quit_game():
	get_tree().quit()
