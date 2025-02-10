extends Node
var isFull : bool = false

var invDict: Dictionary
var currentSlot : int = 0
signal entered_inventory
signal equipped_item
var equipped
signal dropped_all
func _ready():
	set_block_signals(!is_multiplayer_authority())
	set_process_input(is_multiplayer_authority())
	for i in range(%PlayerUI.slots.size()):
		invDict[i] = null
	
func _input(event):
	if Input.is_action_just_pressed("slot1"):
		currentSlot = 0
		change_equipped()
	if Input.is_action_just_pressed("slot2"):
		currentSlot = 1
		change_equipped()
	if Input.is_action_just_pressed("slot3"):
		currentSlot = 2
		change_equipped()
	if Input.is_action_just_pressed("slot4"):
		currentSlot = 3
		change_equipped()
		#equippedItem = %PlayerUI.swap(3)
	if Input.is_action_just_pressed("drop"):
		drop_current()
		
		
func change_equipped():
	%PlayerUI.swap(currentSlot)
	if !invDict[currentSlot]:
		#%"3rdPersonItem".display_item.rpc("Hands")
		%"3rdPersonItem".display_text.rpc("Hands") #todo this is temp
	else:
		#%"3rdPersonItem".display_item.rpc(invDict[currentSlot].itemName)
		%"3rdPersonItem".display_text.rpc(invDict[currentSlot].itemName) #todo this is temp
		equipped_item.emit()
	equipped = invDict[currentSlot]
func check_free_slot():
	for slot in range(invDict.size()):
		if invDict[slot] == null:
			isFull = false
			return slot
	isFull = true
	print("Full Inventory")
	return 22
	
func accept_item(item):
	if !is_multiplayer_authority():
		return false
	print(invDict)
	var openSlot = check_free_slot()
	if isFull:
		print("No slot to accept item: ", item)
		return false
	invDict[openSlot] = item
	if openSlot == currentSlot:
		change_equipped()
	%PlayerUI.add_item_to_ui(invDict, openSlot, item)
	entered_inventory.emit()
	return true
	
func delete_item():
	invDict[currentSlot] = null
	%PlayerUI.remove_item_ui(currentSlot)
	equipped.consume.rpc()
func drop_all():
	currentSlot = 0
	for i in range(invDict.size()):
		drop_current()
		currentSlot+=1
	dropped_all.emit()
func drop_current():
	var item = invDict[currentSlot]
	if item == null:
		return
	var droppos = get_parent().get_position()
	invDict[currentSlot] = null #Delete the item from dictionary once dropping has taken place
	change_equipped()
	%PlayerUI.remove_item_ui(currentSlot)
	item.add_to_world.rpc(droppos)
	isFull = false
	
func _on_signal_hitbox_area_entered(item):
	if !item.has_node("Interactable"):
		#print("Inventory encountered non interactable item")
		return
	if item.canPickup and !isFull and accept_item(item):
		item.remove_from_world.rpc()
	else:
		print("cant remove bc we are full or something")
		#print("Removing item from world")
