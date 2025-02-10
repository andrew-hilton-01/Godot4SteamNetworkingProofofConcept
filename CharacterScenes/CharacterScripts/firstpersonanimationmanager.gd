extends Node3D
@onready var hands = $AnimationPlayer
var pickingUp : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	hands.play("Relax_hands_idle")
	print("we hsould have an anim playing")
	pass

func playAnim(animation):
	hands.play(animation)
func pickup():
	pickingUp = true
	hands.play("Collect_something")
	
func _on_animation_player_animation_finished(anim_name):
	print(anim_name, " ending.")
	if anim_name == "Collect_something":
		hands.play("Relax_hands_idle_start")
		return
	else:
		hands.play("Relax_hands_idle")
