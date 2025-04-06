extends CharacterBody2D

const INPUT_BUFFER_PATIENCE = 0.1
const COYOTE_TIME = 0.1
const SPEED = 100
const ACCELERATION = 100
const FRICTION = 1000
const JUMP_VELOCITY = 300
const WALL_JUMP_VELOCITY = 100
const WALL_JUMP_PUSHBACK = 100
const MAX_WALL_SLIDE_SPEED = 100

var input_buffer : Timer
var coyote_timer : Timer
var coyote_jump_available : bool = true

func _ready():	
	# Setup input buffer timer
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)
	
	# Setup coyote timer
	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)

func _physics_process(delta):
	var horizontal_input = Input.get_axis("move_left", "move_right")
	var jump_attempted = Input.is_action_just_pressed("jump")

	if horizontal_input:
		velocity.x = move_toward(velocity.x, horizontal_input * SPEED, delta * ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * FRICTION)
	
	if jump_attempted or input_buffer.time_left > 0:
		if coyote_jump_available:
			velocity.y = -JUMP_VELOCITY
			coyote_jump_available = false
		elif is_on_wall() and horizontal_input != 0:
			velocity.y = -WALL_JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSHBACK * -sign(horizontal_input)
		elif jump_attempted:
			input_buffer.start()
			
	if is_on_floor():
		coyote_jump_available = true
		coyote_timer.stop()
	else:
		if coyote_jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start()

		velocity += get_gravity() * delta
		if is_on_wall():
			velocity.y = min(velocity.y, MAX_WALL_SLIDE_SPEED)

	move_and_slide()

func coyote_timeout():
	coyote_jump_available = false
