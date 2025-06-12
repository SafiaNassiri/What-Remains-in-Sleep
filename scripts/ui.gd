#ui.gd

extends CanvasLayer

signal message_done

@onready var panel = $Panel
@onready var label = $Panel/MarginContainer/Label

var full_text := ""
var char_index := 0
var typing_speed := 0.03
var typing_timer: Timer = null
var is_typing := false
var message_finished := false
var is_message_active: bool = false

func show_message(text: String) -> void:
	is_message_active = true
	full_text = text
	char_index = 0
	label.text = ""
	panel.visible = true
	is_typing = true
	message_finished = false	
	
	if typing_timer:
		typing_timer.queue_free()
		
	typing_timer = Timer.new()
	typing_timer.wait_time = typing_speed
	typing_timer.one_shot = false
	add_child(typing_timer)
	typing_timer.timeout.connect(_on_typing_timer_timeout)
	typing_timer.start()
	
	await self.message_done
	is_message_active = false
	
func _on_typing_timer_timeout():
	if char_index < full_text.length():
		label.text += full_text[char_index]
		char_index += 1
	else:
		is_typing = false
		message_finished = true
		typing_timer.stop()

func _process(_delta):
	if message_finished and Input.is_action_just_pressed("ui_accept"):
		_on_message_timeout()
	elif is_typing and Input.is_action_just_pressed("ui_accept"):
		# Instantly finish typing
		label.text = full_text
		is_typing = false
		message_finished = true
		typing_timer.stop()

func _on_message_timeout():
	panel.visible = false
	if typing_timer:
		typing_timer.queue_free()
		typing_timer = null
	emit_signal("message_done")
