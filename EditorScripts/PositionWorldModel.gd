@tool
extends EditorScript
var item = "res://Equippables/Hands.tres" #Must change this path everytime to item Resource Required

func _run():
	var selection = EditorInterface.get_selection().get_selected_nodes()[0]
	item = ResourceLoader.load(item)
	item.mesh = selection.mesh
	item.position = selection.position
	item.rotation.x = rad_to_deg(selection.rotation.x)
	item.rotation.y = rad_to_deg(selection.rotation.y)
	item.rotation.z = rad_to_deg(selection.rotation.z)
	item.scale = selection.scale
	ResourceSaver.save(item, item.resource_path)
	print("Updated resource:", item.resource_path)
