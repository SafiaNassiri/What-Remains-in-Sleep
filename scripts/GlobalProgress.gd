# GlobalProgress.gd
extends Node

var last_ending_number := -1

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
	
	print("=== GlobalProgress Totals Set ===")
	print("Total Neutral Items: %d" % total_neutral_items)
	print("Total Secret Items: %d" % total_secret_items)
	print("Total Neutral Interactions: %d" % total_neutral_interactions)
	print("Total Secret Interactions: %d" % total_secret_interactions)
	print("==============================")

func add_progress(collected_neutral, collected_secret, interacted_neutral_count, interacted_secret_count):
	collected_neutral_items += collected_neutral
	collected_secret_items += collected_secret
	interacted_neutral += interacted_neutral_count
	interacted_secret += interacted_secret_count
	
	# Print the updated progress state after every addition
	print("=== GlobalProgress Updated ===")
	print("Collected Neutral Items: %d / %d" % [collected_neutral_items, total_neutral_items])
	print("Collected Secret Items: %d / %d" % [collected_secret_items, total_secret_items])
	print("Interacted Neutral: %d / %d" % [interacted_neutral, total_neutral_interactions])
	print("Interacted Secret: %d / %d" % [interacted_secret, total_secret_interactions])
	print("==============================")

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

func reset_progress():
	collected_neutral_items = 0
	collected_secret_items = 0
	interacted_neutral = 0
	interacted_secret = 0

	print("=== GlobalProgress Reset ===")
	print("Collected Neutral Items: %d" % collected_neutral_items)
	print("Collected Secret Items: %d" % collected_secret_items)
	print("Interacted Neutral: %d" % interacted_neutral)
	print("Interacted Secret: %d" % interacted_secret)
	print("============================")
