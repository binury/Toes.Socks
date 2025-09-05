extends Node

signal player_added(player)
signal player_removed(player)
signal ingame
signal outgame
signal at_main_menu

var DEBUG := OS.has_feature("editor") and true

var Utils := preload("res://mods/Toes.Socks/modules/Socks.Utils/main.gd")

var by_steam_id := {}
var in_game = false
## Our player; you
var local_player
var entities


func _debug(msg, data = null):
	if not DEBUG:
		return
	print("[Socks.Players]: %s" % msg)
	if data != null:
		print(JSON.print(data, "\t"))


func _emit_game_status(sig: String):
	_debug("Game status change", sig)
	Utils.call_debounced("emit_game_status_" + sig, funcref(self, "emit_signal"), 5.0, [sig])


func _emit_player_event(sig: String, player: Actor):
	_debug("Player event", sig)
	Utils.call_debounced("emit_event_" + sig, funcref(self, "emit_signal"), 5.0, [sig, player])


func _process(__) -> void:
	if in_game and not is_player_valid(local_player):
		in_game = false
		_debug("Found no local player but was still in_game...")
		_emit_game_status("outgame")
	if (not in_game) and is_player_valid(local_player):
		in_game = true
		_debug("Found local player but was still out_game...")
		_emit_game_status("ingame")


func _is_player(node: Node) -> bool:
	return node.get("actor_type") == "player"


func _add_player(node: Node):
	by_steam_id[node.owner_id] = node


func _remove_player(node: Node):
	by_steam_id.erase(node.owner_id)


func _player_removed(node: Node):
	if !_is_player(node):
		return
	if node.name == "player":
		local_player = null
		in_game = false
		_emit_game_status("outgame")
	else:
		_remove_player(node)
	_emit_player_event("player_removed", node)


func _player_added(node: Node):
	var is_local_player := node.name == "player"
	var is_other_player := node.name.begins_with("@player@")

	if is_local_player:
		local_player = node
		_add_player(node)
		yield(get_tree().create_timer(0.6), "timeout")
		_emit_game_status("ingame")
	elif is_other_player:
		_add_player(node)
		Steam.setPlayedWith(node.owner_id)
	else:
		return
	connect("tree_exited", node, "_player_removed")
	yield(get_tree().create_timer(0.6), "timeout")
	_emit_player_event("player_added", node)


func _setup():
	entities = get_tree().current_scene.get_node("Viewport/main/entities")
	entities.connect("child_entered_tree", self, "_player_added")
	entities.connect("child_exiting_tree", self, "_player_removed")


func _check_if_ingame_and_local_player_is_ready(node: Node):
	in_game = get_tree().current_scene.name == "world"
	if in_game and node.name == "main_map":
		_setup()

func _check_if_went_to_main_menu(node: Node):
	if node.name == "main_menu":
		_emit_game_status("at_main_menu")

func _ready():
	get_tree().connect("node_added", self, "_check_if_ingame_and_local_player_is_ready")
	get_tree().connect("node_added", self, "_check_if_went_to_main_menu")


############
## Public ##
############


##  Check whether a given Actor exists as a valid player currently
func is_player_valid(player: Actor) -> bool:
	return is_instance_valid(player) and _is_player(player)


## Check whether a player exists and is valid for the given Steam ID
func check(steamid: String) -> bool:
	var id = int(steamid)
	if not id in by_steam_id:
		return false
	return is_player_valid(by_steam_id[id])


## Get a Player by their Steam ID
func get_player(steamid: String) -> Actor:
	assert(check(steamid), "No player found with id: " + steamid + "! Check if player exists first!")
	return by_steam_id[int(steamid)]


## Get player's username, either by id or by actor
func get_username(player = local_player) -> String:
	var id: int
	if typeof(player) == TYPE_STRING:
		id = int(player)
		assert(check(String(id)), "No player found with id: " + String(id) + "! Check if player exists first!")
	else:
		if !is_instance_valid(player):
			return ""
		id = player.owner_id
	return Steam.getFriendPersonaName(id)


## Get the current lobby's owner ("host")
func get_lobby_owner() -> Actor:
	if Network.STEAM_LOBBY_ID < 1:
		return local_player
	return get_player(str(Steam.getLobbyOwner(Network.STEAM_LOBBY_ID)))


## Get player's title
## (Convenience method)
func get_title(player: Actor = local_player) -> String:
	assert(
		is_player_valid(player), "Argument error - Invalid Actor received - check id & validate player object first!"
	)
	return player.get_node("Viewport/player_label").title


