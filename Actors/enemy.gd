extends KinematicBody2D



 
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var anim_player :AnimationPlayer = get_node("AnimationPlayer")
onready var nav_to_loot :Navigation2D = get_node("..").get_node("nav_to_loot")
onready var line_2d :Line2D  = get_node("..").get_node("Line2D")

var enemy_timer  =  preload("res://object_scenes/enemy_timer.tscn")
var e_timer

var status  = true

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
var i  :int  = 0 
var path_last_point : int = path.size() -1
var move_velocity :Vector2

# enemy_properties used in animations.
enum _ENEMY_IS_LOOKING {LEFT, RIGHT}
enum  _ENEMY_STATE {PATROLL, IDLE,CHECK_LOOT,RETURN_FROM_CHECKLOOT,ATTACK,RETREAT,DIE}

var _enemy_is_looking : int = _ENEMY_IS_LOOKING.LEFT
var _enemy_state : int = _ENEMY_STATE.PATROLL


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#	 CALCULATION USED IN CHECK LOOT
	path = nav_to_loot.get_simple_path(global_position,loot_pos,true)
	move_velocity =  (path[i] - global_position)
	my_initial_pos_2 = global_position
	path_last_point = path.size() - 1
	my_initial_pos = global_position
	
	# TIMER CALCULATIONS USED TO CHANGE ENEMY STATE
	e_timer =  enemy_timer.instance()
	e_timer.connect("time_finished", self, "_on_timer_timeout")
	
	
	
	print(e_timer.name," e timers name")
	
	print("############# timer added successfully")
	
	
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
	while (status):
		get_tree().get_root().add_child(e_timer)
		
		status = false
	
	
	
	#ENEMY SHOULD
	#1 PATROLL
	#CHECK LOOT         & RETURN FROM CHECKLOOT
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
		
		line_2d.points = path
		_check_loot(loot_pos,path,path_last_point,_ENEMY_STATE.RETURN_FROM_CHECKLOOT)
	
	elif(_enemy_state == _ENEMY_STATE.RETURN_FROM_CHECKLOOT):
		path = nav_to_loot.get_simple_path(loot_pos,my_initial_pos,true)
		path_last_point = path.size() -1
		line_2d.points = path
		_check_loot(my_initial_pos,path,path_last_point,_ENEMY_STATE.PATROLL)
		pass


func _getVelocity() -> void:
	_velocity.x  = speed.x *_direction.x;
	_velocity.y  =  _velocity.y + (gravity * get_physics_process_delta_time())
	if(_velocity.x > 0):
		get_node("Sprite").flip_h = false
	else:
		$Sprite.flip_h = true
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

func _check_loot(
		
		target_pos:Vector2,
		path:PoolVector2Array,
		path_last_point : int,
		next_enemy_state:int

) ->void:
	#1.know your position and loot position~
	#2.find a path to the loot.~
	#3find points to the path
	#4 calculayte move_velocity along the points
	#5 move and slide until you reach the destination.
	#6 check loot if its still there
	#7 return to where you were before checloot 
	#8 return patrolling.
	
	# flip well according to direction.
	if(move_velocity.x>0):
		get_node("Sprite").flip_h = false
	else:
		$Sprite.flip_h = true
	
	
	if(global_position != target_pos):
		
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
			print(my_initial_pos_2,"pos : 2")
			print(my_initial_pos,"initial pos")
			print("i =",i,"\n")
			
			if((global_position.x <= path[i].x or global_position.y <= path[i].y) and i <= path_last_point):
				i = i + 1
				if(i == path.size()): #check if we have reached end of path.
					_on_reaching_destination(next_enemy_state,target_pos)
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = global_position
				
				print("i = :",i)
				move_velocity = path[i] - global_position
		
		elif my_initial_pos_2.x >= path[i].x and my_initial_pos_2.y <= path[i].y :
			#lesser in x and greater in y means we have reached.
			print("sec 2")
			if((global_position.x <= path[i].x or global_position.y >= path[i].y) and i <= path_last_point):
				i = i + 1
				if(i == path.size()):
					_on_reaching_destination(next_enemy_state,target_pos)
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = global_position
				
				print("i = :",i)
				move_velocity = path[i] - global_position
			
		elif my_initial_pos_2.x <= path[i].x and my_initial_pos_2.y >= path[i].y :
			print("sec 3")
			print("in 3 i  = ",i)
			#greater in x and lesser in y means we have reached.
			if((global_position.x >= path[i].x and global_position.y <= path[i].y) and (i <= path_last_point)):
				i = i + 1
				if(i == path.size()): #check if we have reached end of path.
					_on_reaching_destination(next_enemy_state,target_pos)
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = global_position
				print("i = :",i)
				move_velocity = path[i] - global_position
				
		elif my_initial_pos_2.x <= path[i].x and my_initial_pos_2.y <= path[i].y :
			#greater in x and greater in y means we have reached.
			print("sec 4")
			print(move_velocity)
			if((global_position.x >= path[i].x or global_position.y >= path[i].y) and i <= path_last_point):
				i = i + 1
				print("i in section 4 increased ")
				print("i   =  ",i)
				if(i == path.size()): #check if we have reached end of path.
					_on_reaching_destination(next_enemy_state,target_pos)
					
					return
				#reset initial position to your pos
				my_initial_pos_2 = global_position
				
				print("i = :",i)
				move_velocity = path[i] - global_position


func _on_reaching_destination(next_enemy_state:int,target_pos : Vector2)->void:
	i = 0
	move_velocity = Vector2(0,-200)
	global_position = target_pos
	_enemy_state = next_enemy_state
	my_initial_pos_2 = global_position
	if(next_enemy_state == _ENEMY_STATE.PATROLL):
		#make a new timer to count until next checkloot
		e_timer = enemy_timer.instance()
		e_timer.connect("time_finished", self, "_on_timer_timeout")
		get_tree().get_root().add_child(e_timer)

func _on_timer_timeout() ->void:
	
	print("Timer timeout was recived bpoooooiizi \n")
	if(_enemy_state == _ENEMY_STATE.PATROLL):
		path = nav_to_loot.get_simple_path(global_position,loot_pos,true)
		i = 0
		move_velocity =  (path[i] - global_position)
		my_initial_pos_2 = global_position
		path_last_point = path.size() - 1
		my_initial_pos = global_position
		_enemy_state = _ENEMY_STATE.CHECK_LOOT
	
