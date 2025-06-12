#main.gd

extends Node2D

@onready var player = $Player
@onready var ui = $UI 
@onready var item_panel_container = $UI/Panel2 
@onready var item_display = $UI/Panel2/MarginContainer/ItemDisplay
@onready var collectibles = $Collectibles
@onready var layer = $Layers
@onready var exit_trigger = $Triggers/Exit
@onready var ItemScene = preload("res://scenes/item.tscn")
@onready var fade_rect = $FadeRect
@onready var tileset_texture = preload("res://Sprites&TileMaps/Top-Down_Retro_Interior/TopDownHouse_SmallItems.png")

var current_run = 1
var max_runs = 3
var memory_items_collected = 0
var collected_this_run = []

# item data
var item_data = {
	1: [
		{
			"pos": Vector2(70, 135),
			"text": "A cracked photograph. Someone's missing...",
			"hidden": false,
			"region_rect": Rect2(16, 16, 16, 16)
		},
		{
			"interact": "bookshelf1",
			"spawn_pos": Vector2(118, 101),
			"text": "The pages mention a hospital room.",
			"hidden": true,
			"region_rect": Rect2(0, 48, 16, 16)
		}
	],
	2: [
		{
			"pos": Vector2(175, 131),
			"text": "A dog toy. You remember crying.",
			"hidden": false,
			"region_rect": Rect2(0, 32, 16, 16)
		},
		{
			"interact": "Pot1",
			"spawn_pos": Vector2(180, 131),
			"text": "A letter half-burned: 'We’re sorry, we had to let go.'",
			"hidden": true,
			"region_rect": Rect2(16, 16, 16, 16)
		}
	],
	3: [
		{
			"pos": Vector2(190, 131),
			"text": "A flower pot. A small card says 'Get Well Soon!'. Your name is on it.",
			"hidden": false,
			"region_rect": Rect2(112, 16, 16, 16)
		}
	]
}

func _ready():
	player.ui = ui
		
	print("Current run: ", current_run)
	
	exit_trigger.main_node = self
	item_panel_container.visible = false
	player.movement_locked = true
	spawn_items_for_run(current_run)

	await ui.show_message("I don't remember how I got here...")
	await ui.show_message("I fell asleep, I think.")
	await ui.show_message("It's been dark for so long...")
	await ui.show_message("And now, I'm just... here.")
	await ui.show_message("Maybe I should look around. Find something...")
	await ui.show_message("or someone.")

	player.movement_locked = false

func _on_lore_text_done():
	player.movement_locked = false

func next_run():
	current_run += 1
	player.movement_locked = true

	await fade_out(1.0)
	await ui.show_message("Memories feel different this time...")

	player.global_position = Vector2(26, 133)
	for child in collectibles.get_children():
		child.queue_free()

	spawn_items_for_run(current_run)

	await fade_in(1.0)
	player.movement_locked = false

func end_game():
	print("Waking up ...")
	# TO DO: add wake-up scene

func spawn_items_for_run(run):
	var items = item_data.get(run, [])
	print("Spawning items for run ", run, ": ", items.size())
	for item in items:
		if item.hidden:
			continue
		print("Spawning item at pos: ", item.pos)
		spawn_item(item.pos, item.text, item.region_rect)

func reveal_hidden_item(interact_name: String):
	for item in item_data.get(current_run, []):
		if item.hidden and item.get("interact") == interact_name:
			spawn_item(item.spawn_pos, item.text, item.region_rect)
			break

func spawn_item(pos: Vector2, memory_text: String, sprite_region: Rect2 = Rect2()):
	var item = ItemScene.instantiate()
	item.global_position = pos
	item.memory_text = memory_text
	item.sprite_region = sprite_region
	item.texture = tileset_texture
	item.main_node = self
	collectibles.add_child(item)
	print("Spawned item: ", memory_text, " at ", pos)

func on_item_collected(item):
	# Copy all data early to avoid referencing freed object
	var texture = item.texture
	var region = item.sprite_region
	var memory_text = item.memory_text

	memory_items_collected += 1
	collected_this_run.append(memory_text)

	print("Collected item: ", memory_text)
	print("Texture: ", texture)
	print("Region: ", region)

	await ui.show_message(memory_text)
	add_item_icon_to_ui(texture, region, memory_text)

func add_item_icon_to_ui(texture: Texture2D, region: Rect2, memory_text: String):
	var icon = TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(16, 16)
	icon.tooltip_text = memory_text

	if region.size != Vector2.ZERO:
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = texture
		atlas_tex.region = region
		icon.texture = atlas_tex
	else:
		icon.texture = texture

	if item_display:
		if not item_panel_container.visible:
			item_panel_container.visible = true
		item_display.add_child(icon)
		update_item_display_size()
	else:
		print("ERROR: item_display not found")

func fade_out(duration = 1.0) -> void:
	fade_rect.visible = true
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_in(duration = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished
	fade_rect.visible = false

func update_item_display_size():
	var item_count = item_display.get_child_count()
	var items_per_row = item_display.columns
	var item_icon_size = Vector2(16, 16)
	var padding = 4

	var rows = ceil(float(item_count) / items_per_row)

	var width = items_per_row * (item_icon_size.x + padding) - padding
	var height = rows * (item_icon_size.y + padding) - padding

	# Update ItemDisplay (GridContainer) size
	item_display.custom_minimum_size = Vector2(width, height)

	# Update MarginContainer size (adds padding)
	var margin_container = item_display.get_parent()
	margin_container.custom_minimum_size = Vector2(width, height)

	# Update Panel size with extra padding for border/background
	var panel = margin_container.get_parent()
	var panel_padding = Vector2(20, 20) # tweak as you want
	panel.custom_minimum_size = Vector2(width, height) + panel_padding