## Get player's Steam ID
## *ensures that the ID is a String rather than an int*
## !Always use this rather than directly referencing owner_id property!
## (Convenience method)
func get_id(player: Actor = local_player) -> String:
	assert(
		is_player_valid(player), "Argument error - Invalid Actor received - check id & validate player object first!"
	)
	return String(player.owner_id)


## Get player's cosmetics (Dictionary\<String\>)
## (Convenience method)
## `accessory`, `bobber`, `eye`, `hat`, `legs`, `mouth`, `nose`, `overshirt`, `pattern`, `primary_color`
## `secondary_color`, `species`, `tail`, `title`, `undershirt`
func get_cosmetics(player: Actor = local_player) -> Dictionary:
	return player.cosmetic_data


## Set player's cosmetic
## (Convenience method)
## Unstable/TODO
func set_cosmetic(type: String, to: String) -> void:
	if !is_player_valid(local_player):
		return
	assert(
		(
			type
			in [
				"eye",
				"legs",
				"hat",
				"mouth",
				"nose",
				"overshirt",
				"pattern",
				"primary_color",
				"secondary_color",
				"species",
				"tail",
				"title",
				"undershirt"
			]
		),
		"Argument error - Invalid cosmetic type"
	)
	local_player.call_deferred("_change_cosmetics")
	PlayerData._change_cosmetic(type, to)


## Get player's chat color
## (Convenience method)
## Returns a Color or null
func get_chat_color(player = local_player):
	var target: Actor
	if typeof(player) == TYPE_STRING:
		target = get_player(player)
	else:
		target = player

	var target_primary_color = get_cosmetics(target).get("primary_color")
	if (not target_primary_color) or (not target_primary_color in Globals.cosmetic_data):
		return null
	var player_color = Globals.cosmetic_data[target_primary_color]["file"].main_color
	return player_color


## Get player's current Vector3 position
## (Convenience method)
func get_position(player: Actor = local_player) -> Vector3:
	return player.global_transform.origin


## Retrieves the player closet to position
## If omitted, position will be nearest to the local player
func get_nearest_player(at: Vector3 = local_player.global_transform.origin) -> Node:
	if Network.PLAYING_OFFLINE or Network.STEAM_LOBBY_ID <= 0:
		return null

	var all_current_players = get_players()
	if all_current_players.size() == 0:
		return null

	var closest_player: Node
	var min_distance: float = INF

	for player in all_current_players:
		var dist = at.distance_to(get_position(player))
		if dist < min_distance:
			min_distance = dist
			closest_player = player
	return closest_player


## Get a list of (active) player names
func get_names(include_self = false) -> Array:
	var res = []
	for p in get_players(include_self):
		res.append(get_username(p))
	res.sort_custom(self, "sort_by_length")
	return res


## Find player by username
func find(username: String) -> Actor:
	username = username.to_lower()
	for p in get_players():
		var name = get_username(p)
		var name_unstylized = name.to_lower().replacen(" ", "")
		if username == name.to_lower():
			return p
		if username.replacen(" ", "") == name_unstylized:
			return p
	return null


## Get an Array of all currently active players
func get_players(include_self = false) -> Array:
	var res = []
	for p in by_steam_id.values():
		if is_instance_valid(p):
			if local_player.owner_id == p.owner_id and not include_self:
				continue
			res.append(p)
	return res


## Get a Dictionary of all currently active players
func get_players_dict(include_self = false) -> Dictionary:
	var res = {}
	for p in by_steam_id.values():
		if is_instance_valid(p):
			if local_player.owner_id == p.owner_id and not include_self:
				continue
			res[p.owner_id] = p
	return res


func is_player_blocked(id) -> bool:
	return PlayerData.players_hidden.has(int(id))


func is_player_muted(id) -> bool:
	return PlayerData.players_muted.has(int(id))


## @Deprecated - Use is_ignored instead
func is_player_ignored(id) -> bool:
	return self.is_ignored(id)

## Check if a player is either muted or ignored, on Webfishing or Steam
func is_ignored(id) -> bool:
	return is_player_blocked(id) or is_player_muted(id) or Steam.getFriendRelationship(int(id)) in [Steam.FRIEND_RELATION_BLOCKED, Steam.FRIEND_RELATION_IGNORED]

## Check if the player is busy
func is_busy(player = local_player):
	if player:
		return player.busy


static func sort_by_length(a: String, b: String) -> bool:
	return a.length() < b.length()
