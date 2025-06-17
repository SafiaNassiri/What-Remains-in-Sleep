extends CanvasLayer

signal typing_done
signal message_done
signal message_closed

@onready var panel = $Panel
@onready var label = $Panel/Label
@onready var item_panel = $Panel2
@onready var item_display = $Panel2/CenterContainer/ItemDisplay

var full_text := ""
var char_index := 0
var typing_speed := 0.03
var typing_timer: Timer
var is_typing := false
var is_message_active := false

func _ready() -> void:
	typing_timer = Timer.new()
	typing_timer.one_shot = false
	add_child(typing_timer)
	typing_timer.timeout.connect(_on_typing_timer_timeout)

func show_message(pages: Array) -> void:
	if typeof(pages) == TYPE_STRING:
		pages = [pages]

	is_message_active = true
	panel.visible = true

	for page in pages:
		_start_typing(page)
		while is_typing:
			await get_tree().process_frame
			if Input.is_action_just_pressed("ui_accept"):
				label.text = full_text
				is_typing = false
				typing_timer.stop()
				emit_signal("typing_done")

		await _wait_for_input("ui_accept")

	_clear_message()
	emit_signal("message_closed")

func _start_typing(text: String) -> void:
	full_text = text
	char_index = 0
	label.text = ""
	is_typing = true
	typing_timer.wait_time = typing_speed
	typing_timer.start()

func _on_typing_timer_timeout() -> void:
	if char_index < full_text.length():
		label.text += full_text[char_index]
		char_index += 1
	else:
		typing_timer.stop()
		is_typing = false
		emit_signal("typing_done")

func _wait_for_input(action: String) -> void:
	while not Input.is_action_just_pressed(action):
		await get_tree().process_frame
	await get_tree().process_frame

func _clear_message() -> void:
	panel.visible = false
	is_message_active = false
	label.text = ""
	typing_timer.stop()

func add_item_to_display(texture: Texture2D) -> void:
	if not texture:
		push_warning("add_item_to_display received null texture")
		return

	if not item_panel.visible:
		item_panel.visible = true

	var icon = TextureRect.new()
	icon.texture = texture
	icon.stretch_mode = TextureRect.STRETCH_KEEP
	icon.size = texture.get_size()
	item_display.add_child(icon)
