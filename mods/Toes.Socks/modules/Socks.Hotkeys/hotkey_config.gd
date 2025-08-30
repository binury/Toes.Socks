extends Resource

## https://docs.godotengine.org/en/3.5/classes/class_inputeventwithmodifiers.html#class-inputeventwithmodifiers
enum MODIFIER { alt, command, control, meta, shift }


class HotkeyConfig:
	## The internal name for your hotkey (passed to InputMap)
	## Make this unique!
	## @example "toggle_flashlight"
	var name: String

	## Key Scancode from KeyList
	## @example KEY_F10
	## https://docs.godotengine.org/en/3.5/classes/class_%40globalscope.html#enum-globalscope-keylist
	var key_code: int

	## The short-name/description, shown in UI to player
	## @example "[Flashlight Mod] Toggle"
	var label: String

	## Modifier keys that must be held down when using this hotkey
	var modifiers: Array = []

	## Whether your hotkey should signal if held down and repeating
	var repeat: bool = false

	## When disabled, allows handling input that is occurring out of game, in the main menu
	## 99% of webfishers/modders probably don't want this !
	var only_when_in_game: bool = true

	## When disabled, allows handling input while player is "busy"
	## Which means they are typing in chat, navigating the menu, or dealing with a pop-up
	## 99% of webfishers/modders probably don't want this !
	var skip_if_busy: bool = true
