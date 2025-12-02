extends CharacterBody2D

const SPEED: float = 300
const JUMP_VELOCITY: float = -400
var appeared : bool = false


func _ready() -> void:
	$Animations.play("appearing")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	decide_animation()


func decide_animation() -> void:
	# wait for the first animation to finish
	if not appeared: return
	
	# eje x
	if velocity.x == 0:
		# idle
		$Animations.play("idle")
	elif velocity.x < 0:
		# walk left
		$Animations.flip_h = true
		$Animations.play("run")
	elif velocity.x > 0:
		# walk right
		$Animations.flip_h = false
		$Animations.play("run")
		
	# eje y
	if velocity.y < 0:
		# jump
		$Animations.play("jump")
	elif velocity.y > 0:
		# fall
		$Animations.play("fall")


func _on_animations_animation_finished() -> void:
	if $Animations.animation == "appearing":
		appeared = true
