extends Window

signal confirmed
signal canceled

@onready var yes_button = $HBoxContainer/Yes
@onready var cancel_button = $HBoxContainer/Cancel
@onready var label = $DialogLabel

func _ready():
	close_requested.connect(_on_cancel_pressed)
	
	print("Label node found: ", label)

func set_text(text: String) -> void:
	label.text = text

func _on_yes_pressed():
	emit_signal("confirmed")
	hide()

func _on_cancel_pressed():
	emit_signal("canceled")
	hide()
