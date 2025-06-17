extends Area2D

signal interacted

@export var lore_id: String
@export var lore_text: Array[String]
@export var is_secret: bool = false

var used := false

func _ready():
	add_to_group("lore_objects")

func is_lore_source() -> bool:
	return true

func get_lore_id() -> String:
	return lore_id

func get_lore_text() -> Array[String]:
	return lore_text

func handle_interaction(player: Node) -> void:
	if used:
		return
	used = true

	emit_signal("interacted", self)
