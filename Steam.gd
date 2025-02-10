extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_environment("SteamAppID", str(480)) #Steam ID for SpaceWars dev game
	OS.set_environment("SteamGameID", str(480))
	Steam.steamInitEx()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	Steam.run_callbacks()
