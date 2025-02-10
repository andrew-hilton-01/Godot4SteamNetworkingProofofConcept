extends CharacterBody3D

### State Machine States ###
var isWalking : bool = false
var isMidair : bool
@export var health = 100
@export var energy = 50
### Variables ###
const sensitivity = 0.002
@export var SPEED = 5.0
const JUMP_VELOCITY = 6
var isMouseFree : bool = false
var activeSlot : int
var accel_rate
var target_speed
const ACCEL_TIME = 0.3
var movement_factor
const  air_control_factor : float = 0.25  # reduces movement ability in air
@export var shoveEnergy : int #mult of 10
@export var jumpEnergy : int #mult of 10
# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") + 4.0
signal attacking
### rpcs ###
@rpc("any_peer", "call_remote", "unreliable") #Unreliably sends new position to all peers except self
func _sync_position(new_position, new_rotation):
	position = new_position
	rotation = new_rotation
	
@rpc("any_peer", "call_local", "reliable")
func take_damage(amt):
	if amt == 1000: #Checks for game ending
		die()
		print("You won")
	if energy < 100:
		energy+=10
	health-=amt
	if health <= 0:
		die()
		
func die():
	%Inventory.drop_all()
	await %Inventory.dropped_all
	global_position.y = 40
func _ready():
	set_physics_process(is_multiplayer_authority()) #Only this authority can use these functions
	set_process_input(is_multiplayer_authority())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await wait (.1)
	if !is_multiplayer_authority():
		return
	set_global_position(Vector3.ZERO)
	velocity = Vector3.ZERO
	$Head/POV.current = is_multiplayer_authority()
func wait(time):
	await get_tree().create_timer(time).timeout
		

### PHYSICS AND INPUTS BELOW BORINGGGGGGGGGGGGGGGGGGGG ###
func _input(event):
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensitivity)
		$Head.rotate_x(-event.relative.y * sensitivity)
		$Head.rotation.x = clampf($Head.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	#Keyboard inputs
	if Input.is_action_just_pressed("consume"):
		consume_item()
	if Input.is_action_just_pressed("click"):
		use()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	if Input.is_action_just_pressed("altclick"):
		if !isMouseFree:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			isMouseFree = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			isMouseFree = false

func consume_item():
	var equipped = %Inventory.equipped
	if !equipped:
		return
	if energy >= 100:
		return
	if !equipped.isConsumable:
		return
	energy+=equipped.energyProvided
	%Inventory.delete_item()

@rpc("any_peer", "reliable", "call_remote")#todo make host able to use this function
func shove(jump_strength := 5.0, forward_boost := 50.0, push_force : Vector3 = Vector3.ZERO):
	var direction
	if push_force != Vector3.ZERO:
		direction = (push_force - global_transform.origin).normalized()
	velocity = Vector3(direction.x * forward_boost, jump_strength, direction.z * forward_boost)
func use():
	var object_clicked = $Head/POV/RayCast3D.get_collider()
	if object_clicked and object_clicked.is_in_group("Enemies"):
		#print("enemy clicked: ", object_clicked)
		if energy >= shoveEnergy:
			object_clicked.jump.rpc(5.0, 150.0, $Head/POV/RayCast3D/ImpulseLocation.global_position)
			energy-=shoveEnergy
		#print("applying impulse")

	if object_clicked and object_clicked.is_in_group("Players"):
		#print("player clicked: ", object_clicked)
		if energy >= shoveEnergy:
			object_clicked.shove.rpc_id(object_clicked.name.to_int(), 5.0, 20.0, $Head/POV/RayCast3D/ImpulseLocation.global_position)
			energy-=shoveEnergy
		#print("applying impulse")
	var equipped = %Inventory.equipped
	attacking.emit()
	if !equipped or !equipped.isWeapon:
		#print("Nothing equipped")
		return
	else:
		print(multiplayer.get_unique_id(), " is Attacking with: ", equipped)
func alt_use():
	var equipped = %Inventory.equipped
	
func _physics_process(delta):
	_sync_position.rpc(position, rotation) #send updated position and rotation to peers every physics frame
	# Handle core movement mechanics
	handle_gravity(delta)
	handle_jump()
	handle_movement(delta)
	move_and_slide()
	
func handle_gravity(delta):
	# Apply gravity when in air
	if not is_on_floor():
		isMidair = true
		velocity.y -= gravity * delta

func handle_jump():
	# Jump when on ground and space pressed
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		if energy >= jumpEnergy:
			velocity.y = JUMP_VELOCITY
			energy-=jumpEnergy
func handle_movement(delta):
	# Get input direction and convert to world space
	var input_dir = Input.get_vector("left", "right", "forw", "backw")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Update movement state
	isWalking = input_dir.length() > 0.1
	accel_rate = SPEED / ACCEL_TIME
	if isWalking:
		target_speed = SPEED
	else:
		target_speed = 0
	
	# Apply appropriate movement based on ground state
	if is_on_floor():
		handle_ground_movement(direction, delta)
	else:
		handle_air_movement(direction, delta)

func handle_ground_movement(direction: Vector3, delta: float):
	# Full control on ground
	isMidair = false
	velocity.x = lerp(velocity.x, direction.x * target_speed, accel_rate * delta)
	velocity.z = lerp(velocity.z, direction.z * target_speed, accel_rate * delta)

func handle_air_movement(direction: Vector3, delta: float):
	# Reduced control in air to preserve momentum
	var is_moving_in_direction = direction.x * velocity.x + direction.z * velocity.z > 0.9
	
	if !is_moving_in_direction:
		# Apply air control only when changing direction
		velocity.x = lerp(velocity.x, velocity.x + direction.x * target_speed * air_control_factor, accel_rate * delta)
		velocity.z = lerp(velocity.z, velocity.z + direction.z * target_speed * air_control_factor, accel_rate * delta)


func _on_energy_recharge_timeout():
	if !is_multiplayer_authority():
		return
	if energy<100:
		energy+=10
