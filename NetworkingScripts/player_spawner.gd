extends MultiplayerSpawner

@export var playerScene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawnPlayer
	if is_multiplayer_authority():
		call_deferred("spawn", 1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)
		
var players = {}

func spawnPlayer(data):
	var p = playerScene.instantiate()
	p.set_multiplayer_authority(data)
	players[data] = p
	#print("Spawning: ", p, "\n", "Playerlist: ", players)
	#print(data)
	p.name = str(data)
	return p
func removePlayer(data):
	players[data].queue_free()
	players.erase(data)
	
