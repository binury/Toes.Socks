# Changelog

## v0.4.0
- New `outgame` signal emitted from Players
    - You can use this like `ingame` instead of testing for the existence of `Players.local_player` etc
- Fixed `Players.in_game` was never properly reset to false after leaving a game
    - We'd sorta never ended up using this, personally, and honestly forgot about it until now, sorry!

## v0.3.3
- Hotfixed URI messages causing crash; sorry!
    - This happened because of an infinite loop! Link messages would trigger another link and so on.
    - Fixed this by adding a negative-lookahead to the match to exclude messages with BBCode `[url=example.com]link[/url]`

## v0.3.2
- Hotfixed Chat module issues caused by recent LucyTools update/conflict causing messages to include unexpected BBCode

## v0.3.1
- Hotfixed issue with URIs not being detected due to presence of BBCode in messages (LucyTools mod conflict)

## v0.3.0
- New Socks.Utils module
- Added Players.get_lobby_owner for retrieving the current lobby's host
- Changed Players methods to default to the local player when appropriate:
    - get_username
    - get_title
    - get_id
    - get_chat_color
    - get_position
- Chat links should now open in your browser rather than within the Steam overlay
- Opening Discord links will now require viewing a safety warning and confirmation from the user

## v0.2.7
- Fixes `Recently Seen Players` Steam integration. Now everyone you meet in lobbies will
 be listed in your Game Overview > Recent Players UI.

## v0.2.6
- Hotfix Players.chat

## v0.2.5
- Added Players.is_player_ignored helpers for checking if a player has been muted or blocked

## v0.2.4
- Links will now generate for URL's in messages even when the message contains other preceding text
- System messages (e.g., MOTD) will now also generate clickable `[LINK]`s


## v0.2.1

- Added clickable links for URLs pasted into game chat

## v0.2.0

- Fixed `player_removed` event not emitting as expected     
- Dependency on [NoNameFix](https://thunderstore.io/c/webfishing/p/toes/NoNameFix/) changed to v1.0.0

## v0.1.99

### New Socks.Chat methods

- `get_all`, `get_chatbox`

### New Socks.Players methods
- `Players.get_chat_color`
- `Players.get_names`
- `Players.find`