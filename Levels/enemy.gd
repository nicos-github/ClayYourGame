extends CharacterBody2D

@export var moving := false
@export var SPEED = 100.0
@export var MOVE_DURATION = 1.0

@onready var SpriteAnim = $Sprites/Sprite2D

var input: float = 0.0

func _ready() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "input", -1.0, MOVE_DURATION/2.0)
	tween.tween_property(self, "input", 1.0, MOVE_DURATION)

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	velocity.x = input * SPEED
		
	move_and_slide()
	
	process_animations()

func process_animations():
	
	# check face direction
	SpriteAnim.set_direction(velocity.x)
	
	# standing / walking
	
	# standing / walking
	if abs(velocity.x) > 1.0:
		SpriteAnim.set_anim(SpriteAnim.walking)
	else:
		SpriteAnim.set_anim(SpriteAnim.standing)
		

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.velocity.y = -300
		queue_free()

func _on_player_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().reload_current_scene()
