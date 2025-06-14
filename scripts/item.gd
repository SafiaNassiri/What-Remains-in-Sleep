extends Area2D

# --- Node References ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var sprite2: Sprite2D = $Sprite2D2

# --- Exported Properties ---
@export var memory_text: String = ""
@export var sprite_region: Rect2 = Rect2()
@export var texture: Texture2D
@export var use_sprite2: bool = false
@export var interactable_name: String = ""
@export_enum("secret", "neutral", "bad") var ending_tag: String = "neutral"

# --- Runtime State ---
var main_node: Node = null
var player_in_range: bool = false

# --- Setup ---
func _ready() -> void:
	var active_sprite = sprite2 if use_sprite2 else sprite
	var inactive_sprite = sprite if use_sprite2 else sprite2
	
	# Apply texture/region to active sprite
	if texture:
		active_sprite.texture = texture
		active_sprite.region_enabled = sprite_region.size != Vector2.ZERO
		active_sprite.region_rect = sprite_region if active_sprite.region_enabled else Rect2(0, 0, 16, 16)
	
	# Hide the unused one
	inactive_sprite.visible = false

# --- Interaction Detection ---
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false

# --- Input Handling ---
func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		if main_node:
			var revealed = main_node.reveal_hidden_item(interactable_name)
			if revealed:
				queue_free()
				return

			main_node.call_deferred("on_item_collected", self)
			queue_free()
