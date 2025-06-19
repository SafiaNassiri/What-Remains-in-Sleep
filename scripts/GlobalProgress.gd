# GlobalProgress.gd
extends Node

var unlocked_endings: Array[String] = []

const SAVE_PATH = "user://endings.save"

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
	load_endings()

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
	print("✅ add_progress() called")
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

func add_unlocked_ending(ending: String) -> void:
	if ending not in unlocked_endings:
		unlocked_endings.append(ending)
		save_endings()

func save_endings():
	var data = {
		"unlocked_endings": unlocked_endings
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()

func load_endings():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var data = file.get_var()
			unlocked_endings = data.get("unlocked_endings", [])
			file.close()
	else:
		unlocked_endings = []

func reset_endings():
	unlocked_endings.clear()
	save_endings()
