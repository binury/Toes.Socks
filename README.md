# Toes.Socks

WebFishing development library

## About

Socks is an evolving development library for gdscript mods. (It is usable but not feature complete yet.)

The Players module is borrowed from [BlueberryWolf's](https://thunderstore.io/c/webfishing/p/BlueberryWolfi/BlueberryWolfiAPIs)
while significantly improving performance and usability at the cost of backward compatibility. However, you should find
Socks.Players will suit your existing needs without many changes.. In addition, our modules bring new features to make mod building more straightforward
and focused on fun than overcoming technical roadblocks. This is also our motivation for working on and publishing this library.
The Socks Chat module was created to address the naturally opaque and cumbersome process of hooking into the game's chat methods.

## Usage

Documentation is included within the source files be sure to check it out!


### Example

```gds
func _ready():
	Players = get_node_or_null("/root/ToesSocks/Players")
	Chat = get_node_or_null("/root/ToesSocks/Chat")

	Chat.connect("player_messaged", self, "_on_player_messaged")


func _on_player_messaged(message: String, player_name: String, is_self: bool):
    if is_self: return

    print(player_name + ": " + message)

    var response = "Hi, %n!"
    Chat.send(response % player_name)
```

#### Example projects

[TODO!]