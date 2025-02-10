extends Node
@export var Levels : Array[String]
var testlevel : String = "res://WorldScenes/TestLevel.tscn"
var lobby_id = 0
var peer = SteamMultiplayerPeer.new()
var selected_id = ""
### RPC STUBS ###
@rpc
func register_peer():
	pass

func _ready():
	pass
func join_lobby(id):
	Steam.joinLobby(id)
	await Steam.lobby_joined
	multiplayer.multiplayer_peer = peer
	
	await multiplayer.peer_connected
	spawn_level(testlevel)
	queue_free()
	
func _on_host_pressed():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 4)
	peer.create_host(0)
	multiplayer.multiplayer_peer = peer
	Steam.lobby_created.connect(_on_lobby_created)

func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print(lobby_id)
		spawn_level(testlevel)
		queue_free()
func _on_join_pressed():
	if $ItemList/TextEdit.text == "": #LAN Connect
		$"../Steam".queue_free()
		peer=ENetMultiplayerPeer.new()
		peer.create_client("localhost", 5122) #Available port as of 2/20/2025
		multiplayer.multiplayer_peer = peer
		await multiplayer.peer_connected #Ensures we are connected before trying to add the peer otherwise we get errors
		print("conncted!")
	else: #If using steamworksAPI
		selected_id = int($ItemList/TextEdit.text)
		var peer = SteamMultiplayerPeer.new()
		#multiplayer.multiplayer_peer = peer
		Steam.joinLobby(selected_id)
		await Steam.lobby_joined
		print_status.rpc()
		#await multiplayer.peer_connected
		print("peer connected")
		var connecting_id = Steam.getLobbyOwner(selected_id)
		peer.create_client(connecting_id, 0)
		multiplayer.multiplayer_peer = peer
	
	spawn_level(testlevel)
	queue_free()
@rpc("call_local", "any_peer")
func print_status():
	print("steam lobby joined")
func _on_lan_pressed():
	$"../Steam".queue_free()
	peer=ENetMultiplayerPeer.new()
	peer.create_server(5122)
	multiplayer.multiplayer_peer = peer
	print("Hosting LAN")
	spawn_level(testlevel)
	queue_free()
	

#func load_level(data):
	#print("Data: ", data)
	#var level = preload("res://WorldScenes/TestLevel.tscn").instantiate()
	#queue_free()
	#return level
	
#func _on_lobby_created(connect, id):
	#if connect:
		#lobby_id = id
		#Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName()+"'s Lobby"))
		#Steam.setLobbyJoinable(lobby_id, true)
		#print(lobby_id)
		#$Label.set_size(Vector2(500, 500))
		#$Label.text  = str(lobby_id)
		
func spawn_level(level):
	level = load(level) as PackedScene
	var level_instance = level.instantiate()
	get_parent().add_child(level_instance)
	
