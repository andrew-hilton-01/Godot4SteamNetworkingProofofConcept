# Godot 4.3 Steam Multiplayer Proof of Concept

 This project uses plugins Steam Multiplayer Peer and GodotSteam to integrate the Steam multiplayer p2p framework within Godot's higher level networking (MultiplayerSynchronizer and MultiplayerSpawner node and built-in RPC calls).
 Additionally, trenchbroom is used via the Qodot 4.x plugin to create the map, all third party plugins and assets are attributed at the bottom.
## features
- Lethal Company inspired item collection and retrieval gameplay
- Instantiate multiple players on a peer to peer mesh / host-authoritative hybrid system through the Steam lobby API.
- Host authoritative AI attacks any player via Signals monitored only by host-peer, keeping AI consistent.
- Theoretically should work for any amount of players, was only tested between 2 on an average ping of about 50ms.
## important notes
- Network rollback / tick system is needed to increase the ability for the game to run properly, quickly, and in-sync on differing pings and amounts of packet loss
- As this was created mainly to test the ability to merge each API and wrapper together (Steam Multiplayer Peer, Godot Steam, Steamworks API, Godot High Level Networking) and prove multiplayer through Godot and Steam possible, all "fun-ness" / gameplay features are incredibly barebones roughly implemented.
## running and using the project
1. Clone the repo,
2. open the project in Godot 4.3
3. ensure plugins load properly, may have to delete and manually reinstall (plugins used in attribution section note: ensure 4.x support and use project in Godot 4.3 if manually installing plugins).
4. Make sure both players have Steam logged in, one will click host after running from editor and copy the Steam lobby code printed in the editor output and have other player paste it into the text field and press connect.
5. If all plugins are installed properly and the project isn't properly open, a system restart has fixed this issue in the past.
6. LAN is hardcoded with IP and port used so change that as needed if you wish to run locally. Use "localhost" as IP to run multiple instances of the game on one computer.

## keybinds / gameplay
- Host can press "P" to enable the AI once peer connection has been made and both players are in game.
- Left click a player or an enemy to shove
- Hold space and use Source movement bhops to move around faster
- Item collection area each player must bring items to and drop them without being eliminated by enemy AI is the blue glowing room, a label3d will show scrap needed to win when you drop items there.

## attributions
- QodotPlugin  
QodotPlugin is licensed under the MIT License.  
Source: https://github.com/QodotPlugin/Qodot

- GodotSteam  
GodotSteam is licensed under the MIT License.  
Source: https://github.com/GodotSteam/GodotSteam  

- SteamMultiplayerPeer  
SteamMultiplayerPeer is licensed under the MIT License.  
Source: https://github.com/expressobits/steam-multiplayer-peer

- PSX First Person Arms
Creator: https://drillimpact.itch.io/
Source: https://drillimpact.itch.io/psx-first-person-arms-free

- Retro Urban Kit - Included some textures from this asset kit in the map
Creator: https://kenney-assets.itch.io/
Source: https://kenney-assets.itch.io/retro-urban-kit

## contributing
feel free to fork and submit pull requests.

## license
This project is licensed under the terms of the MIT license, details in LICENSE.txt

## contact
for questions or suggestions, reach out at andrew2001hilton@gmail.com

