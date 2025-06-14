#player.gd
extends CharacterBody2D

@export var speed := 150

var movement_locked := false
var direction := Vector2.ZERO
var last_direction := "down"

var current_interactable_node: Node = null
var interactables_in_range := []
var stairs_node: Node
var ui: Node = null

func _physics_process(delta: float) -> void:
	if ui and ui.is_message_active:
		velocity = Vector2.ZERO
		play_idle_animation()
		return

	handle_movement_input()
	move_and_slide()

	# Flip sprite for side-facing
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

# Animation methods
func play_idle_animation() -> void:
	var anim = "idle-" + last_direction
	_set_animation(anim)

func play_run_animation() -> void:
	var anim = "run-" + last_direction
	_set_animation(anim)

func play_hurt_animation() -> void:
	_set_animation("hurt-" + last_direction)

func play_death_animation() -> void:
	_set_animation("death-" + last_direction)

func _set_animation(anim: String) -> void:
	if $PlayerSprite.animation != anim:
		$PlayerSprite.animation = anim
		$PlayerSprite.play()

# Interaction handling
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print("Interact key pressed. Current interactable:", current_interactable_node)
		if current_interactable_node:
			if current_interactable_node.has_method("handle_interaction"):
				print("Calling handle_interaction on:", current_interactable_node)
				await current_interactable_node.handle_interaction(self)
