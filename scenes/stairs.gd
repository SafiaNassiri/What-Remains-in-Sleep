# stairs.gd

extends Area2D

signal player_entered
signal player_exited

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("player_entered")

func _on_body_exited(body):
	if body.name == "Player":
		emit_signal("player_exited")

func handle_interaction(player):
	var main_node = get_tree().get_current_scene()
	if main_node.check_win_condition_1():
		main_node.end_game()
	else:
		player.ui.show_message("I feel like I’m missing something...")
