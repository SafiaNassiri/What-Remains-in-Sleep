#Interactable.gd
extends Area2D

# --- Exported properties ---
@export var interactable_name: String
@export var can_reveal_item: bool = true
@export_enum("message", "reveal_item") var interact_type := "message"
@export_enum("neutral", "secret", "bad") var ending_tag: String = "neutral"

# --- Runtime state ---
var player_in_area: bool = false
var main_node: Node = null

func _ready() -> void:
	if main_node == null:
		main_node = get_tree().get_current_scene()
	print("Interactable ", interactable_name, " has main_node: ", main_node)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_area = true
		body.current_interactable_node = self

func _on_body_exited(body: Node) -> void:
	if body.name == "Player" and body.current_interactable_node == self:
		player_in_area = false
		body.current_interactable_node = null

func handle_interaction(player: Node) -> void:
	print("Picked up interactable: ", interactable_name)
	if not main_node:
		return

	var ui = main_node.get_node("UI")
	if not ui:
		return

	# Only proceed if it's a revealable item
	if interact_type == "reveal_item" and can_reveal_item:
		# Reveal item only if not already revealed
		var already_revealed: bool = not main_node.reveal_hidden_item(interactable_name)
		if already_revealed:
			return  # Don't show message again

		# Show the one-time interaction message
		var lore = main_node.ItemData.lore_snippets.get(interactable_name, [])
		if lore.size() > 0:
			await ui.show_message([lore[randi() % lore.size()]])
		
		# Optionally register the lore interaction after showing
		main_node.register_lore_interaction(interactable_name)
