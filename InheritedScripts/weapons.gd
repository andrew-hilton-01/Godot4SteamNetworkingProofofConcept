extends "res://InheritedScripts/items.gd"


@export var canDrop : bool
@export var isRanged : bool
@export var damage : int
@export var attackRate : float
@export var range : int
# Called when the node enters the scene tree for the first time.
func _ready():
	canEquip = true
	canScrap = false
	canGrab = false
	pass # Replace with function body.
func attack():
	var x = attackRate * 30
	
	#detect aim
	#find object pointed at
	#use range for melee
	#Will inherit mouse pos from character it is equipped by
	pass
