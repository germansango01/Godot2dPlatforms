extends CharacterBody2D

const SPEED: float = 300
const JUMP_VELOCITY: float = -400
var allow_animation : bool = false
var leaved_floor : bool = false
var had_jump : bool = false
var max_jumps : int = 2
var count_jumps : int = 0
var double_jump : bool = false
var ray_cast_dimention : float = 11.5

func _ready() -> void:
	$Animations.play("appearing")


func _physics_process(delta: float) -> void:
	if is_on_floor():
		leaved_floor = false
		had_jump = false
		count_jumps = 0

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		# coyote timer init
		if not leaved_floor:
			$CoyoteTimer.start()
			leaved_floor = true

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and right_to_jump():
		if count_jumps == 1:
			double_jump = true
		count_jumps += 1
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if $RayCastWall.get_collider():
		$RayCastWall.get_collider().is_in_group("wall_jump")
		print('toco zona amarilla')
	
	move_and_slide()
	decide_animation()


func decide_animation() -> void:
	# wait for the first animation to finish
	if not allow_animation: return
	
	# eje x
	if velocity.x == 0:
		# idle animation
		$Animations.play("idle")
	elif velocity.x < 0:
		# walk left
		$Animations.flip_h = true
		$RayCastWall.target_position.x = -ray_cast_dimention
		$Animations.play("run")
	elif velocity.x > 0:
		# walk right
		$Animations.flip_h = false
		$RayCastWall.target_position.x = ray_cast_dimention
		$Animations.play("run")
		
	# eje y
	if velocity.y < 0:
		# jump animation
		$Animations.play("jump")
	elif velocity.y > 0:
		# fall animation
		$Animations.play("fall")
	# double jump animation
	if double_jump:
		double_jump = false
		allow_animation = false
		$Animations.play("double_jump")

# jump
func right_to_jump():
	if had_jump:
		if count_jumps < max_jumps:
			return true
		else: 
			return false
	if is_on_floor(): 
		had_jump = true
		return true
	elif not $CoyoteTimer.is_stopped(): 
		had_jump = true
		return true

################
# Signals
################

func _on_animations_animation_finished() -> void:
	allow_animation = true


func _on_coyote_timer_timeout() -> void:
	print('boom!')
