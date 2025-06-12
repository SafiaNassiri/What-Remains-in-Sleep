#ExitBlock.gd

extends Area2D

var main_node

func _on_body_entered(body):
	if body.name != "Player":
		return
	
	if main_node and main_node.has_method("next_run"):
		main_node.call_deferred("next_run")
	else:
		print("ERROR: main_node is null or missing method.")
