extends Sprite3D

@export var speed : float = 2.0
@export var amplitude : float = 1.0

var time : float = 0.0

func _process(delta):
	time += delta
	var offset = sin(time * speed) * amplitude
	global_transform.origin.y = position.y + offset
