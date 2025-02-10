@tool
class_name EquippedItemWorldModel extends Resource

@export var name : StringName
@export_category("Orientation")
@export var position : Vector3 = Vector3.ZERO
@export var rotation : Vector3 = Vector3.ZERO
@export var scale : Vector3 = Vector3(1,1,1)
@export_category("Visual")
@export var mesh : Mesh
