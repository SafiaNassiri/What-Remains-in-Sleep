# Item.gd
extends Area2D

@export var memory_text: String
@export var sprite_region: Rect2 = Rect2()
@export var texture: Texture2D
@export var use_sprite2: bool = false
@export var interactable_name: String
@export_enum("secret", "neutral", "bad") var ending_tag: String = "neutral"

@onready var sprite = $Sprite2D
@onready var sprite2 = $Sprite2D2

var main_node: Node = null
var player_in_range := false

func _ready() -> void:
	var active = sprite2 if use_sprite2 else sprite
	var inactive = sprite if use_sprite2 else sprite2
	inactive.visible = false

	if texture:
		active.texture = texture
		active.region_enabled = sprite_region.size != Vector2.ZERO
		active.region_rect = sprite_region

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		if main_node:
			main_node.call_deferred("on_item_collected", self)
			queue_free()

# Add this to Item.gd
func handle_interaction(player: Node) -> void:
	if main_node:
		main_node.call_deferred("on_item_collected", self)
		queue_free()
