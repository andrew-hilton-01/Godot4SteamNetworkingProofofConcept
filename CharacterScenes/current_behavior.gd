extends Label3D

func _process(delta):
	var parent = get_parent()  # get the enemy node
	var new_text = parent.State.keys()[parent.current_state]  # get state name as string
	if text != new_text:
		text = new_text
