extends CharacterBody2D

@onready var Sprite = $Sprites
@onready var SpriteAnim: AnimationManager = $Sprites/Sprite2D

const SPEED = 150.0
const ACCELERATION = 30.0
const AIR_ACCELERATION = 15.0
const DECELERATION = 20.0
const GRAVITY = 1500.0
const GRAVITY_MULT_IMPACT = -500.0
const MAX_FALL_VELOCITY = 800.0
const JUMP_VELOCITY = -400.0
const JUMP_HELD_GRAVITY_MULT = 1.25
const JUMP_FALL_GRAVITY_MULT = -1.25
const WISH_JUMP_TIME = 0.12
const COYOTE_TIME = 0.15

var wish_jump_time = 0.0
var coyote_time = 0.0

func _ready() -> void:
	pass
	

func _physics_process(delta: float) -> void:
	
	
	# reset if falling down
	if global_position.y > 1500:
		get_tree().reload_current_scene()
	
	# handle wish jump ( if still in air but about to hit the ground and the jump key is pressed, buffer it
	if !is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		wish_jump_time = WISH_JUMP_TIME
	
	# deteriorate wish jump time
	if wish_jump_time > 0.0:
		wish_jump_time = clamp(wish_jump_time - delta, 0.0, WISH_JUMP_TIME)
	
	# calculate if falling down as a float
	var falling: float = 1.0 if velocity.y >= 0 else 0.0
	
	# half gravity if jump button held, so jump height becomes variable
	var jump_grav_multiplier: float = JUMP_HELD_GRAVITY_MULT * Input.get_action_strength("ui_accept") * (1.0-falling)
	
	# apply extra downforce when falling so it feels snappier
	var jump_fall_grav_multiplier: float = JUMP_FALL_GRAVITY_MULT * falling
	
	# calculate the whole addition to gravity
	var gravity_addition: float = (GRAVITY_MULT_IMPACT * (jump_grav_multiplier + jump_fall_grav_multiplier))

	# Add the gravity. 
	if not is_on_floor():
		velocity.y += (GRAVITY + gravity_addition) * delta
		velocity.y = clamp(velocity.y, JUMP_VELOCITY, MAX_FALL_VELOCITY)
		
		# deteriorate coyote time
		if coyote_time > 0.0:
			coyote_time = clamp(coyote_time - delta, 0.0, COYOTE_TIME)
			
	else:
		# check if just landed
		if coyote_time != COYOTE_TIME:
			reset_squash_stretch()
			coyote_time = COYOTE_TIME
		

	# Handle jump.
	if (Input.is_action_just_pressed("ui_accept") or wish_jump_time > 0.0) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		play_jump_squash_stretch()
	elif Input.is_action_just_pressed("ui_accept") and !is_on_floor() and coyote_time > 0.0: # handle coyote jump if jump key is pressed while midair but inside coyote allowance
		velocity.y = JUMP_VELOCITY
		play_jump_squash_stretch()
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		var accel = ACCELERATION if is_on_floor() else AIR_ACCELERATION
		velocity.x = move_toward(velocity.x, direction * SPEED, accel)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)

	move_and_slide()
	
	process_animations(direction)

func process_animations(direction: float):
	
	var target_animation: Anim = null
	
	# face directions
	if sign(direction) != 0:
		SpriteAnim.set_direction(sign(direction))
	
	# standing / walking
	if abs(velocity.x) > 1.0:
		target_animation = SpriteAnim.walking
	else:
		target_animation = SpriteAnim.standing
		
	# jumping
	if !is_on_floor():
		if velocity.y < 0:
			target_animation = SpriteAnim.jumping
		else:
			target_animation = SpriteAnim.falling
	
	# apply animation
	if target_animation != null:
		SpriteAnim.set_anim(target_animation)
	

func play_jump_squash_stretch():
	# --- Jump Stretch ---
	var jump_tween := create_tween()
	jump_tween.tween_property(
		Sprite,               # the node whose property you animate
		"scale",
		Vector2(0.4, 1.8),  # wider horizontally? no, taller vertically -> adjust as you like
		0.1                # duration in seconds
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# --- Falling Squash ---
	var fall_tween := create_tween()
	# delay so it starts after the jump tween finishes
	fall_tween.tween_property(
		Sprite,
		"scale",
		Vector2(0.9, 1.1),
		0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func reset_squash_stretch():
	var fall_tween := create_tween()
	
	fall_tween.tween_property(
		Sprite,
		"scale",
		Vector2(1.1, 0.8),
		0.05
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	fall_tween.tween_property(
		Sprite,
		"scale",
		Vector2.ONE,
		0.2
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
