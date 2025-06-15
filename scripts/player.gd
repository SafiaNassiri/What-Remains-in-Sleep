# player.gd
extends CharacterBody2D

const Item = preload("res://scripts/item.gd")

@export var speed := 150

var movement_locked := false
var direction := Vector2.ZERO
var last_direction := "down"

var current_interactable_node: Node = null
var interactables_in_range: Array[Node] = []

var stairs_node: Node
var ui: Node = null

func _physics_process(delta: float) -> void:
	if ui and ui.is_message_active:
		velocity = Vector2.ZERO
		play_idle_animation()
		return

	handle_movement_input()
	move_and_slide()

	if last_direction == "side" and direction.x != 0:
		$PlayerSprite.flip_h = direction.x < 0

func handle_movement_input() -> void:
	direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
		update_facing_direction(direction)
		play_run_animation()
	else:
		velocity = Vector2.ZERO
		play_idle_animation()

func update_facing_direction(dir: Vector2) -> void:
	last_direction = "side" if abs(dir.x) > abs(dir.y) else ("up" if dir.y < 0 else "down")

# Animation
func play_idle_animation(): _set_animation("idle-" + last_direction)
func play_run_animation(): _set_animation("run-" + last_direction)
func play_hurt_animation(): _set_animation("hurt-" + last_direction)
func play_death_animation(): _set_animation("death-" + last_direction)

func _set_animation(anim: String) -> void:
	if $PlayerSprite.animation != anim:
		$PlayerSprite.animation = anim
		$PlayerSprite.play()

# Area2D Signals
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Item:
		interactables_in_range.append(area)
		update_current_interactable()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area is Item:
		interactables_in_range.erase(area)
		update_current_interactable()

func update_current_interactable() -> void:
	# Optionally prioritize by distance
	if interactables_in_range.is_empty():
		current_interactable_node = null
	else:
		current_interactable_node = interactables_in_range[0]
		var shortest_distance = position.distance_to(current_interactable_node.position)
		for item in interactables_in_range:
			var dist = position.distance_to(item.position)
			if dist < shortest_distance:
				current_interactable_node = item
				shortest_distance = dist

# Interaction handling
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if current_interactable_node:
			print("Calling handle_interaction on:", current_interactable_node)
			if current_interactable_node.has_method("handle_interaction"):
				await current_interactable_node.handle_interaction(self)
