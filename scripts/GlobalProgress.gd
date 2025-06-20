extends Node

var unlocked_endings: Array[String] = []

var ENDINGS_FOLDER := "user://endings_folder/"

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
	_load_endings()

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
		_save_ending_file(ending)
		print("Unlocked ending saved:", ending)

func _save_ending_file(ending: String) -> void:
	# Ensure folder exists
	var base_dir := DirAccess.open("user://")
	if base_dir == null:
		print("❌ Failed to open user:// directory")
		return
	
	if not base_dir.dir_exists("endings_folder"):
		var err := base_dir.make_dir("endings_folder")
		if err != OK:
			print("❌ Failed to create endings_folder:", err)
			return
	
	var file_path := ENDINGS_FOLDER + ending + ".txt"
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string("")  # You can store actual text if you want later
		file.close()
		print("✅ Saved ending:", file_path)
	else:
		print("❌ Failed to open file for writing:", file_path)

func _load_endings() -> void:
	unlocked_endings.clear()

	if not DirAccess.dir_exists_absolute(ENDINGS_FOLDER):
		print("📂 No endings folder found.")
		return

	var dir := DirAccess.open(ENDINGS_FOLDER)
	if dir == null:
		print("❌ Failed to open endings folder")
		return

	var error := dir.list_dir_begin()
	if error != OK:
		print("❌ Failed to start listing endings folder:", error)
		return

	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if not dir.current_is_dir():
			var ending_name := file_name.get_basename()
			unlocked_endings.append(ending_name)

	dir.list_dir_end()
	print("✅ Loaded endings from folder:", unlocked_endings)

func reset_endings():
	unlocked_endings.clear()

	var dir := DirAccess.open(ENDINGS_FOLDER)
	if dir == null:
		print("❌ Could not open endings folder for reset")
		return
	
	var error = dir.list_dir_begin()
	if error != OK:
		print("❌ Could not begin directory listing:", error)
		return
	
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if not dir.current_is_dir():
			var file_path = ENDINGS_FOLDER + file_name
			if FileAccess.file_exists(file_path):
				var err = dir.remove(file_path) 
				if err == OK:
					print("✅ Removed ending file:", file_path)
				else:
					print("❌ Failed to remove ending file:", file_path, "Error:", err)
	
	dir.list_dir_end()

	print("All endings reset and files deleted")
