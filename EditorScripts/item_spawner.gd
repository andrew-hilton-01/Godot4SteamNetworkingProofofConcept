@tool
extends EditorScript
#highlight navregion, run to instantiate item node given from path inside function at 
# random point which is ontop of surface 8 (floor)
func _run():
	var selection = get_editor_interface().get_selection()
	if selection.get_selected_nodes().is_empty():
		print("no selection")
		return
	
	var navmap = selection.get_selected_nodes()[0].get_navigation_map()
	var random_point = NavigationServer3D.map_get_random_point(navmap, 1, false)
	print("random nav point:", random_point)

	# get the world from the editor
	var world = get_editor_interface().get_edited_scene_root().get_world_3d()
	var space_state = world.direct_space_state
	
	# raycast straight down
	var query = PhysicsRayQueryParameters3D.create(random_point, random_point + Vector3.DOWN * 10)
	var result = space_state.intersect_ray(query)

	if not result:
		print("raycast hit nothing")
		return

	print("raycast hit:", result)

	if result.has("collider"):
		var static_body = result["collider"]
		print("hit collider:", static_body)

		if static_body is StaticBody3D:
			print("static body detected")
			var mesh_instance = find_parent_mesh(static_body)

			if mesh_instance:
				print("found parent mesh:", mesh_instance)
				var mesh = mesh_instance.mesh
				var face_index = result["face_index"]
				print("face index:", face_index)

				var surface_index = get_surface_from_face_index(mesh, face_index)
				print("surface index:", surface_index)
				if surface_index == 8:
					spawn_item_in_editor("res://Equippables/Item.tscn", result["position"])
					

				if surface_index != -1:
					var material = mesh.surface_get_material(surface_index)
					
					if material:
						print("material found:", material.resource_path)
					
					if material and material.resource_path.ends_with("floor_material.tres"):  # adjust for your material path
						print("floor found at:", result["position"])
						# instantiate your node here
				else:
					print("couldn't find surface for face index", face_index)
			else:
				print("no parent mesh found for static body")
				
# helper function to find the parent mesh
func find_parent_mesh(node):
	var root = get_editor_interface().get_edited_scene_root()
	while node and node != root:
		node = find_node_parent(root, node)
		if node is MeshInstance3D:
			return node
	return null

# recursively search for a node's parent
func find_node_parent(root, target):
	for child in root.get_children():
		if target in child.get_children():
			return child
		var parent = find_node_parent(child, target)
		if parent:
			return parent
	return null

# find which surface contains the face index
func get_surface_from_face_index(mesh: Mesh, face_index: int) -> int:
	var accumulated_faces = 0
	
	for i in range(mesh.get_surface_count()):
		var array = mesh.surface_get_arrays(i)
		if array.size() == 0:
			continue
		
		var indices = array[ArrayMesh.ARRAY_INDEX]
		var face_count = indices.size() / 3  # each triangle has 3 indices

		print("checking surface", i, "face range:", accumulated_faces, "to", accumulated_faces + face_count - 1)

		if face_index < accumulated_faces + face_count:
			print("face index", face_index, "belongs to surface", i)
			return i  # found the correct surface
		
		accumulated_faces += face_count
	
	return -1  # couldn't find a valid surface
	
func spawn_item_in_editor(scene_path: String, position: Vector3):
	var root = get_editor_interface().get_edited_scene_root()
	if not root:
		print("no root scene found")
		return

	var scene = load(scene_path)
	if not scene:
		print("failed to load scene:", scene_path)
		return

	var instance = scene.instantiate()
	instance.position = position
	root.add_child(instance)
	instance.set_owner(root)  # ensures it saves properly in the editor

	print("spawned item at:", position)
