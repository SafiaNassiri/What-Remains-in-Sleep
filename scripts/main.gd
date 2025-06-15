extends Node2D

# --- Nodes & Resources ---
@onready var player = $Player
@onready var ui = $UI
@onready var item_panel_container = $UI/Panel2
@onready var item_display = $UI/Panel2/CenterContainer/ItemDisplay
@onready var collectibles = $Collectibles
@onready var layer = $Layers
@onready var exit_trigger = $Triggers/Exit
@onready var fade_rect = $UI/FadeRect

@onready var ItemScene = preload("res://scenes/item.tscn")
@onready var ItemData = preload("res://scripts/item_data.gd").new()
@onready var tileset_texture = preload("res://Sprites&TileMaps/Top-Down_Retro_Interior/TopDownHouse_SmallItems.png")

# --- Game State ---
var current_run := 1
var max_runs := 3
var memory_items_collected := 0
var collected_this_run := []
var collected_item_ids := []
var revealed_hidden_items := {}
var lore_interactions := {}
var collected_tags: Array[String] = []

# --- UI Layout ---
var max_items_per_col := 5

# collection count
var collected_tags_count := {
	"neutral": 0,
	"bad": 0,
	"secret": 0
}

# --- Scene Setup ---
func _ready() -> void:
	player.ui = ui
	player.movement_locked = true
	
	fade_rect.color = Color(0, 0, 0, 1)  # fully black
	fade_rect.visible = true
	await fade_in_screen(1.0)

	exit_trigger.main_node = self
	print("exit_trigger has script:", exit_trigger)

	item_panel_container.visible = false
	spawn_items_for_run(current_run)
	update_item_display_columns()

	await _intro_messages()

	player.movement_locked = false

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

	# Reset player position and collectibles
	player.global_position = Vector2(26, 133)
	for child in collectibles.get_children():
		child.queue_free()

	spawn_items_for_run(current_run)
	exit_trigger.reset_interaction()
	
	await fade_in_screen(1.0)
	player.movement_locked = false

func end_game() -> void:
	await ui.show_message(["You've collected all memories... You wake up."])
	player.movement_locked = true
	await fade_out_screen(1.0)
	get_tree().change_scene("res://scenes/GameOver.tscn")

# --- Item Spawning & Interaction ---
func spawn_items_for_run(run):
	var items = ItemData.data.get(run, [])
	for item in items:
		if item.hidden:
			continue
		var use_sprite2 = item.get("use_sprite2", false)
		spawn_item(item.pos, item.text, item.region_rect, item.interact, item.ending_tag, use_sprite2)

func reveal_hidden_item(interact_name: String) -> bool:
	if revealed_hidden_items.has(interact_name):
		return false

	for item in ItemData.data.get(current_run, []):
		if item.hidden and item.get("interact") == interact_name:
			if item.has("unlock_condition"):
				var cond = item.unlock_condition
				var count = 0
				for name in cond.names:
					count += lore_interactions.get(name, 0)
				if count < cond.required:
					print("Unlock condition not met for:", interact_name)
					return false

			# Passed conditions – spawn item
			var use_sprite2 = item.get("use_sprite2", false)
			spawn_item(item.pos, item.text, item.region_rect, item.interact, item.ending_tag, use_sprite2)
			revealed_hidden_items[interact_name] = true
			return true

	return false

func spawn_item(pos: Vector2, memory_text: String, region: Rect2, interact_name: String = "", ending_tag: String = "neutral", use_sprite2: bool = false) -> Node:
	var item = ItemScene.instantiate()
	item.global_position = pos
	item.memory_text = memory_text
	item.sprite_region = region
	item.texture = tileset_texture
	item.interactable_name = interact_name
	item.ending_tag = ending_tag
	item.main_node = self
	item.use_sprite2 = use_sprite2  
	collectibles.add_child(item)
	print("Spawned item: ", interact_name, " → Tag:", ending_tag, " | use_sprite2:", use_sprite2)
	return item

func register_lore_interaction(name: String) -> void:
	if lore_interactions.has(name):
		lore_interactions[name] += 1
	else:
		lore_interactions[name] = 1

	print("Lore interaction:", name, " → Count:", lore_interactions[name])

