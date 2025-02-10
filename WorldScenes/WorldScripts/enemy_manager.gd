extends Node
#Handles sending wanted behaviors to Enemy nodes
signal host_start
var isActive : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if Input.is_action_just_pressed("startgame"):
		isActive = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !isActive:
		return
	#$Enemy.attack(%Players.get_child(0))
