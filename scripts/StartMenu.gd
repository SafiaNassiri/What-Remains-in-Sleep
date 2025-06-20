extends Node2D

@onready var small_confirm = preload("res://scenes/Menus/SmallConfirmDialog.tscn").instantiate()

@onready var main_menu = $CenterContainer/VBoxContainer
@onready var controls_panel = $CenterContainer/ControlsPanel
@onready var endings_panel = $EndingsPanel
@onready var endings_list = $EndingsPanel/VBoxContainer/EndingsList
@onready var music_player = $music_player

var all_endings = [
	"all_everything",
	"hoarder",
	"story_collector",
	"neutral_full",
	"all_items",
	"still_stuck",
	"dumb"
]

func _ready():
	controls_panel.visible = false
	endings_panel.visible = false
	
	music_player.stream = load("res://Audio/music/EndGame.wav")
	music_player.play()

	small_confirm.confirmed.connect(_do_reset_progress)
	small_confirm.canceled.connect(_on_cancel_canceled)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/Menus/main.tscn")

func _on_controls_pressed():
	main_menu.visible = false
	controls_panel.visible = true

func _on_back_pressed():
	controls_panel.visible = false
	main_menu.visible = true

func _on_quit_pressed():
	get_tree().quit()

func _on_reset_button_pressed():
	add_child(small_confirm)
	small_confirm.set_text("Are you sure you want to erase all progress?")
	small_confirm.popup_centered()

func _do_reset_progress():
	GlobalProgress.reset_endings()
	GlobalProgress.reset_progress()
	
	GlobalProgress._load_endings()
	_refresh_endings_list()
	
	print("Progress reset!")

func _on_cancel_canceled():
	print("Reset canceled")

func _on_view_endings_pressed():
	main_menu.visible = false
	endings_panel.visible = true
	_refresh_endings_list()

func _on_close_endings_pressed():
	endings_panel.visible = false
	main_menu.visible = true

func _refresh_endings_list():
	if endings_list == null:
		print("❌ endings_list is not assigned!")
		return

	endings_list.clear()

	# Reload endings from disk - optional if already loaded
	GlobalProgress._load_endings()

	var unlocked = GlobalProgress.unlocked_endings
	print("✅ Unlocked endings to display:", unlocked)

	# Make sure all_endings has all endings
	print("All possible endings:", all_endings)

	# Show each ending with checkbox or placeholder
	for ending in all_endings:
		var is_collected : bool = ending in unlocked
		var prefix := "☑ " if is_collected else "🟪 "
		endings_list.add_item(prefix + ending)

	# Add spacer and progress summary
	endings_list.add_item("")  # Spacer
	endings_list.add_item("Progress: %d / %d endings unlocked" % [unlocked.size(), all_endings.size()])
