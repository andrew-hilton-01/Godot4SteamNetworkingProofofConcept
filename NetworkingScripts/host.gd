extends Node

# Track connected peers
var peers = {}
# Called when the node enters the scene tree for the first time.
var player_inventories: Dictionary = {} # {peer_id: {slot: item}}
func _ready():
	if multiplayer.connected_to_server:
		print("Host peer initialized")

func wait(time):
	await get_tree().create_timer(time).timeout
	
	

### Initial Networking and playerlist setup ###


	
@rpc("any_peer", "reliable")
func register_peer():
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = 1
		
	print("Registered peer: ", peer_id)
	peers[peer_id] = null
	#print(peers)
		
@rpc("any_peer", "reliable")
func bind_peer_to_player(playerPath):
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = 1
	
	var player = get_node_or_null(playerPath)
	#print("id: ", peer_id, " path: ", playerPath, " object: ", player)
	peers[peer_id] = player
	#print("Bounded peer dictionary: ", peers)
	#init_inventories(4)# Not currently storing inventories on host, we simply are delivered information from inventory as its needed
### Inventory Functions ###
#@rpc("authority", "reliable")
#func init_inventories(slot_count):#Stores inventory data structure on host for each connected player
	#if !multiplayer.is_server():
		#return
	#for peer_id in peers.keys():
		#player_inventories[peer_id] = {}
		#for i in range(slot_count):
			#player_inventories[peer_id][i] = null # empty slots
	#print(player_inventories)
	
	
@rpc("any_peer", "reliable")
func display_equipped(itemPath, viewmodelPath):
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = 1
		
	var item = get_node_or_null(itemPath)
	var worldmodel = get_node_or_null(viewmodelPath)
	for id in peers.keys():#displays to all peers except who called it
		if id != peer_id:
			worldmodel.rpc_id(id, "update_vm", item.viewmodel)
	
@rpc("any_peer", "reliable")
func display_no_equipped(viewmodelPath):
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = 1
	
	var worldmodel = get_node_or_null(viewmodelPath)
	for id in peers.keys():#displays to all peers except who called it
		if id != peer_id:
			worldmodel.rpc_id(id, "update_vm", null)
	
func is_valid_pickup(item) -> bool:
	return item != null and item.canPickup
	
@rpc("authority", "reliable")
func give_item(playerPath, itemPath): #Broadcasts the item to a specific player' inventory to be handled locally
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = 1
		
	var player = get_node_or_null(playerPath)
	var item = get_node_or_null(itemPath)
	print(item)
	var inv = player.get_node("Inventory")
	inv.accept_item(item)

@rpc("any_peer", "reliable")
func place_item(itemPath, pos):
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = 1
	
	var item = get_node_or_null(itemPath)
	print(peer_id, " dropping: ", item)
	item.position = pos
	item.set_visible(true)
	await wait(2.0)
	item.monitoring = true
	
### SIGNAL RECIEVER (mostly for gamestate) ###
 #Signal Recieved from an Item which is entered by Player
func _on_item_area_entered(playerHitbox: Area3D, item: Area3D) -> void:
	var player = playerHitbox.playerNode
	var player_id = peers.find_key(player) #Finds player network ID from peers dictionary
	print(player, " entered item area: ", item.itemName)
	if is_valid_pickup(item) and !player.get_node("Inventory").isFull:
		if player_id != 1:
			rpc_id(player_id, "give_item", player.get_path(), item.get_path())
		else:
			give_item(player.get_path(), item.get_path())
		item.rpc("remove_from_world") #This is only ran by host by nature of the signal architecture of this function

func _physics_process(_delta):
	if !multiplayer.is_server():
		return
	return
	if peers.has(1) and peers[1]:  # check if key exists and isn't null
		get_tree().call_group("enemies", "update_target_location", peers[1].position)
	
	
