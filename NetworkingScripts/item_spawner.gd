extends MultiplayerSpawner


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawn_item

func spawn_item(item, pos):
	add_child(item)
	item.position = pos
	print("spawned, ", item, "at, ", pos)
	return item
