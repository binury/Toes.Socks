# Players

**Extends**: `Node`

## Table of contents

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[is_player_valid](#is_player_valid)|`Actor`|-|
|[check](#check)|`String`|-|
|[get_player](#get_player)|`String`|-|
|[get_username](#get_username)|`-`|-|
|[get_title](#get_title)|`Actor`|-|
|[get_id](#get_id)|`Actor`|-|
|[get_cosmetics](#get_cosmetics)|`Actor`|`local_player`|
|[set_cosmetic](#set_cosmetic)|`String`|-|
|[get_position](#get_position)|`Actor`|-|
|[get_nearest_player](#get_nearest_player)|`Vector3`|`local_player.global_transform.origin`|
|[get_players](#get_players)|`-`|`false`|
|[get_players_dict](#get_players_dict)|`-`|`false`|
|[is_busy](#is_busy)|`-`|`local_player`|

## Functions

### is_player_valid

```gdscript
func is_player_valid(player:Actor) -> bool
```

Check whether a given Actor exists as a valid player currently

**Returns**: `bool`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`player`|`Actor`|-|

### check

```gdscript
func check(steamid: String) -> bool
```

Check whether a player exists and is valid for the given Steam ID

**Returns**: `bool`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`steamid`|`String`|-|

### get_player

```gdscript
func get_player(steamid: String) -> Actor
```

Get a Player by their Steam ID

**Returns**: `Actor`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`steamid`|`String`|-|

### get_username

```gdscript
func get_username(player) -> String
```

Get player's username, either by id or by actor

**Returns**: `String`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`player`|-|-|

### get_title

```gdscript
func get_title(player: Actor) -> String
```

Get player's title (Convenience method)

**Returns**: `String`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`player`|`Actor`|-|

### get_id

```gdscript
func get_id(player: Actor) -> String
```

Get player's Steam ID
*ensures that the ID is a String rather than an int* Always use this rather than directly referencing owner_id property (Convenience method)

**Returns**: `String`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`player`|`Actor`|-|

### get_cosmetics

```gdscript
func get_cosmetics(player: Actor = local_player) -> Dictionary
```

Get player's cosmetics (Dictionary\<String\>) (Convenience method) `accessory`, `bobber`, `eye`, `hat`, `legs`, `mouth`, `nose`, `overshirt`, `pattern`, `primary_color` `secondary_color`, `species`, `tail`, `title`, `undershirt`

**Returns**: `Dictionary`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`player`|`Actor`|`local_player`|

### set_cosmetic

```gdscript
func set_cosmetic(type: String, to: String) -> void
```

Set player's cosmetic (Convenience method) Unstable/TODO

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`type`|`String`|-|
|`to`|`String`|-|

### get_position

```gdscript
func get_position(player: Actor) -> Vector3
```

Get player's current Vector3 position (Convenience method)

**Returns**: `Vector3`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`player`|`Actor`|-|

### get_nearest_player

```gdscript
func get_nearest_player(at: Vector3 = local_player.global_transform.origin) -> Node
```

Retrieves the player closet to position If omitted, position will be nearest to the local player

**Returns**: `Node`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`at`|`Vector3`|`local_player.global_transform.origin`|

### get_players

```gdscript
func get_players(include_self = false) -> Array
```

Get an Array of all currently active players

**Returns**: `Array`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`include_self `|-|`false`|

### get_players_dict

```gdscript
func get_players_dict(include_self = false) -> Dictionary
```

Get a Dictionary of all currently active players

**Returns**: `Dictionary`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`include_self `|-|`false`|

### is_busy

```gdscript
func is_busy(player = local_player)
```

Check if the player is busy

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`player `|-|`local_player`|

---

Powered by [GDScriptify](https://github.com/hiulit/GDScriptify).
