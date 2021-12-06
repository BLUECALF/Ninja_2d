extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var anim_player :AnimationPlayer = get_node("AnimationPlayer")
export var speed: = Vector2(200,500)
export var gravity = 1000;
export var  _direction : Vector2
var _previous_direction = Vector2.ZERO
var _velocity = Vector2.ZERO

# player_properties used in animations.
var _player_is_looking: = "right" # can be right or left
var _player_state : = "idle" #can be idle,walk,attackjump,slide,throw

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	# THIS IS THE CODE THAT RUNNS EVERY CYCLE/FRAME
	getDirection()
	_velocity = calculate_move_velocity(_velocity,_direction,speed)
	#get approperiate animation
	get_animation()
	# move and slide player
	
	move_and_slide(_velocity,Vector2.UP)
	_previous_direction = _direction


func getDirection() -> void:
	_direction.x = (Input.get_action_strength("move_right")-Input.get_action_strength("move_left"))
	if(Input.is_action_just_pressed("player_jump") and is_on_floor()):
		_direction.y = -1
	else:
		_direction.y = 1


func calculate_move_velocity(
	linear_velocity:Vector2,
	_direction:Vector2,
	speed:Vector2
	) -> Vector2:
	var new_velocity = linear_velocity
	new_velocity.x = speed.x * _direction.x
	# next line ia acceleration due to gravity
	new_velocity.y =new_velocity.y +(gravity * get_physics_process_delta_time())
	
	# WHAT HAPPENS WHEN THE PLAYER JUMPS 
	if(_direction.y ==-1.0):
		new_velocity.y = speed.y * _direction.y
	if(new_velocity.y >= 1500):
		new_velocity.y = 1500
	return new_velocity


#FUNCTION TO GET APPROPERIATE ANIMATION
func get_animation() ->void :
	if (_direction.x >0 and _previous_direction.x <= 0 and (_player_state =="idle" or _player_state=="walk")):
		anim_player.play("player_walk_right")
		_player_state = "walk"
		_player_is_looking = "right"
		
	if (_direction.x <0 and _previous_direction.x >= 0 and (_player_state =="idle" or _player_state=="walk")):
		anim_player.play("player_walk_left")
		_player_state = "walk"
		_player_is_looking = "left"
		
	elif(_direction.y <0 and _previous_direction.y >=0 and is_on_floor() and _direction.x ==0 and (_player_state == "idle" or _player_state == "walk") ):
		anim_player.play("player_jump") #player is jumping in idle possition		
		_player_state = "jump"
		#yield to wait the jump process to end
		yield(anim_player,"animation_finished")
		_player_state = "idle" #return state to idle
		anim_player.play("player_idle")
	
	# JUMP ANIMATION WHEN PLAYER IS MOVING AT CERTAIN DIRECTION
		
	elif(_direction.y <0 and _previous_direction.y >=0 and is_on_floor() and _direction.x !=0 and (_player_state == "idle" or _player_state == "walk")):
		anim_player.play("player_jump") #player is jumping in idle possition		
		_player_state = "jump"
		#yield to wait the jump process to end
		yield(anim_player,"animation_finished")
		
		#CHECK THE AFTER DIRECTION TO SHOW APPROPERIATE ANIMATION.
		_player_state = "walk" #return state to WALK
		if(_direction.x > 0):
			_player_is_looking = "right"
			anim_player.play("player_walk_right")
		elif (_direction.x < 0 ):
			_player_is_looking = "left"
			anim_player.play("player_walk_left")
	
	
	# ATTACK ANIMATION WHILE STILL
	elif(is_on_floor() and _direction.x ==0 and Input.is_action_just_pressed("player_attack")and _player_state=="idle"):
		anim_player.play("player_attack") #player is attacking in idle possition		
		_player_state = "attack"
		#yield to wait the attack process to end
		yield(anim_player,"animation_finished")
		_player_state = "idle" #return state to idle
		anim_player.play("player_idle")
	
	# THROW KUNAI  ANIMATION WHILE STILL
	elif(is_on_floor() and _direction.x ==0 and Input.is_action_just_pressed("player_throw_kunai") and _player_state=="idle"):
		anim_player.play("player_throw") #player is throwing kunai in idle possition		
		_player_state = "throw"
		#yield to wait the throw process to end
		yield(anim_player,"animation_finished")
		_player_state = "idle" #return state to idle
		anim_player.play("player_idle")
		
	# SLIDE ANIMATION WHILE STILL
	elif(is_on_floor() and _direction.x ==0 and Input.is_action_just_pressed("player_slide")):
		anim_player.play("player_slide") #player is sliding in idle possition		
		_player_state = "slide"
		#yield to wait the slide process to end
		yield(anim_player,"animation_finished")
		_player_state = "idle" #return state to idle
		anim_player.play("player_idle")
	
	# SLIDE ANIMATION WHEN PLAYER IS MOVING AT CERTAIN DIRECTION
		
	elif(is_on_floor() and _direction.x !=0 and (_player_state == "walk") and Input.is_action_just_pressed("player_slide")):
		anim_player.play("player_slide") #player is sliding in walk state		
		_player_state = "slide"
		#yield to wait the slide process to end
		yield(anim_player,"animation_finished")
		_player_state = "walk" #return state to idle
		anim_player.play("player_walk")
		
	elif(is_on_floor() and _direction.x != 0 and _player_state == "idle"):
			# PLAYER IS ON FLOOR MOVING BUT STATE HAS ERROR SAYING HE IS IDLE.
			if(_direction.x > 0):
				anim_player.play("player_walk_right")
				_player_is_looking = "right"
			else:
				anim_player.play("player_walk_left")
				_player_is_looking = "left"
			_player_state = "walk"
		
	# DEAFULT ANIMATION 
	elif(_direction.x ==0 and _direction.y ==1 and is_on_floor() and _player_state == "walk"):
		_player_state = "idle"
		anim_player.play("player_idle")