func on_item_collected(item) -> void:
	memory_items_collected += 1
	collected_this_run.append(item.memory_text)
	collected_item_ids.append(item.interactable_name)
	collected_tags.append(item.ending_tag)
	
	# Increment count for tag
	if collected_tags_count.has(item.ending_tag):
		collected_tags_count[item.ending_tag] += 1
	else:
		collected_tags_count[item.ending_tag] = 1

	print("Collected:", item.name, " → Tag:", item.ending_tag)

	add_item_icon_to_ui(item.texture, item.sprite_region, item.memory_text)

# --- UI Updates ---
func add_item_icon_to_ui(texture: Texture2D, region: Rect2, memory_text: String) -> void:
	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(16, 16)
	icon.tooltip_text = memory_text

	if region.size != Vector2.ZERO:
		var atlas_tex := AtlasTexture.new()
		atlas_tex.atlas = texture
		atlas_tex.region = region
		icon.texture = atlas_tex
	else:
		icon.texture = texture

	if not item_panel_container.visible:
		item_panel_container.visible = true

	item_display.add_child(icon)
	update_item_display_columns()
	reorder_items_column_first()
	update_item_display_size()

func update_item_display_columns() -> void:
	var count = item_display.get_child_count()
	item_display.columns = max(1, int(ceil(float(count) / max_items_per_col)))

func reorder_items_column_first() -> void:
	var children := item_display.get_children()
	var count := children.size()
	var cols := int(ceil(float(count) / max_items_per_col))
	var rows := max_items_per_col

	var reordered := []
	for row in range(rows):
		for col in range(cols):
			var i = col * rows + row
			if i < count:
				reordered.append(children[i])

	for child in children:
		item_display.remove_child(child)
	for child in reordered:
		item_display.add_child(child)

func update_item_display_size() -> void:
	var count = item_display.get_child_count()
	var cols = item_display.columns
	var icon_size = Vector2(16, 16)
	var padding = 4
	var rows = ceil(float(count) / cols)

	var width = cols * (icon_size.x + padding) - padding
	var height = rows * (icon_size.y + padding) - padding

	item_display.custom_minimum_size = Vector2(width, height)

	var margin_container = item_display.get_parent()
	margin_container.custom_minimum_size = Vector2(width, height)

	var panel = margin_container.get_parent()
	panel.custom_minimum_size = Vector2(width, height) + Vector2(20, 20)

func flip_item_display_horizontally() -> void:
	item_display.scale.x = -1
	for child in item_display.get_children():
		child.scale.x = -1

func get_ending() -> String:
	var secret_items_total = 3  # total secret items needed for secret ending

	var neutral_count = collected_tags_count.get("neutral", 0)
	var bad_count = collected_tags_count.get("bad", 0)
	var secret_count = collected_tags_count.get("secret", 0)
	var total_collected = neutral_count + bad_count + secret_count

	# Dumb ending: no items collected
	if total_collected == 0:
		return "dumb"

	# Secret ending first: must collect ALL secret items
	if secret_count == secret_items_total:
		return "secret"

	# Otherwise, compare bad vs neutral
	if bad_count > neutral_count:
		return "bad"
	else:
		return "neutral"

func trigger_ending(ending: String) -> void:
	player.movement_locked = true

	match ending:
		"secret":
			await fade_out_screen(1.0)  # before the message
			await ui.show_message(["Secret Ending Unlocked! You've uncovered all the hidden secrets..."])
		"bad":
			await fade_out_screen(1.0)  # before the message
			await ui.show_message(["Bad Ending... Your choices have consequences."])
		"neutral":
			await fade_out_screen(1.0)  # before the message
			await ui.show_message(["Neutral Ending. You wake up, memories fading..."])
		"dumb":
			await fade_out_screen(1.0)  # before the message
			await ui.show_message(["You didn't collect anything... Maybe try paying attention next time? You're kinda dumb."])
	
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

# --- Screen Fade In/Out ---

func fade_out_screen(duration := 1.0) -> void:
	fade_rect.color.a = 0  # start fully transparent
	fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration) #fade to black
	await tween.finished

func fade_in_screen(duration := 1.0) -> void:
	fade_rect.color.a = 1.0  # start fully black
	fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration) #fade to transparent
	await tween.finished
	fade_rect.visible = false  # hide it again when done

# --- Debug ---
func debug_log_interactables() -> void:
	for node in get_tree().get_current_scene().get_children():
		if node is Area2D:
			print("Interactable: ", node.name)
