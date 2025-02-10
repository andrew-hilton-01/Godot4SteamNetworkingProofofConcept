@tool
extends EditorScript
### HOWTO: Select the meshes you want to apply nearest filtering for their materials on and then run this script. ###
func _run():
	var selection = get_editor_interface().get_selection()
	for node in selection.get_selected_nodes():
		process_mesh_instance(node)
	print("Finished setting nearest filtering for all selected meshes.")

func process_mesh_instance(node):
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			if mesh is ArrayMesh:
				for i in range(mesh.get_surface_count()):
					var material = mesh.surface_get_material(i)
					if material and material is Material:
						update_material_filter(material)
			elif mesh is PrimitiveMesh:
				var material = node.get_active_material()
				if material and material is Material:
					update_material_filter(material)

func update_material_filter(material):
	if material is BaseMaterial3D:
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		material.texture_anisotropy = 1
		print("Updated material: ", material)
