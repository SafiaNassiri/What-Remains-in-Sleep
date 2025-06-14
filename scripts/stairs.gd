extends Area2D

signal player_entered
signal player_exited

@export var main_node: Node

@onready var player: Node = get_tree().root.get_node("main/Player")
@onready var ui: Node = get_tree().root.get_node("main/UI")

func _ready() -> void:
	if not ui.has_signal("message_done"):
		push_error("UI node does not have signal 'message_done'. Check the script!")
	else:
		ui.message_done.connect(_on_message_done)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.current_interactable_node = self
		emit_signal("player_entered")

func _on_body_exited(body: Node) -> void:
	if body.name == "Player" and body.current_interactable_node == self:
		body.current_interactable_node = null
		emit_signal("player_exited")

func handle_interaction(player_node: Node) -> void:
	print("Stairs interaction triggered.")

	if not main_node:
		printerr("stairs.gd: No main_node assigned!")
		return

	if main_node.check_win_condition_1():
		print("Win condition met. Ending game...")
		await main_node.end_game()
	else:
		print("Win condition NOT met. Displaying message...")
		player.movement_locked = true
		ui.show_message(["I feel like I'm missing something still."])
		# Don't await; let message_done signal handle unlocking
		print("Message triggered.")

func _on_message_done() -> void:
	if player:
		player.movement_locked = false
