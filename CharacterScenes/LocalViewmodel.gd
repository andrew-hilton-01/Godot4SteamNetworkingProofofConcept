extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_multiplayer_authority():
		self.set_visible(false)
		set_process(PROCESS_MODE_DISABLED)
		return
	$AnimationPlayer.play("Relax_hands_idle")



func _on_inventory_entered_inventory():
	$AnimationPlayer.play("Collect_something")

func _on_inventory_equipped_item():
	pass #need animations for equipping items

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Collect_something":
		$AnimationPlayer.play("Hands_below")
	$AnimationPlayer.play("Relax_hands_idle")


func _on__attacking():
	$AnimationPlayer.play("Magic_spell_attack")
