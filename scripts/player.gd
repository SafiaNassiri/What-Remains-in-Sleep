# player.gd
extends CharacterBody2D

@export var speed := 150

@onready var sfx_player = $sfx_player

var movement_locked := false
var direction := Vector2.ZERO
var last_direction := "down"

var current_interactable_node: Node = null
var interactables_in_range: Array[Node] = []
var can_interact := true

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
	if area.is_in_group("items") or area.is_in_group("lore_objects"):
		if not interactables_in_range.has(area):
			interactables_in_range.append(area)
			update_current_interactable()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("items") or area.is_in_group("lore_objects"):
		interactables_in_range.erase(area)
		update_current_interactable()

func update_current_interactable() -> void:
	if interactables_in_range.size() == 0:
		current_interactable_node = null
		return

	var shortest_distance = position.distance_to(interactables_in_range[0].position)
	current_interactable_node = interactables_in_range[0]

	for item in interactables_in_range:
		var dist = position.distance_to(item.position)
		if dist < shortest_distance:
			shortest_distance = dist
			current_interactable_node = item

func collect_item(item):
	if item.item_id not in get_tree().current_scene.collected_items:
		get_tree().current_scene.collected_items.append(item.item_id)
		#print("DEBUG: Collected item:", item.item_id)

		play_item_collect_sound()

		if item.is_secret:
			GlobalProgress.add_progress(0, 1, 0, 0)
		else:
			GlobalProgress.add_progress(1, 0, 0, 0)
		print("DEBUG: Progress updated in GlobalProgress.")

		if item.is_secret:
			if item.item_id not in get_tree().current_scene.unlocked_secrets:
				get_tree().current_scene.unlocked_secrets.append(item.item_id)
				#print("DEBUG: Collected secret item:", item.item_id)

		#print("DEBUG: Current collected_items array:", get_tree().current_scene.collected_items)
		#print("DEBUG: Current unlocked_secrets array:", get_tree().current_scene.unlocked_secrets)

		if ui and ui.has_method("add_item_to_display"):
			ui.add_item_to_display(item.icon_texture)
	else:
		print("DEBUG: Item already collected:", item.item_id)

# Interaction handling
func _process(_delta: float) -> void:
	if ui and ui.is_message_active:
		return  # block interaction while message is active

	if Input.is_action_just_pressed("ui_accept") and can_interact:
		if current_interactable_node and current_interactable_node.has_method("handle_interaction"):
			can_interact = false
			await current_interactable_node.handle_interaction(self)
			# Add a small delay after interaction ends
			if is_inside_tree() and get_tree():
				await get_tree().create_timer(0.2).timeout
			can_interact = true

func play_item_collect_sound():
	sfx_player.stream = load("res://Audio/sounds/Item collect.wav")
	sfx_player.play()
