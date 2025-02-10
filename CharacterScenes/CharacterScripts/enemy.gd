extends CharacterBody3D
@onready var nav_agent = $NavigationAgent3D
@export var minspeed : float = 2.0
@export var maxspeed : float = 3.0
@export var damage : float = 10.0
@export var isHostile : bool = true
@export var CHASE_SPEED : float = 5.5
enum State { IDLE, ATTACKING, PATROLLING, STALKING, FLEEING, CHASING }
var current_state = State.IDLE
var targettedNode
var patrol_pos
const JUMP_VELOCITY = 10
var isMoving : bool
var oldpos : Vector3
@onready var SPEED = randf_range(minspeed, maxspeed)
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") + 20
func _ready():
	set_physics_process(is_multiplayer_authority())
	set_block_signals(is_multiplayer_authority())
	if is_multiplayer_authority():
		get_random_nav_point()
func _physics_process(delta):
	print("Agent pos:", global_transform.origin)
	print("Next path pos:", nav_agent.get_next_path_position())
	#print(nav_agent.distance_to_target())
	if current_state == State.IDLE:
		if $"..".isActive:
			current_state = State.PATROLLING
	elif current_state == State.CHASING:
		update_target_location()
	elif current_state == State.PATROLLING:
		update_target_location()
		if global_transform.origin.distance_to(patrol_pos) < 5.0:
			get_random_nav_point()
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var direction = (next_location - current_location).normalized()

	if direction.length() > 0.01:
		direction.y = 0  # prevent tilting
		if current_location.length() - direction.length() <= 0.1: #maybe gets rid of error look_at() failed
			return
		look_at(current_location + direction, Vector3.UP)
	var new_velocity
	if current_state == State.CHASING:
		new_velocity = direction * (CHASE_SPEED)
	else:
		new_velocity = direction * SPEED
	velocity = new_velocity
	jump_to_next_pos()
	handle_gravity(delta)
	move_and_slide()
	#print("pos: ", position, "oldpos: ", oldpos)
	
func jump_to_next_pos(threshold := 1.0, jump_strength := 5.0, forward_boost := 2.0):
	print("Jumping!!!")
	var next_pos = nav_agent.get_next_path_position()
	var delta_y = next_pos.y - global_transform.origin.y

	if delta_y < -threshold:  # if the next point is significantly lower
		var forward_dir = -global_transform.basis.z.normalized()  # assuming -Z is forward
		velocity = Vector3(forward_dir.x * forward_boost, jump_strength, forward_dir.z * forward_boost)


func handle_gravity(delta):
	# Apply gravity when in air
	if not is_on_floor():
		velocity.y -= gravity * delta

func update_target_location():
	if current_state == State.PATROLLING:
		if nav_agent.get_target_position() != patrol_pos:
			nav_agent.set_target_position(patrol_pos)
	else:
		nav_agent.set_target_position(targettedNode.global_position)


func chase(target):
	if current_state == State.IDLE or current_state == State.PATROLLING:
		current_state = State.CHASING
		targettedNode = target

func _on_attack_cd_timeout():
	if !is_multiplayer_authority():
		return
	if current_state != State.ATTACKING:
		return
	if targettedNode and targettedNode.is_in_group("Players"):  
		targettedNode.take_damage.rpc_id(targettedNode.get_multiplayer_authority(), damage)

func _on_chase_area_body_entered(body):
	if !is_multiplayer_authority():  # ensure only the authority processes it
		return
	if !body.is_in_group("Players"):
		return
	chase(body)
	print(multiplayer.get_unique_id(), ": chase signal recieved, chasing: ", body)
	print(body.global_position)


func _on_chase_area_body_exited(body):
	if !is_multiplayer_authority():  # ensure only the authority processes it
		return
	if !body.is_in_group("Players"):
		return
	current_state = State.PATROLLING
	get_random_nav_point()

func _on_attack_area_body_entered(body):
	if !is_multiplayer_authority():  # ensure only the authority processes it
		return
	if !body.is_in_group("Players"):
		return
	current_state = State.ATTACKING
func _on_attack_area_body_exited(body):
	if !is_multiplayer_authority():  # ensure only the authority processes it
		return
	if !body.is_in_group("Players"):
		return
	current_state = State.CHASING
func patrol_random():
	current_state = State.PATROLLING
	var random_point = get_random_nav_point()
	nav_agent.set_target_position(random_point)

func get_random_nav_point():
	var max_distance = 20.0  # adjust as needed
	var nav_map = nav_agent.get_navigation_map()
	var start_position = global_transform.origin
	
	# keep sampling until we get a valid point within max_distance
	for i in range(10):  # limit attempts to avoid infinite loops
		var random_point = NavigationServer3D.map_get_random_point(nav_map, 1, true)
		if random_point.distance_to(start_position) <= max_distance:
			patrol_pos = random_point
			return
	
	# fallback to closest point if no valid random one found
	patrol_pos = NavigationServer3D.map_get_closest_point(nav_map, start_position + Vector3(randf_range(-max_distance, max_distance), 0, randf_range(-max_distance, max_distance)))


func _on_navigation_agent_3d_target_reached():
	if current_state == State.PATROLLING:
		get_random_nav_point()
		print(self.name, ": Patrolling and reached point, navigating to new point")
