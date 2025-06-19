extends Area2D

@export var item_id: String = ""
@export var item_name: String
@export var icon_texture: AtlasTexture  # use AtlasTexture instead of plain Texture2D
@export var lore_text: Array[String] = []
@export var is_secret: bool = false

var collected := false

func get_item_id(): return item_id
func get_item_lore(): return lore_text
func get_lore_id(): return item_id

func _ready():
	add_to_group("items")
	
	# If you want to update the sprite in the scene with the atlas texture:
	var sprite = $Sprite2D
	if sprite and icon_texture:
		sprite.texture = icon_texture

func handle_interaction(player: Node) -> void:
	if collected:
		return
	collected = true
	if lore_text.size() > 0:
		await player.ui.show_message(lore_text)

	if player and player.has_method("collect_item"):
		player.collect_item(self)
	emit_signal("collected", self)
	queue_free()  # Remove item from world
