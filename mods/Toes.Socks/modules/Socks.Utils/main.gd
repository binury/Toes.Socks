extends Node

signal mod_config_updated(mod_id, config)

#################################
# Adapted from code written by  #
# https://github.com/puppy-girl #
#################################

var _file := File.new()
var _dir := Directory.new()

var gdweave_directory := get_gdweave_dir()
var mods_directory := gdweave_directory.plus_file("mods") if not OS.has_feature("editor") else ProjectSettings.globalize_path("res://mods")
var configs_directory := gdweave_directory.plus_file("configs")
var gdweave_logs: String
var mod_manifests: Dictionary
var mod_configs: Dictionary
var mod_data: Dictionary
## List of loaded mods
## E.g., [baltdev.Nightlight, BlueberryWolfi.APIs, Lucy.LucysTools, Sulayre.Lure, TackleBox, Toes.AutoAFK, Toes.Socks, Toes.Tablecopter, Toes.ThePhantom, Toes.Tuner]
var loaded_mods: Array



func _get_loaded_mods() -> Array:
	var mods := []

	if OS.has_feature("editor"):
		if _dir.open(mods_directory) != OK:
			push_error("Could not open mods directory")
			breakpoint
			return []

		_dir.list_dir_begin(true, true)
		var file_name := _dir.get_next()
		mods.append(file_name)
		while file_name != "":
			file_name = _dir.get_next()
			mods.append(file_name)
		_dir.list_dir_end()
		return mods

	else:
		var regex = RegEx.new()
		regex.compile("Loaded \\d+ mods: (?<mods>\\[.*\\])")

		var search: RegExMatch = regex.search(gdweave_logs)
		var loaded_mod_logs := JSON.parse(search.get_string("mods") if search else "")

		if loaded_mod_logs.error != OK:
			push_error("could not parse loaded mods from the log file")
			return []

		return loaded_mod_logs.result


func _get_gdweave_logs() -> String:
	var log_file_path := gdweave_directory.plus_file("GDWeave.log")

	if not _file.file_exists(log_file_path):
		push_error("Could not get the GDWeave log file: does not exist")
		return ""

	_file.open(log_file_path, File.READ)
	var logs := _file.get_as_text()
	_file.close()

	return logs


func _init_mod_configs() -> void:
	if not _dir.dir_exists(configs_directory):
		_dir.make_dir(configs_directory)

	if _dir.open(configs_directory) != OK:
		push_warning("Could not open configs directory")
		return

	_dir.list_dir_begin(true, true)

	var file_name := _dir.get_next()
	while file_name != "":
		var config_path := configs_directory.plus_file(file_name)
		var mod_id := file_name.replace(".json", "")

		_file.open(config_path, File.READ)

		var config_data := JSON.parse(_file.get_as_text())
		if config_data.error == OK and config_data.result is Dictionary:
			mod_configs[mod_id] = config_data.result

		_file.close()

		file_name = _dir.get_next()

	_dir.list_dir_end()


func _init_mod_manifests() -> void:
	if not _dir.dir_exists(mods_directory):
		_dir.make_dir(mods_directory)

	if _dir.open(mods_directory) != OK:
		push_error("Issue opening mods directory")
		return

	_dir.list_dir_begin(true, true)

	var file_name := _dir.get_next()
	while file_name != "":
		if not _dir.current_is_dir():
			file_name = _dir.get_next()
			continue

		var manifest_path := mods_directory.plus_file(file_name + "/manifest.json")
		var mod_id: String

		if _file.file_exists(manifest_path):
			_file.open(manifest_path, File.READ)

			var manifest_data := JSON.parse(_file.get_as_text())
			if manifest_data.error == OK and "Id" in manifest_data.result:
				mod_id = manifest_data.result.Id
				mod_manifests[mod_id] = _snakeify_keys(manifest_data.result)

			_file.close()

		var mod_file_path := mods_directory.plus_file(file_name + "/mod.json")

		if _file.file_exists(mod_file_path):
			_file.open(mod_file_path, File.READ)

			var mod_file_data := JSON.parse(_file.get_as_text())
			if mod_file_data.error == OK and mod_file_data.result is Dictionary:
				mod_data[mod_id] = mod_file_data.result

			_file.close()

		file_name = _dir.get_next()

	_dir.list_dir_end()


func _snakeify_keys(input: Dictionary) -> Dictionary:
	var new_dictionary := {}

	for key in input:
		if input[key] is Dictionary:
			new_dictionary[_to_snake_case(key)] = _snakeify_keys(input[key])
		else:
			new_dictionary[_to_snake_case(key)] = input[key]

	return new_dictionary


func _to_snake_case(input: String) -> String:
	var regex = RegEx.new()
	regex.compile("([a-z])([A-Z])")
	return regex.sub(input, "$1_$2", true).to_lower()


func _init() -> void:
	_init_mod_manifests()
	_init_mod_configs()
	gdweave_logs = _get_gdweave_logs()
	loaded_mods = _get_loaded_mods()


func _ready() -> void:
	pass

############
## Public ##
############


## Returns the mod manifest for the given mod ID
## Keys are returned in snake_case
func get_mod_manifest(mod_id: String) -> Dictionary:
	if not mod_id in mod_manifests:
		push_warning("No mod manifest for mod id " + mod_id)
		return {}

	return mod_manifests[mod_id]


## Returns mod metadata for the given mod ID
## Keys are returned in snake_case
func get_mod_metadata(mod_id: String) -> Dictionary:
	if mod_id in mod_data:
		return mod_data[mod_id]

	if mod_id in mod_manifests and "metadata" in mod_manifests[mod_id]:
		return mod_manifests[mod_id].metadata

	push_warning("No mod metadata for mod id " + mod_id)
	return {}


## Returns the config file for the given mod ID
func get_mod_config(mod_id: String) -> Dictionary:
	if not mod_id in mod_configs:
		push_warning("No config data for mod id " + mod_id)
		return {}

	return mod_configs[mod_id]


## Sets the config file for the given mod ID or creates a new one
func set_mod_config(mod_id: String, new_config: Dictionary) -> int:
	if mod_id.find("/") != -1 or mod_id.find("\\") != -1:
		return ERR_INVALID_PARAMETER

	if not new_config is Dictionary:
		return ERR_INVALID_DATA

	var config_file_path = configs_directory.plus_file(mod_id + ".json")

	var config_file_err := _file.open(config_file_path, File.WRITE)
	if config_file_err != OK:
		return config_file_err

	_file.store_string(JSON.print(new_config, "  "))
	_file.close()

	mod_configs[mod_id] = new_config

	emit_signal("mod_config_updated", mod_id, new_config)

	return OK


func get_gdweave_dir() -> String:
	var game_directory := OS.get_executable_path().get_base_dir()
	var default_directory := game_directory.plus_file("GDWeave")
	var folder_override: String
	var final_directory: String

	for argument in OS.get_cmdline_args():
		if argument.begins_with("--gdweave-folder-override="):
			folder_override = argument.trim_prefix("--gdweave-folder-override=").replace("\\", "/")

	if folder_override:
		var relative_path := game_directory.plus_file(folder_override)
		var is_relative := not ":" in relative_path and _file.file_exists(relative_path)

		final_directory = relative_path if is_relative else folder_override
	else:
		final_directory = default_directory

	return final_directory


