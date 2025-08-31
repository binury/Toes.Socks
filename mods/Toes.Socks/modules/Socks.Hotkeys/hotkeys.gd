extends Node

signal hotkey_changed(name, key_code)

const SAVE_FILE_PATH ="user://hotkeys.json"
var DEBUG := true and OS.has_feature("editor")

## A copy of each *originally* supplied hotkey
var _configs := {}
## Hotkey store
var _hotkeys := {}

var hotkey_save_file := File.new()

const Hotkey := preload("res://mods/Toes.Socks/modules/Socks.Hotkeys/hotkey_config.gd")
const HotkeyPicker := preload("res://mods/Toes.Socks/modules/Socks.Hotkeys/menu_hotkey_picker.tscn")
var Players
var controls_settings: VBoxContainer


func _ready() -> void:
	self.set_process_unhandled_key_input(true)
	Players = get_node("/root/ToesSocks/Players")
	controls_settings = get_node("/root/OptionsMenu/Control/Panel/tabs_main/control/ScrollContainer/HBoxContainer/VBoxContainer")
	connect("hotkey_changed", self, "_on_hotkey_changed")

	if not hotkey_save_file.file_exists(SAVE_FILE_PATH):
		hotkey_save_file.open(SAVE_FILE_PATH, File.WRITE_READ)
		hotkey_save_file.store_string(JSON.print({
			"dummy_hotkey": KEY_YDIAERESIS
		}))
		hotkey_save_file.close()
	hotkey_save_file.open(SAVE_FILE_PATH, File.READ_WRITE)

	if DEBUG:
		var dummy := {
			"name": "dummy_hotkey",
			"label": "An Unused Dummy Hotkey",
			"modifiers": ["control"],
			"key_code": KEY_D,
			"repeat": true,
			"only_when_in_game": false,
			"skip_if_busy": true
		}
		self.add(dummy)


func _exit_tree():
	if !hotkey_save_file:
		return
	self._save_hotkey()
	if hotkey_save_file.is_open():
		hotkey_save_file.close()


func _unhandled_key_input(event: InputEventKey) -> void:
	var handler: Dictionary
	for action_name in self._hotkeys:
		if InputMap.action_has_event(action_name, event):
			handler = self._hotkeys[action_name]
			break

	if not handler:
		return
	if InputMap.event_is_action(event, handler.name, true):
		if (
			(not event.pressed)
			or (handler.repeat == false and event.is_echo())
			or (handler.only_when_in_game and Players.in_game == false)
			or (Players.is_busy() and handler.skip_if_busy)
		):
			_debug("Unhandled key input", OS.get_scancode_string(event.get_scancode_with_modifiers()))
			return
		get_tree().set_input_as_handled()
		_debug("Handled custom hotkey %s | %s" % [handler.name, OS.get_scancode_string(event.get_scancode_with_modifiers())])
		emit_signal(handler.name + "_pressed")


func _on_hotkey_changed(hotkey_name, key_code) -> void:
	self._save_hotkey()

func _save_hotkey(hotkey = null) -> Dictionary:
	var save_data : Dictionary = _get_saved_hotkey_binding()
	if not hotkey:
		for name in self._hotkeys.keys():
			var h = _hotkeys[name]
			var default = _configs[name]
			if h.key_code == default.key_code:
				continue
			save_data[name] = _hotkeys[name].key_code
	else:
		save_data[hotkey.name] = hotkey.key_code

	hotkey_save_file.seek(0)
	hotkey_save_file.store_string(JSON.print(save_data, "\t"))
	hotkey_save_file.flush()
	return save_data


func _debug(msg, data = null):
	if not DEBUG:
		return
	print("[Socks (Hotkeys)]: %s" % msg)
	if data != null:
		print(JSON.print(data, "\t"))


func _get_saved_hotkey_binding(hotkey_name = null):
	var saved_bindings: Dictionary
	hotkey_save_file.seek(0)
	var file_content = JSON.parse(hotkey_save_file.get_as_text())
	var result = file_content.result
	if typeof(result) != TYPE_DICTIONARY or file_content.error != OK:
		# TODO: Handle corruption
		push_error(file_content.error_string)
		breakpoint
		return
	saved_bindings = file_content.result as Dictionary
	return saved_bindings.get(hotkey_name) if hotkey_name else saved_bindings


## Setup new hotkey
## Returns the name of the signal that your hotkey triggers
func add(hotkey_config: Dictionary) -> String:
	# If only we could merge dictionaries in Godot3
	# TODO: Refactor into defaults

	var name: String = hotkey_config.name
	if not self._configs.has(name):
		_configs[name] = hotkey_config
	var label: String = hotkey_config.label
	var modifiers: Array = hotkey_config.get("modifiers", [])
	var key_code: int = hotkey_config.key_code
	var rebound_key_code = self._get_saved_hotkey_binding(name)
	if rebound_key_code:
		key_code = rebound_key_code
	var repeat: bool = hotkey_config.repeat
	var only_when_in_game: bool = hotkey_config.get("only_when_in_game", true)
	var skip_if_busy: bool = hotkey_config.get("skip_if_busy", true)


	var event := InputEventKey.new()
	event.set_scancode(key_code)
	for mod in modifiers:
		event[mod] = true
	if not InputMap.has_action(name):
		InputMap.add_action(name)
	if InputMap.get_action_list(name).size() > 0:
		InputMap.action_erase_events(name)
	InputMap.action_add_event(name, event)

	var new_signal_name = name + "_pressed"
	add_user_signal(new_signal_name)

	var hotkey_picker: HBoxContainer = HotkeyPicker.instance()
	if _hotkeys.has(name):
		hotkey_picker = _hotkeys[name].get("picker", HotkeyPicker.instance())
	_hotkeys[name] = {
		"name": name,
		"label": label,
		"modifiers": modifiers,
		# "default_key_code": hotkey_config.key_code,
		"key_code": key_code,
		"event": event,
		"repeat": repeat,
		"only_when_in_game": only_when_in_game,
		"picker": hotkey_picker,
		"skip_if_busy": skip_if_busy
	}
	hotkey_picker.name = "input_%s" % name
	var label_node = hotkey_picker.get_child(0)
	label_node.text = label
	var button_node = hotkey_picker.get_child(1)
	button_node.initialize(_hotkeys[name])

	if not hotkey_picker.get_parent():
		# controls_settings.remove_child(hotkey_picker)
		controls_settings.add_child(hotkey_picker)


	_debug("Added new hotkey " + name, self._hotkeys)
	return new_signal_name


## Change the key_code of a hotkey you've already added
func change(name: String, key_code: int):
	if not self._hotkeys.has(name):
		push_error("NO HOTKEY EXISTS WITH NAME " + name)
		breakpoint
	else:
		self._save_hotkey({
			"name": name,
			"key_code": key_code
		})
		self.add(_hotkeys[name])
		emit_signal('hotkey_changed', name, key_code)


## Un-add a hotkey
func remove(hotkey_config: Dictionary):
	var name: String = hotkey_config.name
	InputMap.action_erase_event(name, self._hotkeys[name].event)
	_debug("Removed old hotkey " + name, self._hotkeys)


## Get a string for e.g. instructing player on what buttons to press
## -> "Control+D"
func get_hotkey_binding_string(name: String) -> String:
	var event: InputEvent = InputMap.get_action_list(name)[0]
	if event == null:
		return ""
	# return toggle_event.as_text()
	return OS.get_scancode_string(event.get_scancode_with_modifiers())
