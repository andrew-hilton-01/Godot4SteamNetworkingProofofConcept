extends Node
@onready var player = $"../Player"

func _physics_process(delta):
	get_tree().call_group("enemies", "update_target_location", player.position)
