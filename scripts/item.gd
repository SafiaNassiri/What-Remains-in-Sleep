# item.gd
extends Node2D

@export var interaction_message: String = "Press [E] to pick up."
@export var lore_text: String = ""

@onready var icon_texture: Texture2D = $Sprite2D.texture

signal interacted

func handle_interaction(player) -> void:
	if interaction_message != "":
		await player.ui.show_message([interaction_message])

	if lore_text != "":
		await player.ui.show_message([lore_text])

	if player.has_method("collect_item"):
		player.collect_item(self)

	# Tell player you're no longer interactable before freeing
	if player.current_interactable_node == self:
		player.current_interactable_node = null
		player.interactables_in_range.erase(self)

	queue_free()
