extends MeshInstance3D


@export var models : Dictionary = {
	"Hands": "res://Equippables/Hands.tres",
	"Staff": "res://Equippables/Staff.tres"
}
@export var currentResource : Resource


func _ready():
	if is_multiplayer_authority():
		self.set_visible(false)

@rpc("call_remote", "reliable", "any_peer")
func display_item(itemName):
	var item_resource = load(models[itemName])
	set_mesh(item_resource.mesh)
	set_position(item_resource.position)
	set_rotation_degrees(item_resource.rotation)
	set_scale(item_resource.scale)
	print(multiplayer.get_unique_id(), " set mesh to ", item_resource)
	
@rpc("call_remote", "reliable", "any_peer")
func display_text(itemName):
	$"../Label3D".text = itemName
	
