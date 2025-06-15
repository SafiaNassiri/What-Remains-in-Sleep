# Interactable.gd
extends Area2D

@export var interactable_name: String
@export var can_reveal_item: bool = true
@export_enum("message", "reveal_item", "static") var interact_type := "message"
@export_enum("neutral", "secret", "bad") var ending_tag: String = "neutral"

var player_in_area := false
var main_node: Node = null

func _ready() -> void:
	main_node = get_tree().get_current_scene()

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_area = true
		body.current_interactable_node = self

func _on_body_exited(body: Node) -> void:
	if body.name == "Player" and body.current_interactable_node == self:
		player_in_area = false
		body.current_interactable_node = null

func handle_interaction(player: Node) -> void:
	var ui = main_node.get_node("UI")
	if not ui: return

	match interact_type:
		"message":
			var lore = main_node.ItemData.lore_snippets.get(interactable_name, [])
			if lore.size() > 0:
				await ui.show_message([lore[randi() % lore.size()]])
			main_node.register_lore_interaction(interactable_name)

		"reveal_item":
			if not can_reveal_item: return
			var revealed = main_node.reveal_hidden_item(interactable_name)
			if revealed:
				var lore = main_node.ItemData.lore_snippets.get(interactable_name, [])
				if lore.size() > 0:
					await ui.show_message([lore[randi() % lore.size()]])
				main_node.register_lore_interaction(interactable_name)
