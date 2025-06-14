extends Area2D

var main_node: Node = null
var player_in_area: bool = false

# Track if player already used the exit this run
var interacted_this_run := false

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_area = true
		body.current_interactable_node = self

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_area = false
		if body.current_interactable_node == self:
			body.current_interactable_node = null

func handle_interaction(player) -> void:
	if interacted_this_run:
		print("Exit already used this run!")
		return
	
	interacted_this_run = true
	print("ExitBlock interaction triggered!")

	if main_node == null:
		print("ERROR: main_node not assigned in ExitBlock")
		return

	# Check if we're on the final run
	if main_node.current_run >= main_node.max_runs:
		var ending = main_node.get_ending()
		await main_node.trigger_ending(ending)
	else:
		await main_node.ui.show_message(["You feel something pulling you away..."])
		await main_node.next_run()

func reset_interaction() -> void:
	interacted_this_run = false
