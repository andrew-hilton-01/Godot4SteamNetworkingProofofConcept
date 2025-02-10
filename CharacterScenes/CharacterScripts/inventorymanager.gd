extends Control
var maxItems : int = 4
var inventory : Array = []
@onready var hotbar = $HotBar.get_children()
var isFull : bool = false
const RED = Color(1.0,0.0,0.0,1.0)
var currSlot : int = 0
@onready var hands = $"../CharacterBody3D/Head/ViewModel"
func _ready():
	pass

func updateUI():
	for i in range(hotbar.size()):
		if i < inventory.size():
			hotbar[i].set_text(inventory[i].itemName) # set text for items in inventory
		else:
			hotbar[i].set_text("[]") # clear unused hotbar slots
		hotbar[i].set("theme_override_colors/font_color", Color(0,0,0,1.0))
	isFull = inventory.size() == maxItems
	if inventory.size() > 0:
		hotbar[currSlot].set("theme_override_colors/font_color", RED)

func add_item(item):
	inventory.append(item)
	item.remove_from_world()
	updateUI()
	hands.pickup()
	%PlayerUI.add_item(item)
	
func equip(slot):
	currSlot = slot
	updateUI()
	print("Swapping", slot)
	%PlayerUI.swap(slot)
func place_location():
	var location = Marker3D.new()
	self.get_parent().get_parent().add_child(location) #Adds marker3D to root as a new setpos for dropping items, etc
	location.set_position($"../CharacterBody3D".get_position())
	print($"../CharacterBody3D".get_global_position())
	return location
	
func drop(slot):
	currSlot = slot
	if slot + 1 > inventory.size():
		return
	if hotbar[slot].get_text() != "" and inventory[slot] != null:
		var itemPos = place_location()
		inventory[slot].set_position(Vector3(0,0,0))
		inventory[slot].add_to_world(itemPos)
		
		
		hotbar[slot].set_text("")
		inventory.remove_at(slot)
	else:
		return ("Can't Drop")
	
	updateUI()
