extends MultiplayerSpawner

# Called when the node enters the scene tree for the first time.
func _ready():
	var navmesh = $"../NavigationRegion3D".get_navigation_map()
	for i in range(5):  # generate 5 items
		var random_point = NavigationServer3D.map_get_random_point(navmesh, 1, true)
		spawn_item(random_point)

func spawn_item(position: Vector3):
	var item = preload("res://ObjectScenes/Item.tscn").instantiate()
	item.spawn_position = position
	call_deferred("add_child", item)
