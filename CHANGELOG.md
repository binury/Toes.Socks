# Changelog

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