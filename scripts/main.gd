extends Node2D

# --- Nodes & Resources ---
@onready var player = $Player
@onready var ui = $UI
@onready var exit_trigger = $Triggers/Exit
@onready var fade_rect = $UI/FadeRect

# --- Game State ---
var current_run := 1
var max_runs := 3
var unlocked_items: Array[String] = []
var collected_items: Array[String] = []
var unlocked_secrets: Array[String] = []
var interacted_secret_lore: Array[String] = []

# --- Scene Setup ---
func _ready() -> void:
	player.ui = ui
	player.movement_locked = true

	if has_node("Interactables"):
		_update_run_visibility()
	else:
		push_error("Missing node: 'Interactables'. Check your scene hierarchy.")

	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.visible = true
	await fade_in_screen(1.0)

	_connect_lore_objects()
	
	exit_trigger.main_node = self

	await _intro_messages()
	player.movement_locked = false

func _update_run_visibility() -> void:
	var runs = $Interactables.get_children()
	for run_node in runs:
		run_node.visible = false
		run_node.set_process(false)
		# Disable interaction (e.g., disable collision and signals)
		_disable_interaction(run_node)
	
	if current_run <= runs.size():
		var current_run_node = runs[current_run - 1]
		current_run_node.visible = true
		current_run_node.set_process(true)
		_enable_interaction(current_run_node)

# Recursively disable interactions
func _disable_interaction(run_node: Node) -> void:
	_set_interaction_enabled(run_node, false)

# Recursively enable interactions
func _enable_interaction(run_node: Node) -> void:
	_set_interaction_enabled(run_node, true)

func _set_interaction_enabled(node: Node, enabled: bool) -> void:
	if node is Area2D:
		node.set_monitoring(enabled)

		# Disable all CollisionShape2D children
		for shape in node.get_children():
			if shape is CollisionShape2D:
				shape.disabled = not enabled

	# If your interactables have a method like this, call it too
	if node.has_method("set_interactable_enabled"):
		node.set_interactable_enabled(enabled)

	# Recursively check children (e.g. in case there are nested nodes)
	for child in node.get_children():
		_set_interaction_enabled(child, enabled)

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

	if current_run > max_runs:
		await fade_out_screen(1.0)
		var ending = get_ending()
		trigger_ending(ending)
		return

	await fade_out_screen(1.0)

	player.global_position = Vector2(26, 133)
	exit_trigger.reset_interaction()

	_update_run_visibility()
	_connect_lore_objects()

	await fade_in_screen(1.0)
	player.movement_locked = false

func end_game() -> void:
	await ui.show_message(["You've collected all memories... You wake up."])
	player.movement_locked = true
	await fade_out_screen(1.0)
	get_tree().change_scene("res://scenes/Menus/GameOver.tscn")

# --- Ending Calculation ---
func get_ending() -> String:
	var total_memories := get_total_memory_count()
	var total_secret_memories := get_total_secret_memory_count()
	
	var collected_non_secret := 0
	for id in unlocked_items:
		if id not in unlocked_secrets:
			collected_non_secret += 1
	
	var collected_secret := unlocked_secrets.size()
	var secret_interacted := interacted_secret_lore.size()
	
	print("DEBUG: total_memories = %d" % total_memories)
	print("DEBUG: total_secret_memories = %d" % total_secret_memories)
	print("DEBUG: collected_non_secret = %d" % collected_non_secret)
	print("DEBUG: collected_secret = %d" % collected_secret)
	print("DEBUG: secret_interacted = %d" % secret_interacted)

	if collected_non_secret == 0:
		return "void"
	
	# Check secretPlus ending first
	if collected_non_secret == (total_memories - total_secret_memories) and \
		collected_secret == total_secret_memories and \
		secret_interacted == total_secret_memories:
		return "secretPlus"
	
	# Check secret ending (all secrets and non-secrets collected, but maybe not all secret lore interacted)
	if collected_non_secret == (total_memories - total_secret_memories) and \
		collected_secret == total_secret_memories:
		return "secret"
	
	# Check waking (all non-secret memories collected)
	if collected_non_secret == (total_memories - total_secret_memories):
		return "waking"
	
	# Else fading (some collected)
	return "fading"

func get_total_memory_count() -> int:
	var total := 0
	for run in $Interactables.get_children():
		for node in run.get_children():
			if node.is_in_group("lore_objects"):
				total += 1
	return total

func get_total_secret_memory_count() -> int:
	var total := 0
	for run in $Interactables.get_children():
		for node in run.get_children():
			if node.is_in_group("lore_objects") and node.is_secret:
				total += 1
	return total

func trigger_ending(ending: String) -> void:
	player.movement_locked = true
	print("DEBUG: Triggering ending: %s" % ending)

	match ending:
		"secret":
			await fade_out_screen(1.0)
			await ui.show_message(["You remembered *everything.* Even what was hidden."])
			await ui.show_message(["The dream breaks open into something *more.*"])
		"waking":
			await fade_out_screen(1.0)
			await ui.show_message(["You remember the faces, the places, the feelings."])
			await ui.show_message(["You wake up whole."])
		"fading":
			await fade_out_screen(1.0)
			await ui.show_message(["You remember something... but not all."])
			await ui.show_message(["You wake up, but it feels unfinished."])
		"void":
			await fade_out_screen(1.0)
			await ui.show_message(["You wake up... with nothing."])
			await ui.show_message(["Empty. Lost. Again."])

	get_tree().change_scene_to_file("res://scenes/Menus/GameOver.tscn")

func _connect_lore_objects() -> void:
	if not has_node("Interactables"):
		push_error("Missing node: 'Interactables'")
		return
	
	var interactables = $Interactables
	if current_run - 1 >= interactables.get_child_count():
		push_error("Current run index is out of bounds.")
		return

	var current_run_node = interactables.get_child(current_run - 1)
	if current_run_node == null:
		return

	for node in current_run_node.get_children():
		if node.is_in_group("lore_objects"):
			if not node.is_connected("interacted", Callable(self, "_on_lore_object_interacted")):
				node.connect("interacted", Callable(self, "_on_lore_object_interacted"))

func _on_lore_object_interacted(source_node: Node) -> void:
	if not source_node or not source_node.has_method("get_lore_id"):
		return

	var lore_id = source_node.get_lore_id()
	if lore_id in unlocked_items:
		return  # already unlocked

	unlocked_items.append(lore_id)
	print("DEBUG: Unlocked lore item: %s" % lore_id)

	# Directly access the exported property
	if source_node.is_secret:
		unlocked_secrets.append(lore_id)
		if lore_id not in interacted_secret_lore:
			interacted_secret_lore.append(lore_id)

	var lore_text = source_node.get_lore_text()
	await ui.show_message(lore_text)

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
