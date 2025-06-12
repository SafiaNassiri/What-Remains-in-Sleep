#item.gd

extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@export var memory_text: String = ""
@export var sprite_region: Rect2 = Rect2()
@export var texture: Texture2D

var main_node
var player_in_range = false

func _ready():
	if texture:
		sprite.texture = texture
	if sprite_region.size != Vector2.ZERO:
		sprite.region_enabled = true
		sprite.region_rect = sprite_region
	else: 
		sprite.region_enabled = false
		sprite.region_rect = Rect2(0, 0, 16, 16)

func _on_body_entered(body):
	if body.name == "Player": 
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		if main_node:
			main_node.call_deferred("on_item_collected", self)
			queue_free()
