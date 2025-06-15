extends Node2D

# --- Nodes & Resources ---
@onready var player = $Player
@onready var ui = $UI
@onready var exit_trigger = $Triggers/Exit
@onready var fade_rect = $UI/FadeRect

# --- Game State ---
var current_run := 1
var max_runs := 3

# Track collected items this run
var collected_items := []

# --- Scene Setup ---
func _ready() -> void:
	player.ui = ui
	player.movement_locked = true

	fade_rect.color = Color(0, 0, 0, 1)  # fully black at start
	fade_rect.visible = true
	await fade_in_screen(1.0)

	exit_trigger.main_node = self

	# Connect interactable signals for items already in scene
	_connect_interactables()

	await _intro_messages()

	player.movement_locked = false

# --- Connect all interactables in the scene to handle their signals ---
func _connect_interactables() -> void:
	var current_run_node = $Interactibles.get_child(current_run - 1)
	if current_run_node == null:
		return

	var target = Callable(self, "_on_interactable_interacted")

	for node in current_run_node.get_children():
		if node.has_signal("interacted") and not node.is_connected("interacted", target):
			node.connect("interacted", target)

func _update_run_visibility() -> void:
	var runs = $Interactibles.get_children()
	for run_node in runs:
		run_node.visible = false
		run_node.set_process(false)
	
	if current_run <= runs.size():
		var current_run_node = runs[current_run - 1]  # runs is array of Run1, Run2, Run3 nodes
		current_run_node.visible = true
		current_run_node.set_process(true)

# Called when an interactable or item emits the interacted signal
func _on_interactable_interacted(item) -> void:
	if item != null and item.has_method("get_name"):
		var item_name = item.get_name()
		if item not in collected_items:
			collected_items.append(item)
			# Optionally log or update UI here
			print("Collected item:", item_name)
			# Maybe update UI, inventory, etc.
	# You can add other game logic here for interaction effects

# --- Intro ---
func _intro_messages() -> void:
	await ui.show_message(["I don't remember how I got here..."])
	await ui.show_message(["I fell asleep, I think."])
	await ui.show_message(["It's been dark for so long..."])
	await ui.show_message(["And now, I'm just... here."])
	await ui.show_message(["Maybe I should look around. Find something..."])
	await ui.show_message(["or someone."])

# --- Run Progression ---
func next_run() -> void:
	current_run += 1
	player.movement_locked = true

	await fade_out_screen(1.0)

	# Reset player position
	player.global_position = Vector2(26, 133)
	collected_items.clear() # reset collected items on new run

	exit_trigger.reset_interaction()

	_update_run_visibility()
	_connect_interactables()

	await fade_in_screen(1.0)
	player.movement_locked = false

func end_game() -> void:
	await ui.show_message(["You've collected all memories... You wake up."])
	player.movement_locked = true
	await fade_out_screen(1.0)
	get_tree().change_scene("res://scenes/Menus/GameOver.tscn")

# --- Ending Calculation ---
func get_ending() -> String:
	# Example: check items for secret ending
	for item in collected_items:
		if item.name == "SecretMemory":
			return "secret"
	if collected_items.size() == 0:
		return "dumb"
	# Default neutral
	return "neutral"

func trigger_ending(ending: String) -> void:
	player.movement_locked = true

	match ending:
		"secret":
			await fade_out_screen(1.0)
			await ui.show_message(["Secret Ending Unlocked!"])
		"bad":
			await fade_out_screen(1.0)
			await ui.show_message(["Bad Ending..."])
		"neutral":
			await fade_out_screen(1.0)
			await ui.show_message(["Neutral Ending. You wake up, memories fading..."])
		"dumb":
			await fade_out_screen(1.0)
			await ui.show_message(["You didn't collect anything... Maybe try again."])

	get_tree().change_scene_to_file("res://scenes/Menus/GameOver.tscn")

# --- Screen Fade In/Out ---
func fade_out_screen(duration := 1.0) -> void:
	fade_rect.color.a = 0
	fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished

func fade_in_screen(duration := 1.0) -> void:
	fade_rect.color.a = 1.0
	fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration)
	await tween.finished
	fade_rect.visible = false

# --- Debug ---
func debug_log_interactables() -> void:
	for node in get_tree().get_current_scene().get_children():
		if node is Area2D:
			print("Interactable: ", node.name)
