# Chat

**Extends**: `Node`

## Table of contents

### Functions

|Name|Type|Default|
|:-|:-|:-|
|[_parse_color_string](#_parse_color_string)|`String`|-|
|[_get_sender](#_get_sender)|`String`|-|
|[_get_message](#_get_message)|`String`|-|
|[is_local_player](#is_local_player)|`-`|-|
|[send_raw](#send_raw)|`String`|-|
|[write](#write)|`String`|-|
|[send](#send)|`String`|-|
|[emote](#emote)|`String`|-|
|[send_as](#send_as)|`String`|-|
|[emote_as](#emote_as)|`String`|-|
|[notify](#notify)|`String`|-|

## Functions

### _parse_color_string

```gdscript
func _parse_color_string(s: String) -> String
```

Facilitates passing predefined color names in addition to raw RGB values

**Returns**: `String`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`s`|`String`|-|

### _get_sender

```gdscript
func _get_sender(msg: String) -> String
```

Parses a raw message line and returns the message's sender

**Returns**: `String`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`msg`|`String`|-|

### _get_message

```gdscript
func _get_message(msg: String) -> String
```

Parses a raw message line and returns the actual message content

**Returns**: `String`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`msg`|`String`|-|

### is_local_player

```gdscript
func is_local_player(name) -> bool
```

Check whether the local_player's name matches the given name This is possibly broken/forged due to namespace collision There is no workaround for this yet. Use with caution! Validate if possible

**Returns**: `bool`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`name`|-|-|

### send_raw

```gdscript
func send_raw(msg: String, color: String = "Grey", local: bool = false)
```

Send a raw message without any special handling Useful for e.g., non-player or system messages

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`msg`|`String`|-|
|`color`|`String`|`"Grey"`|
|`local`|`bool`|`false`|

### write

```gdscript
func write(msg: String, local:bool = false)
```

Write a (raw) message to the local_player's chat Since this is client-side only, no sanitization is done

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`msg`|`String`|-|
|`local`|`bool`|`false`|

### send

```gdscript
func send(msg: String, color: String = "Grey", local: bool = false)
```

Send a chat message Color can be a plain RGB hex color code or any of the following in-game predefined colors: `white` `tan` `brown` `red` `maroon` `grey` `green` `blue` `purple` `salmon` `yellow` `black` `orange` `olive` `teal`

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`msg`|`String`|-|
|`color`|`String`|`"Grey"`|
|`local`|`bool`|`false`|

### emote

```gdscript
func emote(msg: String, color: String = "Grey", local: bool = false)
```

Send an emote

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`msg`|`String`|-|
|`color`|`String`|`"Grey"`|
|`local`|`bool`|`false`|

### send_as

```gdscript
func send_as(who: String, msg: String, color: String = "Grey", local: bool = false)
```

Send a chat as a given player

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`who`|`String`|-|
|`msg`|`String`|-|
|`color`|`String`|`"Grey"`|
|`local`|`bool`|`false`|

### emote_as

```gdscript
func emote_as(who: String, msg: String, color: String = "Grey", local: bool = false)
```

Send an emote as a given player

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`who`|`String`|-|
|`msg`|`String`|-|
|`color`|`String`|`"Grey"`|
|`local`|`bool`|`false`|

### notify

```gdscript
func notify(msg: String)
```

Convenience method for sending player notifications

#### Parameters

|Name|Type|Default|
|:-|:-|:-|
|`msg`|`String`|-|

---

Powered by [GDScriptify](https://github.com/hiulit/GDScriptify).
