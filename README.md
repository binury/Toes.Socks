# Toes.Socks

<img src="./assets/sockpuppet.png" width="300" alt="Sockpuppet pixel art" />

Socks is an evolving (work-in-progress) development library for [GDWeave](https://github.com/NotNite/GDWeave) mods.
Our motivation publishing this library is primarily to share these solutions and utilities we've written to address
problems we've personally encountered while making mods,
with the hopes you might be able to spend more time focused on fun than overcoming technical roadblocks.

The Players module is borrowed from [BlueberryWolf's](https://thunderstore.io/c/webfishing/p/BlueberryWolfi/BlueberryWolfiAPIs)
but with performance and developer-experience improvements at the cost of being backward-compatible.
Nonetheless, you should find `Socks.Players` will suit your existing needs without many changes.
In addition, our modules introduce convenient utilities to make mod building more straightforward.
The `Socks.Chat` module was created to address the naturally opaque and cumbersome process of hooking into the game's chat methods.

Sockpuppet pixel art by [okayo top hat](https://es.pixilart.com/to-hat-banana)

## Usage

[Documentation](docs/index.md) **is** generated from comments within the source files. Be sure to check it out!

### Example

```gds
onready var Players = get_node_or_null("/root/ToesSocks/Players")
onready var Chat = get_node_or_null("/root/ToesSocks/Chat")

func _ready():
	Chat.connect("player_messaged", self, "_on_player_messaged")


func _on_player_messaged(message: String, player_name: String, is_self: bool):
	if is_self: return

	Chat.send("Hi, %s!" % player_name)
```

### Example projects

- [Trivia](https://github.com/binury/Toes.Trivia)


## Help

Please feel free to submit [RFC issues](https://github.com/buritica/mgt/blob/master/templates/rfc_template.md) with ideas for
new utilities or even modules. I can be reached on Discord `@toes` for discussion, collaboration, or questions.
If you need general help building mods, I suggest joining the [Webfishing Modding Discord](https://discord.com/invite/PMdFCrJnUb).
