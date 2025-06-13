#Interactable.gd

extends Area2D

@export var interactable_name: String
@export_enum("message", "reveal_item") var interact_type := "message"

@export var can_reveal_item: bool = true

var player_in_area := false
var main_node: Node = null

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	if main_node == null:
		main_node = get_tree().get_current_scene()
	print("Interactable ", interactable_name, " has main_node: ", main_node)

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		body.current_interactable = interactable_name

func _on_body_exited(body):
	if body.name == "Player" and body.current_interactable == interactable_name:
		player_in_area = false
		body.current_interactable = ""

func handle_interaction(player) -> void:
	match interact_type:
		"message":
			# Do nothing — no messages shown
			pass
		"reveal_item":
			# Do not show initial message or reveal success/fail messages
			if not can_reveal_item:
				return

			if main_node:
				main_node.reveal_hidden_item(interactable_name)
