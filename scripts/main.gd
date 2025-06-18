extends Node2D

# --- Nodes & Resources ---
@onready var player = $Player
@onready var ui = $UI
@onready var exit_trigger = $Triggers/Exit
@onready var fade_rect = $UI/FadeRect
@onready var sfx_player = $sfx_player
@onready var music_player = $music_player
@onready var fade_sfx_player = $fade_sfx_player

# --- Game State ---
var current_run := 1
var max_runs := 3
var collected_items: Array[String] = []
var unlocked_secrets: Array[String] = []
var interacted_lore_neutral: Array[String] = []
var interacted_lore_secret: Array[String] = []
var total_neutral_memories := 0
var total_secret_memories := 0

# --- Scene Setup ---
func _ready() -> void:
	player.ui = ui
	player.movement_locked = true
	
	# Count total memory types and store in GlobalProgress
	var total_neutral_items = 0
	var total_secret_items = 0
	var total_neutral_interactions = 0
	var total_secret_interactions = 0
	
	for run in $Interactables.get_children():
		for node in run.get_children():
			if node.is_in_group("items"):
				if node.is_secret:
					total_secret_items += 1
				else:
					total_neutral_items += 1
			elif node.is_in_group("lore_objects"):
				if node.is_secret:
					total_secret_interactions += 1
				else:
					total_neutral_interactions += 1

	GlobalProgress.set_totals(
		total_neutral_items,
		total_secret_items,
		total_neutral_interactions,
		total_secret_interactions
	)

	play_music("res://Audio/music/runloop.wav")

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
	
	play_sfx("res://Audio/sounds/Runs.wav")
	
	debug_print_progress()

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
	var totals = GlobalProgress.get_totals()
	var progress = GlobalProgress.get_progress()

	var collected_neutral_items = progress["collected_neutral_items"]
	var collected_secret_items = progress["collected_secret_items"]
	var interacted_neutral = progress["interacted_neutral"]
	var interacted_secret = progress["interacted_secret"]

	var total_neutral_items = totals["total_neutral_items"]
	var total_secret_items = totals["total_secret_items"]
	var total_neutral_interactions = totals["total_neutral_interactions"]
	var total_secret_interactions = totals["total_secret_interactions"]

	# 🟩 All items and all interactions (neutral + secret)
	if collected_neutral_items == total_neutral_items and \
	   collected_secret_items == total_secret_items and \
	   interacted_neutral == total_neutral_interactions and \
	   interacted_secret == total_secret_interactions:
		return "all_everything"

	# 🟩 Only items (neutral + secret), no interactions
	if collected_neutral_items == total_neutral_items and \
	   collected_secret_items == total_secret_items and \
	   interacted_neutral == 0 and \
	   interacted_secret == 0:
		return "hoarder"

	# 🟩 Only interactions (neutral + secret), no items
	if collected_neutral_items == 0 and \
	   collected_secret_items == 0 and \
	   interacted_neutral == total_neutral_interactions and \
	   interacted_secret == total_secret_interactions:
		return "story_collector"

	# 🟩 All neutral items and neutral interactions, no secrets at all
	if collected_neutral_items == total_neutral_items and \
	   collected_secret_items == 0 and \
	   interacted_neutral == total_neutral_interactions and \
	   interacted_secret == 0:
		return "neutral_full"

	# 🟩 All neutral items only, no secrets, no interactions
	if collected_neutral_items == total_neutral_items and \
	   collected_secret_items == 0 and \
	   interacted_neutral == 0 and \
	   interacted_secret == 0:
		return "all_items"

	# 🟥 Dumb ending: player literally did nothing
	if collected_neutral_items == 0 and collected_secret_items == 0 and \
	   interacted_neutral == 0 and interacted_secret == 0:
		return "dumb"

	# 🟥 Fallback ending: player missed key neutral stuff
	if collected_neutral_items < total_neutral_items or \
	   interacted_neutral < total_neutral_interactions:
		return "still_stuck"

	return "still_stuck"

