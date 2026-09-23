extends CharacterBody3D

@export var SPEED: float = 5.0
@export var JUMP_VELOCITY: float = 4.5
@export var MOUSE_SENSITIVITY: float = 0.003

var gravity: float = 1.62

@onready var camera: Camera3D = $Camera3D
@onready var anim_player: AnimationPlayer = $Astronaut3/AnimationPlayer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85.0), deg_to_rad(85.0))

func _physics_process(delta: float) -> void:
	# Apply gravity in the air
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# ONLY update horizontal movement direction while on the ground
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()

		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			# Trigger the looping Mixamo animation
			if anim_player.has_animation("mixamo_com"):
				anim_player.play("mixamo_com")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 10 * delta)
			velocity.z = move_toward(velocity.z, 0, SPEED * 10 * delta)
			# Stop animation when not moving
			anim_player.stop()

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
