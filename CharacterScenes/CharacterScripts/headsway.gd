extends Marker3D
@export var SWAY_AMOUNT : Vector3 = Vector3(0.05, 0.1, 0) # x = side-to-side, y = up-down, z = optional forward/back sway
var SWAY_SPEED : float = 0.0
var sway_time : float = 0.0
var initial_position : Vector3
@onready var player = self.owner

func _ready():
	set_process(is_multiplayer_authority())
	initial_position = position # store the starting position (y=1.5 or whatever it is)
	
func sway_head(delta, player_speed):
	SWAY_SPEED = player_speed
	sway_time += delta * SWAY_SPEED
	# calculate sine wave offsets for x and y
	var x_offset = SWAY_AMOUNT.x * sin(sway_time)
	var y_offset = SWAY_AMOUNT.y * sin(sway_time * 2) # faster vertical sway if desired
	# apply sway to the Head's translation
	position = initial_position + Vector3(x_offset, y_offset, 0)
	
func unsway(delta):
	sway_time = 0.0
	position = lerp(position, initial_position, SWAY_SPEED * delta)
	pass
	
func _process(delta):
	if player.isWalking: #Checks if player is moving
		sway_head(delta, player.SPEED)
	if !player.isWalking and position != initial_position:
		unsway(delta)