func trigger_ending(ending: String) -> void:
	player.movement_locked = true
	
	var item_display = ui.get_node("Panel2/CenterContainer/ItemDisplay")
	if item_display:
		item_display.hide()
	else:
		print("Warning: ItemDisplay node not found in UI/Panel2/CenterContainer")
	
	print("DEBUG: Triggering ending: %s" % ending)

	match ending:
		"all_everything":
			await fade_out_screen(1.0)
			play_music("res://Audio/music/EndGame.wav")
			await ui.show_message(["You pieced it all together. The forgotten. The hidden."])
			await ui.show_message(["You're more than awake now."])
		"hoarder":
			await fade_out_screen(1.0)
			play_music("res://Audio/music/EndGame.wav")
			await ui.show_message(["You have everything... but nothing made sense."])
		"story_collector":
			await fade_out_screen(1.0)
			play_music("res://Audio/music/EndGame.wav")
			await ui.show_message(["You know the story. You lived it in fragments."])
			await ui.show_message(["But you carry nothing out."])
		"neutral_full":
			await fade_out_screen(1.0)
			play_music("res://Audio/music/EndGame.wav")
			await ui.show_message(["You remember what mattered. The surface things."])
			await ui.show_message(["You wake up clean."])
		"all_items":
			await fade_out_screen(1.0)
			play_music("res://Audio/music/EndGame.wav")
			await ui.show_message(["You carried all the pieces... but not the meaning."])
		"still_stuck":
			await fade_out_screen(1.0)
			play_music("res://Audio/music/EndGame.wav")
			await ui.show_message(["You woke up... but something's wrong."])
			await ui.show_message(["You’re not done."])
		"dumb":
			await fade_out_screen(1.0)
			play_music("res://Audio/music/EndGame.wav")
			await ui.show_message(["You wake up, but the world is blank."])
			await ui.show_message(["You remember nothing. You *are* nothing."])

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
	var is_secret = source_node.is_secret

	# Mark interaction regardless of collection status
	if is_secret:
		if lore_id not in interacted_lore_secret:
			interacted_lore_secret.append(lore_id)
			GlobalProgress.add_progress(0, 0, 0, 1)
			print("DEBUG: Interacted with secret lore:", lore_id)
	else:
		if lore_id not in interacted_lore_neutral:
			interacted_lore_neutral.append(lore_id)
			GlobalProgress.add_progress(0, 0, 1, 0)
			print("DEBUG: Interacted with neutral lore:", lore_id)

	var lore_text = source_node.get_lore_text()
	await ui.show_message(lore_text)

# --- Screen Fade In/Out ---
func fade_out_screen(duration := 1.0) -> void:
	var fade_sfx = load("res://Audio/sounds/choirfade.wav") as AudioStream
	if fade_sfx:
		fade_sfx_player.stream = fade_sfx
		fade_sfx_player.play()
		
	fade_rect.color.a = 0
	fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished

func fade_in_screen(duration := 1.0) -> void:
	var fade_sfx = load("res://Audio/sounds/choirfadeR.wav") as AudioStream
	if fade_sfx:
		fade_sfx_player.stream = fade_sfx
		fade_sfx_player.play()
		
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

func play_sfx(sfx_path: String) -> void:
	var sfx = load(sfx_path) as AudioStream
	if sfx:
		sfx_player.stream = sfx
		sfx_player.play()

func play_music(music_path: String) -> void:
	var music = load(music_path) as AudioStream
	if music:
		music_player.stream = music
		music_player.play()

func get_progress_report() -> Dictionary:
	var neutral_items_count = 0
	var secret_items_count = 0

	for id in collected_items:
		var is_secret = false
		for item in get_tree().get_nodes_in_group("items"):
			if item.item_id == id:
				is_secret = item.is_secret
				break
		if is_secret:
			secret_items_count += 1
		else:
			neutral_items_count += 1

	var neutral_lore_count = interacted_lore_neutral.size()
	var secret_lore_count = interacted_lore_secret.size()

	return {
		"collected_neutral_items": neutral_items_count,
		"collected_secret_items": secret_items_count,
		"interacted_neutral": neutral_lore_count,
		"interacted_secret": secret_lore_count
	}

func debug_print_progress() -> void:
	var stats = get_progress_report()
	var totals = GlobalProgress.get_totals()

	print("--- PROGRESS REPORT ---")
	print("Collected Neutral Items: %d / %d" % [
		stats["collected_neutral_items"], totals["total_neutral_items"]
	])
	print("Collected Secret Items: %d / %d" % [
		stats["collected_secret_items"], totals["total_secret_items"]
	])
	print("Interacted Neutral Lore: %d / %d" % [
		stats["interacted_neutral"], totals["total_neutral_interactions"]
	])
	print("Interacted Secret Lore: %d / %d" % [
		stats["interacted_secret"], totals["total_secret_interactions"]
	])
	print("Ending: %s" % get_ending())
