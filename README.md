# Socks

<img src="https://i.imgur.com/K2XB6AP.png" width="60%" alt="Sockpuppet pixel art" />
<br/>
<a href='https://ko-fi.com/A0A3YDMVY' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi2.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
<br/>

**Socks** is an evolving (work-in-progress) development library for [GDWeave](https://github.com/NotNite/GDWeave) mods.
Our motivation publishing this library is primarily to share these solutions and utilities we've written to address
problems we've personally encountered while making mods,
with the hopes you might be able to spend more time focused on fun than overcoming technical roadblocks.

Check out [Better Webfishing Mod Template](https://github.com/binury/better_webfishing_mod_template) for a template/guide to making
mods which patch over the game's code.


Sockpuppet pixel art by [okayo top hat](https://es.pixilart.com/to-hat-banana)

## Usage

### Example

```gds
onready var Players = get_node("/root/ToesSocks/Players")
onready var Chat = get_node("/root/ToesSocks/Chat")

func _ready():
	Chat.connect("player_messaged", self, "_on_player_messaged")


func _on_player_messaged(message: String, player_name: String, is_self: bool):
	if is_self: return

	Chat.send("Hi, %s!" % player_name)
```

### Example projects

- [Finapse X](https://github.com/geringverdien/TeamFishnet/tree/main/Finapse%20X)
- [Jarvis](https://github.com/geringverdien/TeamFishnet/blob/main/Jarvis/project%20-%20prod/mods/eli.Jarvis/main.gd)
- [Trivia](https://github.com/binury/Toes.Trivia)
- [Pip Pals](https://github.com/binury/Toes.Pip-Pals)


<br/>

## Help!

Please feel free to submit [RFC issues](https://github.com/buritica/mgt/blob/master/templates/rfc_template.md) with ideas for
new utilities or even modules. I can be reached on Discord `@toes` for discussion, collaboration, or questions. I recommend avoiding the Webfishing modding Discord server.

> [!TIP]
> You can [reach out to me](https://ko-fi.com/c/993813af6b) for help with building your mod project.
