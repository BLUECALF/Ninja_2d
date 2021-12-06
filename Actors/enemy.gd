extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var anim_player :AnimationPlayer = get_node("AnimationPlayer")
onready var nav_to_loot :Navigation2D = get_node("..").get_node("nav_to_loot")


export var speed: = Vector2(100,500)
export var gravity = 1000;
export var  _direction : = Vector2(1,1)
var _previous_direction = Vector2.ZERO
var _velocity = Vector2.ZERO

#VARIABLES USED IN CHECKING LOOT
var my_initial_pos : = global_position
var my_initial_pos_2 :Vector2
var loot_pos : = Vector2(18400,340)
var path :PoolVector2Array
var i  :int  = 1 
var path_last_point : int = path.size() -1
var move_velocity :Vector2

# enemy_properties used in animations.
enum _ENEMY_IS_LOOKING {LEFT, RIGHT}
enum  _ENEMY_STATE {PATROLL, IDLE,CHECK_LOOT,ATTACK,RETREAT,DIE}

var _enemy_is_looking : int = _ENEMY_IS_LOOKING.LEFT
var _enemy_state : int = _ENEMY_STATE.CHECK_LOOT


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#	 CALCULATION USED IN CHECK LOOT
	path = nav_to_loot.get_simple_path(global_position,loot_pos,true)
	move_velocity =  (path[i] - global_position)
	my_initial_pos_2 = global_position
	path_last_point = path.size() - 1
	
	print("move velocity",move_velocity,"  ::")
	print("path[i] - global_position = ", (path[i] - (global_position)))
	print("enemy position IN ENEMY SCRIPT : ")
	print(global_position)
	print("loot position" ,loot_pos)
	print("path i ",path[i])
	for k in path.size() :
		print("point ",k)
		print(path[k])
		print("path size is : ",path.size())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#ENEMY SHOULD
	#1 PATROLL
	#2 BE IDLE
	#4 SEEYOU 
	#5 ATTACK YOU
	#6 RUN AWAY IN LOW HP
	#7 DIE
	
	
	if (_enemy_state == _ENEMY_STATE.PATROLL):
		_getVelocity()
		_getAnimation()
		move_and_slide(_velocity,Vector2.UP)
		_previous_direction = _direction
		
		
	elif(_enemy_state == _ENEMY_STATE.CHECK_LOOT):
#		print("checkloot runs:::::::::")
#		print("the value of i ::: ",i)
#		print("my pos boooizz:::::",global_position)
		_check_loot()

	

func _getVelocity() -> void:
	_velocity.x  = speed.x *_direction.x;
	_velocity.y  =  _velocity.y + (gravity * get_physics_process_delta_time())
	if(_direction.y ==-1.0 and _previous_direction.y ==1):
		_velocity.y = speed.y * _direction.y


func _getAnimation() -> void:
	if(_direction.x > 0 and _previous_direction.x ==0 and _enemy_state == _ENEMY_STATE.PATROLL):
		anim_player.play("enemy_walk")


func _on_Area_detector_body_entered(body: Node) -> void:
	# IF COLIDE WITH A WALL JUMP THE WALL.
	if((body.name =="TileMap") and is_on_floor() and _previous_direction.y ==1): 
			print("I Must Jump")
			_direction.y = -1
			print("\n jumping ")
	else:
		_direction.y = 1



func _on_Area_detector_area_entered(area: Area2D) -> void:
	if(area.is_in_group("enemy_stopper")):   #if found end of area change direction
		print("Change direction.x ")
		_direction.x = _direction.x * -1
		get_node("Sprite").flip_h = !get_node("Sprite").flip_h

##	FUNCTIONS USED WHEN THE ENEMY IS CHECKING LOOOT

func _check_loot() ->void:
	#1.know your position and loot position~
	#2.find a path to the loot.~
	#3find points to the path
	#4 calculayte move_velocity along the points
	#5 move and slide until you reach the destination.
	#6 check loot if its still there
	#7 return to where you were before checloot 
	#8 return patrolling.
	
	if(global_position != loot_pos):
		
		move_and_slide(move_velocity)
		
		# WE NEED TO KNOW IF WE HAVE REACHED THE PATHS POINT.
		#WE COMPARE  ""INITIAL_POSITION WITH PATH [I]""
#		print("AFTER MOVE and slide runs::::\n")
#		print("my_initial_pos2 ::" ,my_initial_pos_2)
#		print("\n\n path [i]",path[i])
#		print("difference   ",path[i] - my_initial_pos_2)
#		print("current pos::" ,global_position)
#		print("\n\n")
		if my_initial_pos_2.x >= path[i].x and my_initial_pos_2.y >= path[i].y :
			# lesser means we have reached.
			print("sec 1")
			if((global_position.x <= path[i].x and global_position.y <= path[i].y) and i <= path_last_point):
				i = i + 1
				if(i == path.size()): #check if we have reached end of path.
					i = 0
					path.empty()
					move_velocity = Vector2(0,speed.y)
					global_position = loot_pos
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = global_position
				
				print("i = :",i)
				move_velocity = path[i] - global_position
		
		elif my_initial_pos_2.x >= path[i].x and my_initial_pos_2.y <= path[i].y :
			#lesser in x and greater in y means we have reached.
			print("sec 2")
			if((global_position.x <= path[i].x and global_position.y >= path[i].y) and i <= path_last_point):
				i = i + 1
				if(i == path.size()):
					i = 0
					path.empty()
					move_velocity = Vector2(0,speed.y)
					global_position = loot_pos
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = global_position
				
				print("i = :",i)
				move_velocity = path[i] - global_position
			
		elif my_initial_pos_2.x <= path[i].x and my_initial_pos_2.y >= path[i].y :
			print("sec 3")
			#greater in x and lesser in y means we have reached.
			if((global_position.x >= path[i].x and global_position.y <= path[i].y) and (i <= path_last_point)):
				i = i + 1
				if(i == path.size()): #check if we have reached end of path.
					i = 0
					path.empty()
					move_velocity = Vector2(0,speed.y)
					global_position = loot_pos
					print("destination reached")
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = global_position
				print("i = :",i)
				move_velocity = path[i] - global_position
				
		elif my_initial_pos_2.x <= path[i].x and my_initial_pos_2.y <= path[i].y :
			#greater in x and greater in y means we have reached.
			print("sec 4")
			if((global_position.x >= path[i].x and global_position.y >= path[i].y) and i <= path_last_point):
				i = i + 1
				if(i == path.size()): #check if we have reached end of path.
					i = 0
					path.empty()
					move_velocity = Vector2(0,speed.y)
					global_position = loot_pos
					print("destination reached")
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = global_position
				
				print("i = :",i)
				move_velocity = path[i] - global_position
