#player.gd

extends CharacterBody2D

@export var speed := 150
var movement_locked := false
var ui
var direction := Vector2.ZERO
var last_direction := "down"
var is_jumping := false
var current_interactable: String = ""

func _physics_process(delta):
	if ui and ui.is_message_active:
		velocity = Vector2.ZERO
		play_idle_animation()
		return
	
	# If jumping, skip movement input
	if is_jumping:
		move_and_slide()
		return

	# Get movement input
	direction = Vector2.ZERO
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Apply movement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * speed
		update_facing_direction(direction)
		play_run_animation()
	else:
		velocity = Vector2.ZERO
		play_idle_animation()

	move_and_slide()

	# Flip for side-facing sprites only
	if last_direction == "side" and direction.x != 0:
		$PlayerSprite.flip_h = direction.x < 0

	# Jump input
	if not is_jumping and Input.is_action_just_pressed("jump"):
		start_jump()

func update_facing_direction(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		last_direction = "side"
	else:
		last_direction = "up" if dir.y < 0 else "down"

# Animation controls
func play_idle_animation():
	var anim = "idle-" + last_direction
	if $PlayerSprite.animation != anim:
		$PlayerSprite.animation = anim
		$PlayerSprite.play()

func play_run_animation():
	var anim = "run-" + last_direction
	if $PlayerSprite.animation != anim:
		$PlayerSprite.animation = anim
		$PlayerSprite.play()

func play_hurt_animation():
	var anim = "hurt-" + last_direction
	$PlayerSprite.animation = anim
	$PlayerSprite.play()

func play_jump_animation():
	var anim = "jump-" + last_direction
	$PlayerSprite.animation = anim
	$PlayerSprite.play()

func play_death_animation():
	var anim = "death-" + last_direction
	$PlayerSprite.animation = anim
	$PlayerSprite.play()

# Jump action
func start_jump():
	is_jumping = true
	var anim = "jump-" + last_direction
	$PlayerSprite.animation = anim
	$PlayerSprite.play()

	await $PlayerSprite.animation_finished

	is_jumping = false

func _process(_delta):
	if Input.is_action_just_pressed("interact") and current_interactable != "":
		var node = get_parent().find_node(current_interactable, true, false)
		if node and node.has_method("handle_interaction"):
			node.handle_interaction(self)
