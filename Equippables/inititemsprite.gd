extends Sprite3D

func _ready():
	if !$"..".icon:
		print("no icon to set")
		return
	set_texture($"..".icon)
	var size = texture.get_size()
	if size.x >= 512:
		pixel_size = 0.001
