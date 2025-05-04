extends CharacterBody3D

@export var speed = 14
@export var fall_acceleration = 30
@export var jump_force = 7
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var MOUSE_SENSITIVITY : float = 0.5 

var target_velocity = Vector3.ZERO
var interaction_target = null
var reach = 2.5
var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3

@onready var interaction_ray = $InteractionRay
@onready var inventory = $Inventory

func _init() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	interaction_ray.target_position.z = -reach
	SignalManager.add_inventory.emit(inventory)

func _physics_process(delta):
	_update_camera(delta)
	$googles.rotation = CAMERA_CONTROLLER.rotation
	var direction = Vector3.ZERO
	if is_on_floor():
		target_velocity.y = 0
	
	interaction_ray.transform = CAMERA_CONTROLLER.transform
	interaction_target = interaction_ray.get_collider()
	
	if Input.is_action_just_pressed("Use"):
		if interaction_target != null:
			if interaction_target.has_method("pick_up"):
				if inventory.add_item(interaction_target.pick_up()):
					interaction_target.queue_free()
	
	$Hitbox/HitboxShape.disabled = true
	if Input.is_action_just_pressed("primary"):
		$Hitbox/HitboxShape.disabled = false
	
	if Input.is_action_pressed("move_right") and not DEBUG.visible:
		direction.x += 1
	if Input.is_action_pressed("move_left") and not DEBUG.visible:
		direction.x -= 1
	if Input.is_action_pressed("move_backwards") and not DEBUG.visible:
		direction.z += 1
	if Input.is_action_pressed("move_forward") and not DEBUG.visible:
		direction.z -= 1
	if Input.is_action_just_pressed("jump") and is_on_floor() and not DEBUG.visible:
		target_velocity.y = jump_force
	#	Lock camera
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if direction != Vector3.ZERO:
		direction = (transform.basis * direction).normalized()
	
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	# Moving the Character
	velocity = target_velocity
	move_and_slide()

func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input :
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY

func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0
	
