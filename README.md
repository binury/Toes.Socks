# S☃️cks

<img src="https://i.imgur.com/wEipOD5.png" width="38%" alt="Sockpuppet pixel art" />
<br/>
<small>
(Original) Sockpuppet pixel art by <a href="https://es.pixilart.com/to-hat-banana">okayo top hat</a>
</small>
<br/>

### **Socks** is the _best_ library for Webfishing modders writing [GDWeave](https://github.com/NotNite/GDWeave) mods.

Our motivation publishing this library is primarily to share these solutions and utilities we've written to address
problems we've personally encountered while making mods,
with the hopes you might be able to spend more time focused on fun than overcoming technical roadblocks.

You may also like to check out [Better Webfishing Mod Template](https://github.com/binury/better_webfishing_mod_template) for a template/guide to making
patch mods that write over the game's code.

 --- 

```py
## Example Usage of building a mod with Socks

onready var Players = get_node("/root/ToesSocks/Players")
onready var Chat = get_node("/root/ToesSocks/Chat")

var currently_worn_hat := "hat_none"
var is_lobby_owner := false

func _ready():
	Chat.connect("player_messaged", self, "_on_player_messaged")
	Players.connect("ingame", self, "_on_ingame")
	Players.connect("outgame", self, "_on_outgame")


func _on_player_messaged(message: String, player_name: String, is_self: bool):
	if is_self: return
	Chat.send("Hi, %s!" % player_name)


func _on_ingame() -> void:
	# Initialize mod, once we are in-game
	currently_worn_hat = Players.get_cosmetics()["hat"]
	is_lobby_owner = Players.local_player == Players.get_lobby_owner()


func _on_outgame() -> void:
	# Teardown in prep for next lobby
	currently_worn_hat = "hat_none"
	is_lobby_owner = false
```

## Modules

GDScriptify has started breaking when generating our docs - forgive our outdated [docs](./docs/index.md) in the meantime until we fix that...

### [Chat](https://github.com/binury/Toes.Socks/blob/main/mods/Toes.Socks/modules/Socks.Chat/main.gd)

### [Players](https://github.com/binury/Toes.Socks/blob/main/mods/Toes.Socks/modules/Socks.Players/main.gd)

### [Hotkeys](https://github.com/binury/Toes.Socks/blob/main/mods/Toes.Socks/modules/Socks.Hotkeys/hotkeys.gd)

```py
# tablecopter.gd

var enabled := false
func _ready():
	# T Hotkey
	var toggle_signal_name = Hotkeys.add(
		{"name": "toggle_tablecopter", "label": "Toggle Tablecopter", "key_code": KEY_T, "repeat": false }
	)
	Hotkeys.connect(toggle_signal_name, self, "_handle_toggle")

	# CTRL+T Hotkey
	var mode_toggle_signal_name = Hotkeys.add(
		{"name": HOTKEY_NAME + "_mode", "label": HOTKEY_LABEL + " Mode", "key_code": KEY_T, "repeat": false, "modifiers": ["control"] }
	)
	Hotkeys.connect(mode_toggle_signal_name, self, "_handle_mode_toggle")

func _handle_toggle():
	enabled = !enabled
```

See [Hotkey Configuration Documentation](https://github.com/binury/Toes.Socks/blob/main/mods/Toes.Socks/modules/Socks.Hotkeys/hotkey_config.gd) for all hotkey options


## Example projects

- [Finapse X](https://github.com/geringverdien/TeamFishnet/tree/main/Finapse%20X)
- [Jarvis](https://github.com/geringverdien/TeamFishnet/blob/main/Jarvis/project%20-%20prod/mods/eli.Jarvis/main.gd)
- [Trivia](https://github.com/binury/Toes.Trivia)
- [Pip Pals](https://github.com/binury/Toes.Pip-Pals)

<br/>

## 📚 Project Links

- [Changelog](https://thunderstore.io/c/webfishing/p/toes/Socks/changelog)  
- [Contributing (PRs welcome)](https://github.com/binury/Toes.Socks/pulls)  
- [Known Issues](https://github.com/binury/Toes.Socks/issues?q=sort%3Aupdated-desc+is%3Aissue+is%3Aopen)  
- [Feedback & Bug Reports (Discord)](https://discord.gg/kjf3FCAMDb)  
- [Roadmap & Feature Requests](https://github.com/binury/Toes.Socks/issues?q=sort%3Aupdated-desc%20is%3Aissue%20is%3Aopen%20label%3Aenhancement)

