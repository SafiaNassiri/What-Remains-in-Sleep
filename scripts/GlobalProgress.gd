# GlobalProgress.gd
extends Node

var total_neutral_items = 0
var total_secret_items = 0
var total_neutral_interactions = 0
var total_secret_interactions = 0

var collected_neutral_items = 0
var collected_secret_items = 0
var interacted_neutral = 0
var interacted_secret = 0

func _ready():
	# You can initialize or reset cumulative progress here if needed
	pass

func set_totals(neutral_items, secret_items, neutral_interactions, secret_interactions):
	total_neutral_items = neutral_items
	total_secret_items = secret_items
	total_neutral_interactions = neutral_interactions
	total_secret_interactions = secret_interactions

func add_progress(collected_neutral, collected_secret, interacted_neutral_count, interacted_secret_count):
	collected_neutral_items += collected_neutral
	collected_secret_items += collected_secret
	interacted_neutral += interacted_neutral_count
	interacted_secret += interacted_secret_count

func get_totals() -> Dictionary:
	return {
		"total_neutral_items": total_neutral_items,
		"total_secret_items": total_secret_items,
		"total_neutral_interactions": total_neutral_interactions,
		"total_secret_interactions": total_secret_interactions
	}

func get_progress() -> Dictionary:
	return {
		"collected_neutral_items": collected_neutral_items,
		"collected_secret_items": collected_secret_items,
		"interacted_neutral": interacted_neutral,
		"interacted_secret": interacted_secret
	}
