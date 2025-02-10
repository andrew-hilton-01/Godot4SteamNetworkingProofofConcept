extends MeshInstance3D


func _ready():
	if is_multiplayer_authority():
		self.set_visible(false)
