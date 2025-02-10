extends Node3D

@export var item_data: WorldModelData
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready():
	if item_data:
		load_item(item_data)

func load_item(data: WorldModelData):
	mesh_instance.mesh = data.mesh
	mesh_instance.position = data.position
	mesh_instance.rotation_degrees = data.rotation
	mesh_instance.scale = data.scale
