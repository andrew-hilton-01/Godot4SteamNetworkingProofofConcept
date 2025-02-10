@tool
extends EditorScript

func _run():
	var editor_interface = get_editor_interface()
	var selection = editor_interface.get_selection().get_selected_nodes()
	
	if selection.is_empty():
		print("No node selected!")
		return
	
	for node in selection:
		if node is MeshInstance3D:
			var item_resource: Resource = node.get("item_data") # must be assigned in inspector!
			if item_resource:
				item_resource.position = node.position
				item_resource.rotation = node.rotation_degrees
				item_resource.scale = node.scale
				item_resource.mesh = node.mesh
				ResourceSaver.save(item_resource, item_resource.resource_path)
				print("Updated resource:", item_resource.resource_path)
			else:
				print("Node", node.name, "has no item_resource assigned!")
