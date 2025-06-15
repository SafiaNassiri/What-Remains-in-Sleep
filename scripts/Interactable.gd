# interactable.gd
extends Area2D

@export var interaction_message: String = "Press [E] to interact."
@export var message: String = ""
@export var item_scene: PackedScene  # Optional: item to spawn
@export var spawn_offset: Vector2 = Vector2(0, 16)  # Relative to this node
@export var spawn_global_position: Vector2 = Vector2.ZERO  # Absolute position to spawn item; if Vector2.ZERO, use offset

signal interacted(item_spawned)

func _ready():
	set_monitoring(true)
	set_monitorable(true)

func handle_interaction(player) -> void:
	# Show message if there is one
	if interaction_message != "":
		await player.ui.show_message([interaction_message])
	if message != "":
		await player.ui.show_message([message])

	var spawned_item: Node = null

	# Spawn item if set
	if item_scene:
		spawned_item = item_scene.instantiate()
		get_parent().add_child(spawned_item)

		if spawn_global_position != Vector2.ZERO:
			spawned_item.global_position = spawn_global_position
		else:
			spawned_item.global_position = global_position + spawn_offset

	# Emit signal with the spawned item (or null)
	emit_signal("interacted", spawned_item)
