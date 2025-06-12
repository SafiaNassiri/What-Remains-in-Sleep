# EntranceBlock.gd

extends Area2D

@onready var player = null
@onready var ui = null

func _ready():
	player = get_tree().root.get_node("main/Player")
	ui = get_tree().root.get_node("main/UI")

	if ui.has_signal("message_done"):
		ui.message_done.connect(_on_message_done)
	else:
		push_error("UI node does not have signal 'message_done'. Check the script!")

func _on_entrance_body_entered(body):
	if body == player:
		player.movement_locked = true
		
		var sprite = player.get_node("PlayerSprite")
		sprite.flip_h = true
		sprite.animation = "run-side"
		
		var tween = create_tween()
		tween.tween_property(player, "global_position", player.global_position + Vector2(25, 0), 0.3)

		tween.finished.connect(func():
			sprite.animation = "idle-down"
			ui.show_message("There is no going back.")
		)

func _on_message_done():
	player.movement_locked = false
