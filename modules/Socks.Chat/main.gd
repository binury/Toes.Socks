# class_name Chat

extends Node
## The Socks.Chat module was created to address the naturally opaque and cumbersome process of hooking into the game's chat methods.
## @experimental

signal player_messaged(message, player, was_local_player)
signal player_emoted(message, player, was_local_player)

const COLORS := {
	"white": "#ffeed5",
	"tan": "#d5aa73",
	"brown": "#6a4420",
	"red": "#ff0031",
	"maroon": "#ac0029",
	"grey": "#a4756a",
	"green": "#525900",
	"blue": "#008583",
	"purple": "#4a2c4a",
	"salmon": "#f6856a",
	"yellow": "#e69d00",
	"black": "#101c31",
	"orange": "#c54400",
	"olive": "#a4aa39",
	"teal": "#5a755a",
}

var HUD
var _Chat
onready var Network = get_node("/root/Network")
onready var Players = get_node("/root/ToesSocks/Players")


func _ready():
	pass


func _process(delta):
	if not is_instance_valid(_Chat):
		_init()


func _init():
	if not is_instance_valid(get_node_or_null("/root/playerhud")):
		return
	HUD = $"/root/playerhud"
	_Chat = HUD.chat

	Network.connect("_chat_update", self, "_chat_updated")


func _chat_updated():
	if not is_instance_valid(Network):
		return  # Just a weird edge case

	var messages := Network.GAMECHAT.rsplit("\n", false, 1) as Array
	if messages.size() == 1:
		return

	var msg_received = messages[1]

	var sender = _get_sender(msg_received)
	if not sender:
		return  # for now, non-player messages are ignored
	# Perhaps in future can emit, if it is useful somehow

	# TODO !!!!!!!!!!!!!
	if msg_received[0] == "(":
		emit_signal("player_emoted", "EMOTE TODO", sender, is_local_player(sender))
		return

	var message = _get_message(msg_received)
	if not message:
		return  # Player joined the game etc
	emit_signal("player_messaged", message, sender, is_local_player(sender))


## Facilitates passing predefined color names in addition to raw RGB values
func _parse_color_string(s: String) -> String:
	if s.to_lower() in COLORS:
		return COLORS[s.to_lower()]
	# TODO 'convenient validation' of color string
	return s


## Parses a raw message line and returns the message's sender
func _get_sender(msg: String) -> String:
	var match_sender = RegEx.new()
	match_sender.compile("\\](.+)\\[")
	var sender = match_sender.search(msg)
	return sender.get_strings()[1] if sender else ""


## Parses a raw message line and returns the actual message content
func _get_message(msg: String) -> String:
	var match_message = RegEx.new()
	match_message.compile(": (.+)")
	var message = match_message.search(msg)
	return message.get_strings()[1] if message else ""


############
## Public ##
############


## Check whether the local_player's name matches the given name
## This is possibly broken/forged due to namespace collision
## There is no workaround for this yet. Use with caution! Validate if possible
func is_local_player(name) -> bool:
	var local_player_name = Players.get_username(Players.local_player)
	return local_player_name == name


## Send a raw message without any special handling
## Useful for e.g., non-player or system messages
func send_raw(msg: String, color: String = "Grey", local: bool = false):
	if not is_instance_valid(HUD):
		_init()
	Network._send_message(msg, _parse_color_string(color), local)


## Write a (raw) message to the local_player's chat
## Since this is client-side only, no sanitization is done
func write(msg: String, local: bool = false):
	Network._update_chat(msg)


## Send a chat message
## Color can be a plain RGB hex color code
## or any of the following in-game predefined colors:
## `white` `tan` `brown` `red` `maroon` `grey` `green` `blue`
## `purple` `salmon` `yellow` `black` `orange` `olive` `teal`
func send(msg: String, color: String = "Grey", local: bool = false):
	if not is_instance_valid(HUD):
		_init()
	send_as("%u", msg, color, local)


## Send an emote
func emote(msg: String, color: String = "Grey", local: bool = false):
	if not is_instance_valid(HUD):
		_init()
	emote_as("%u", msg, color, local)


## Send a chat as a given player
func send_as(who: String, msg: String, color: String = "Grey", local: bool = false):
	if not is_instance_valid(HUD):
		_init()
	Network._send_message(who + ": " + msg, _parse_color_string(color), local)


## Send an emote as a given player
func emote_as(who: String, msg: String, color: String = "Grey", local: bool = false):
	if not is_instance_valid(HUD):
		_init()
	Network._send_message("(" + who + " " + msg + ")", _parse_color_string(color), local)


## Convenience method for sending player notifications
func notify(msg: String):
	PlayerData._send_notification(msg)
