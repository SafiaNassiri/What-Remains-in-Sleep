# EntranceBlock.gd
extends Area2D

@onready var player: Node = get_tree().root.get_node("main/Player")
@onready var ui: Node = get_tree().root.get_node("main/UI")

func _ready() -> void:
	if not ui.has_signal("message_done"):
		push_error("UI node does not have signal 'message_done'. Check the script!")
	else:
		ui.message_done.connect(_on_message_done)

func _on_entrance_body_entered(body: Node) -> void:
	if body == player:
		player.movement_locked = true
		
		var sprite = player.get_node("PlayerSprite")
		sprite.flip_h = true
		sprite.animation = "run-side"
		
		var tween = create_tween()
		tween.tween_property(player, "global_position", player.global_position + Vector2(25, 0), 0.3)
		tween.finished.connect(func():
			sprite.animation = "idle-down"
			ui.show_message(["There is no going back."])
		)

func _on_message_done() -> void:
	player.movement_locked = false
