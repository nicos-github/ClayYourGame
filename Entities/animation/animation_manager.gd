extends Sprite2D

class_name AnimationManager

@export var standing: Anim
@export var walking: Anim
@export var jumping: Anim
@export var falling: Anim

var current_anim: Anim
var tick: float = 0.0
var cur_frame: int = 0

const FRAMERATE = 8

func _ready() -> void:
	set_anim(standing)

func _physics_process(delta: float) -> void:
	# check for valid animation
	if current_anim == null:
		tick = 0
		return
	
	# increase animation tick
	tick += delta
	
	# store last frame
	var last_frame: float = cur_frame
	
	# frame step
	var frame_step = (1.0/(FRAMERATE*current_anim.anim_speed)) 
	
	# check if action needs to be done
	if tick > frame_step:
		# increase frame but adhere to num of max frames available in animation
		cur_frame = (cur_frame+1) % current_anim.sprites.size()
		tick = 0.0
	
	# check if frames match, if not, refresh the sprite
	if cur_frame != last_frame:
		self.texture = current_anim.sprites[cur_frame]
	
		#print(cur_frame)
	
func set_anim(anim: Anim):
	if anim == current_anim:
		return
	
	current_anim = anim
	print("set new anim " + str(anim))
	cur_frame = -1 # force frame update on anim so it switches immediately
	tick = 999

### 1.0 is right, -1.0 is left
func set_direction(dir):
	self.flip_h = dir < 0
