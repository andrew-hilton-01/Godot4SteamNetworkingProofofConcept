extends CharacterBody3D

### Enemy Stats ###
@export var minspeed : float = 4.0
@export var maxspeed : float = 5.0
@export var damage : float = 10.0
@export var isHostile : bool = true
@export var CHASE_SPEED : float = 5.5

### Movement Variables ###
@onready var nav_agent = $NavigationAgent3D
@onready var SPEED = randf_range(minspeed, maxspeed)
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") + 4.0

const JUMP_VELOCITY = 6.0
const ACCEL_TIME = 0.3
const AIR_CONTROL_FACTOR = 0.25

var target_speed: float
var accel_rate: float
var isMidair: bool = false
var patrol_pos: Vector3
var targettedNode: Node

enum State { IDLE, ATTACKING, PATROLLING, STALKING, FLEEING, CHASING }
var current_state = State.IDLE

func _ready():
	set_physics_process(is_multiplayer_authority())
	set_block_signals(!is_multiplayer_authority())
	if is_multiplayer_authority():
		get_random_nav_point()

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	# Update navigation based on state
	match current_state:
		State.IDLE:
			if $"..".isActive:
				current_state = State.PATROLLING
		State.CHASING:
			update_target_location()
			if velocity == Vector3.ZERO:
				jump()
		State.PATROLLING:
			handle_patrol()
	
	# Handle movement mechanics
	handle_gravity(delta)
	handle_navigation(delta)
	move_and_slide()

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		isMidair = true
		velocity.y -= gravity * delta
	else:
		isMidair = false

func handle_navigation(delta: float) -> void:
	var current_pos = global_transform.origin
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - current_pos).normalized()
	
	# Ensure we aren't stuck

	if current_pos.length() - next_pos.length() <= 0.05 and current_state != State.IDLE: #we're stuck
		match current_state:
			State.PATROLLING:
				#print("Stuck with velocity")
				#jump_toward()
				if is_equal_approx(velocity.length(), 0):
					print("Stuck and getting new point!")
					get_random_nav_point()
					jump_toward()#todo fix this mess
					
				#jump_toward()
			State.CHASING:
				jump_toward()
	# Update rotation
	if direction.length() > 0.01:
		direction.y = 0
		if current_pos.distance_to(current_pos + direction) > 0.01:  # check positions aren't the same
			look_at(current_pos + direction, Vector3.UP)
		else:
			if current_state == State.PATROLLING:
				get_random_nav_point()
	# Calculate target speed based on state
	target_speed = CHASE_SPEED if current_state == State.CHASING else SPEED
	accel_rate = target_speed / ACCEL_TIME
	
	# Apply movement
	if is_on_floor():
		handle_ground_movement(direction, delta)
	else:
		handle_air_movement(direction, delta)
@rpc("any_peer", "reliable", "call_local")
func jump(jump_strength := 5.0, forward_boost := 50.0, push_force : Vector3 = Vector3.ZERO):
	var direction
	if push_force != Vector3.ZERO:
		direction = (push_force - global_transform.origin).normalized()
	else:
		direction = (targettedNode.global_transform.origin - global_transform.origin).normalized()
	velocity = Vector3(direction.x * forward_boost, jump_strength, direction.z * forward_boost)
	
func jump_toward(jump_strength := 5.0, forward_boost := 30.0):#only performs when stuck while chasing
	var height_difference
	var direction
	if current_state == State.ATTACKING or current_state == State.CHASING:
		height_difference = targettedNode.global_position.y - global_position.y
		direction = (targettedNode.global_transform.origin - global_transform.origin).normalized()
	elif current_state == State.PATROLLING:
		height_difference = patrol_pos.y - global_position.y
		direction = (patrol_pos - global_transform.origin).normalized()
	if is_on_floor() and abs(height_difference) > 1.5:
		if height_difference < 0:
			jump_strength = 1.0
		elif height_difference > 0:
			jump_strength = 8.0
		if height_difference > 30:
			current_state = State.PATROLLING
		print("hd:", height_difference, ". jumping now.")
		velocity = Vector3(direction.x * forward_boost, jump_strength, direction.z * forward_boost)

func handle_ground_movement(direction: Vector3, delta: float) -> void:
	velocity.x = lerp(velocity.x, direction.x * target_speed, accel_rate * delta)
	velocity.z = lerp(velocity.z, direction.z * target_speed, accel_rate * delta)
	

func handle_air_movement(direction: Vector3, delta: float) -> void:
	var air_direction = direction * target_speed * AIR_CONTROL_FACTOR
	velocity.x = lerp(velocity.x, air_direction.x, accel_rate * delta)
	velocity.z = lerp(velocity.z, air_direction.z, accel_rate * delta)

func handle_patrol() -> void:
	update_target_location()
	if global_transform.origin.distance_to(patrol_pos) < 1.0:
		get_random_nav_point()

func update_target_location() -> void:
	var target_pos = patrol_pos if current_state == State.PATROLLING else targettedNode.global_position
	nav_agent.set_target_position(target_pos)


# Existing signal functions and utility methods remain unchanged
func chase(target):
	if current_state == State.IDLE or current_state == State.PATROLLING:
		current_state = State.CHASING
		targettedNode = target

func go_find_player():
	pass

func get_random_nav_point():
	var max_distance = 20.0
	var nav_map = nav_agent.get_navigation_map()
	var start_position = global_transform.origin
	
	for i in range(10):
		var random_point = NavigationServer3D.map_get_random_point(nav_map, 1, true)
		if random_point.distance_to(start_position) <= max_distance:
			patrol_pos = random_point
			return
	#print("No point found, using fallback method to return random point  to patrol")
	#patrol_pos = NavigationServer3D.map_get_closest_point(nav_map, start_position + Vector3(randf_range(-max_distance, max_distance), 0, randf_range(-max_distance, max_distance)))

# Keep existing signal connections
func _on_attack_cd_timeout():
	if !is_multiplayer_authority():
		return
	if current_state != State.ATTACKING:
		return
	if targettedNode and targettedNode.is_in_group("Players"):  
		targettedNode.take_damage.rpc_id(targettedNode.get_multiplayer_authority(), damage)

func _on_chase_area_body_entered(body):
	if !is_multiplayer_authority() or !body.is_in_group("Players"):
		return
	chase(body)

func _on_chase_area_body_exited(body):
	if !is_multiplayer_authority() or !body.is_in_group("Players"):
		return
	current_state = State.PATROLLING
	get_random_nav_point()

func _on_attack_area_body_entered(body):
	if !is_multiplayer_authority() or !body.is_in_group("Players"):
		return
	current_state = State.ATTACKING

func _on_attack_area_body_exited(body):
	if !is_multiplayer_authority() or !body.is_in_group("Players"):
		return
	current_state = State.CHASING

func _on_navigation_agent_3d_target_reached():
	if current_state == State.PATROLLING:
		print("Got to the spot")
		get_random_nav_point()
		#print("Probably stuck")
