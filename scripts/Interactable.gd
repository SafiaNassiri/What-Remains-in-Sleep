#Interactable.gd

extends Area2D

@export var interactable_name: String
@export_enum("message", "reveal_item") var interact_type := "message"
@export var message_text: String = ""

var player_in_area := false
var main_node: Node = null

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	# Try to auto-find main.gd if not manually set
	if main_node == null:
		main_node = get_tree().root.get_node("main") 

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		body.current_interactable = interactable_name

func _on_body_exited(body):
	if body.name == "Player" and body.current_interactable == interactable_name:
		player_in_area = false
		body.current_interactable = ""

func handle_interaction(player):
	match interact_type:
		"message":
			player.ui.show_message(message_text)
		"reveal_item":
			if main_node:
				main_node.reveal_hidden_item(interactable_name)
