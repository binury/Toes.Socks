# Copyright (c) 2025 binury

# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this repository.

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

var DEBUG := OS.has_feature("editor") and false


func _debug(msg, data = null):
	if not DEBUG:
		return
	print("[Socks.Chat]: %s" % msg)
	if data != null:
		print(JSON.print(data, "\t"))


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

	# Enable receipt of Mouse events for clicking BBC Links (otherwise set to Ignore)
	HUD.gamechat.mouse_filter = Control.MOUSE_FILTER_PASS
	HUD.gamechat.connect("meta_clicked", self, "_open_url")


func _write_link(url: String):
	var MAX_TITLE_CHARS := 30
	var LINK_COLOR = "66C0F4"

	var path_regex = RegEx.new()
	path_regex.compile("[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#&\\/=]*)")
	var path = path_regex.search(url)
	var link_text = "LINK: " + path.get_string()
	if link_text.length() > MAX_TITLE_CHARS:
		link_text = link_text.substr(0, MAX_TITLE_CHARS) + "…"
	write(
		(
			"[center][font=res://Assets/Themes/font_alternate.tres][color=#%s][url=%s][%s][/url][/color][/font][/center]"
			% [LINK_COLOR, url, link_text]
		)
	)


func _chat_updated():
	if not is_instance_valid(Network):
		return  # Just a weird edge case

	var messages := Network.GAMECHAT.rsplit("\n", false, 1) as Array

	if messages.size() == 1:
		return

	var URI_REGEX := "(?<!url=)https?:\/\/(?:www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&\\/=]*)"
	var msg_received: String = messages[1]

	var llib = get_node_or_null("/root/LucysLib")
	var use_lucy = llib != null
	if use_lucy:
		var bbct = llib.BBCode.parse_bbcode_text(msg_received)
		# print("original:", msg_received)
		msg_received = bbct.get_stripped()
	else:
		breakpoint

	var sender = _get_sender(msg_received)
	## Workaround for fabricated players or "sender-like" messages
	var pnames = Players.get_names(true)
	if not sender in pnames:
		sender = null

	if not sender:
		var match_uri = RegEx.new()
		match_uri.compile(URI_REGEX)
		var result = match_uri.search(msg_received)
		if result:
			_write_link(result.get_string())
		return  # for now, non-player messages do not emit events
	# Perhaps in future can emit, if it is useful somehow

	if msg_received[0] == "(":
		var emote := _get_emote(msg_received, sender)
		_debug("%s emoted: %s" % [sender, emote])
		emit_signal("player_emoted", emote, sender, is_local_player(sender))
		return

	var message = _get_message(msg_received, use_lucy)
	if not message:
		return  # Player joined the game etc

	var match_uri = RegEx.new()
	match_uri.compile(URI_REGEX)
	var result = match_uri.search(message)
	if result:
		_write_link(result.get_string())
	_debug("%s messaged: %s" % [sender, message])
	emit_signal("player_messaged", message, sender, is_local_player(sender))


## Facilitates passing predefined color names in addition to raw RGB values
func _parse_color_string(s: String) -> String:
	if s.to_lower() in COLORS:
		return COLORS[s.to_lower()]
	# TODO 'convenient validation' of color string
	return s


## Parses a raw message line and returns the message's sender
func _get_sender(msg: String) -> String:
	var color_tag_open = "(\\[color=#\\w{3,8}\\])?"
	var color_tag_close = "(\\[/color\\])?"
	var sender := "???"
	var pnames = Players.get_names(true)
	for p in pnames:
		var match_sender := RegEx.new()
		var pattern = (
			("\\(" + color_tag_open + p + color_tag_close + " ")
			if msg[0] == "("
			else (color_tag_open + p + color_tag_close + ": ")
		)
		match_sender.compile(pattern)
		if match_sender.search(msg):
			sender = p
			break
	return sender


## Parses a raw message line and returns the message content
## Sanitized arg should be false if the message may contain BBCode
func _get_message(msg: String, sanitized: bool) -> String:
	if sanitized:
		var delimiter_idx = msg.find(":")
		return msg.substr(delimiter_idx + 2)  # "sender: msg" gap
	var match_message = RegEx.new()
	match_message.compile(": (.+)")
	var message = match_message.search(msg)
	return message.get_strings()[1] if message else ""


## Parses a raw emote line and returns the emote content
func _get_emote(msg: String, sender: String) -> String:
	msg = msg.replace(sender + " ", "")
	msg = msg.substr(1, msg.length() - 2)
	return msg


func _open_url(meta: String):
	print("Opening URL " + str(meta))
	if "discord.gg/" in meta:
		PopupMessage._show_popup(
			"It is UNSAFE to join anybody's Discord if you are a minor!!! Please be careful of interactions with strangers outside of Webfishing...",
			0.0,
			true
		)
		var choice = yield(PopupMessage, "_choice_made")
		if not choice:
			return
	OS.shell_open(meta)
	# Steam.activateGameOverlayToWebPage(meta)


############
## Public ##
############


## Retrieve an array of chat messages, optionally with a limit
## @experimental
func get_all(amt_of_lines: int = 0) -> Array:
	if amt_of_lines > 0:
		var messages = Array(Network.GAMECHAT.rsplit("\n", false, amt_of_lines))
		return messages if amt_of_lines >= messages.size() else messages.slice(1, amt_of_lines)
	var messages = Network.GAMECHAT.split("\n", false)
	return Array(messages)


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


## send_letter wrapper
func send_letter(player: Actor, header: String, closing: String, body: String, items: Array = []):
	PlayerData._send_letter(int(Players.get_id(player)), header, closing, body, items)


## Convenience method for sending player notifications
func notify(msg: String):
	PlayerData._send_notification(msg)


## Get a reference to the HUD's chatbox
func get_chatbox() -> LineEdit:
	var chat = Players.local_player.hud.chat
	return chat


## Get any currently typed message from the chatbox, if any
## @experimental
func get_chatbox_text() -> String:
	var chat = get_chatbox().text
	return chat


## @experimental
func get_last_chatbox_char() -> String:
	var chat = get_chatbox_text()
	return chat[-1]


## @experimental
func get_last_chatbox_word() -> String:
	var chat = get_chatbox_text()
	var words = Array(chat.split(" "))
	return words[-1]
