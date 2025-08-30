extends Button

var Hotkeys

var action := "move_forward"

## Vanilla compat
var default_action
var set_action
const queued_action = null


func _ready():
	Hotkeys = get_node("/root/ToesSocks/Hotkeys")
	Hotkeys.connect("hotkey_changed", self, "_display_key()")
	set_process_unhandled_key_input(false)
	add_to_group("input_remap")
	connect("toggled", self, "_on_button_toggled")
	_display_key()


func initialize(hotkey: Dictionary):
	self.action = hotkey.name
	default_action = InputMap.get_action_list(self.action)[0]
	set_action = default_action
	_display_key()


func _display_key():
	var actions := InputMap.get_action_list(action)
	if actions.empty():
		var all_actions = InputMap.get_actions()
		## Uh-oh :S
		breakpoint
	text = _get_text(actions[0])


func _get_text(action):
	return action.as_text()


## Vanilla compat
func _on_input_forward_toggled(__) -> void:
	pass


func _on_button_toggled(button_pressed):
	set_process_unhandled_key_input(button_pressed)
	if button_pressed:
		text = ". . ."
		OptionsMenu.emit_signal("_rebinding_key", action)
	else:
		_display_key()


func _unhandled_key_input(event: InputEventKey):
	if event is InputEventKey and event.scancode != KEY_ESCAPE:
		_remap_key(event.scancode)
	pressed = false


func _remap_key(code: int):
	set_action = default_action
	set_action.scancode = code
	Hotkeys.change(action, code)
	_display_key()
