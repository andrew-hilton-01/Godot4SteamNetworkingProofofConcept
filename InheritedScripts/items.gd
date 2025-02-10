extends Node3D
@export var canEquip : bool
@export var canGrab : bool
@export var canScrap : bool
@export var scrapAmt : int
@export var itemName : String
@export var canPickup : bool
@export var icon : CompressedTexture2D
@export var weight : float
@export var isWeapon : bool
@export var isConsumable : bool
@export var energyProvided : int
func _ready():
	itemName = name
	pass
func wait(time):
	await get_tree().create_timer(time).timeout
	
@rpc("any_peer", "call_local", "reliable")
func consume():
	queue_free()
@rpc("any_peer", "call_local", "reliable")#call_local allows host to call.
func remove_from_world():
	set_visible(false)
	canPickup = false
	set_process_mode(Node.PROCESS_MODE_DISABLED)#4 is paused
@rpc("any_peer", "call_local", "reliable")#call_local allows host to call.
func add_to_world(pos):
	print("added this item to world at pos: ", pos)
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	set_visible(true)
	set_global_position(pos)
	#print(process_mode)
	#print("waiting 2s to be able to pickup")
	await wait(2.0)
	#print(self.position)
	#print("picker up")
	canPickup = true
