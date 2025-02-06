class_name Players
extends Node

signal _player_added(player)
signal _player_removed(player)
signal _ingame()

var by_steam_id := {}
var in_game = false
var local_player
var entities

func _ready():
	get_tree().connect("node_added", self, "_player_ready")

func _player_ready(node: Node):
	var map: Node = get_tree().current_scene
	in_game = map.name == "world"

	if node.name != "main_map": return
	if not in_game: return
	entities = get_tree().current_scene.get_node("Viewport/main/entities")

	print("playerAPI init")
	# add playerAPI child node with injectedMain.gd script to player

	entities.connect("child_entered_tree", self, "_player_added")

func is_player(node: Node) -> bool:
	return node.name == "player" or node.name.begins_with("@player@")

func _add_player(node: Node):
	by_steam_id[node.owner_id] = node

func _player_removed(node):
	if node.name == "player":
		local_player = null
	emit_signal("_player_removed", node)

func _player_added(node):
	if node.name == "player":
		local_player = node
		_add_player(node)
		yield (get_tree().create_timer(0.5), "timeout")
		emit_signal("_ingame")
	elif node.name.begins_with("@player@"):
		_add_player(node)
	else: return

	connect("tree_exited", node, "_player_removed")

	yield (get_tree().create_timer(0.5), "timeout")
	emit_signal("_player_added", node)


############
## Public ##
############

##  Check whether a given Actor exists as a valid player currently
func is_player_valid(player:Actor) -> bool:
	return is_instance_valid(player) and is_player(player)


## Check whether a player exists and is valid for the given ID
func check_player_by_steamid(steamid: String) -> bool:
	if not steamid in by_steam_id: return false
	return is_player_valid(by_steam_id[steamid])


## Get a Player by their Steam ID
func get_player_from_steamid(steamid: String) -> Actor:
	assert(
		check_player_by_steamid(steamid),
		"No player found with id: " + steamid + "! Check if player exists first!"
	)
	return by_steam_id[steamid]


## Get player's Steam name
func get_player_name(player: Actor) -> String:
	return Steam.getFriendPersonaName(player.owner_id)


## Get player's title
func get_player_title(player: Actor) -> String:
	assert(
		is_player_valid(player),
		"Argument error - Invalid Actor received - validate player object first!"
	)
	return player.get_node("Viewport/player_label").title


## Get player's Steam ID
func get_player_steamid(player: Actor) -> int:
	assert(
		is_player_valid(player),
		"Argument error - Invalid Actor received - validate player object first!"
	)
	return player.owner_id


## Get player's cosmetics (Dictionary\<String\>)
## `accessory`, `bobber`, `eye`, `hat`, `legs`, `mouth`, `nose`, `overshirt`, `pattern`, `primary_color`
## `secondary_color`, `species`, `tail`, `title`, `undershirt`
func get_player_cosmetics(player: Actor) -> Dictionary:
	return player.cosmetic_data


## Get player's current Vector3 position
func get_player_position(player: Actor) -> Vector3:
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
		var dist = at.distance_to(get_player_position(player))
		if dist < min_distance:
			min_distance = dist
			closest_player = player
	return closest_player


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
func get_players_dict() -> Dictionary:
	var res = {}
	for p in by_steam_id.values(): if is_instance_valid(p): res[p.owner_id] = p
	return res
