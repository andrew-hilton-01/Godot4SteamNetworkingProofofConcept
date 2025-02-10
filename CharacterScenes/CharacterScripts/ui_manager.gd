extends Control

var prevSlot = 0

@onready var slots = $Hotbar.get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !is_multiplayer_authority():
		visible = false
func _process(_delta):
	if !is_multiplayer_authority():
		return
	#%Info.text = ("FPS %d" % Engine.get_frames_per_second())
	$InfoBar/InfoPanel/Info.value = get_parent().energy
	$HPBar/HealthPanel/Health.value = get_parent().health
	
	
func swap(slot: int):
	if slot == prevSlot:
		return
	slots[slot].get_child(0).set_visible(false)
	slots[prevSlot].get_child(0).set_visible(true)
	prevSlot = slot

func add_item_to_ui(inv, slot, item):
	slots[slot].get_child(1).set_texture(item.icon)

func remove_item_ui(slot):
	slots[slot].get_child(1).set_texture(null)
