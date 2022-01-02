extends KinematicBody2D



 
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var anim_player :AnimationPlayer = get_node("AnimationPlayer")
onready var nav_to_loot :Navigation2D = get_node("..").get_node("nav_to_loot")
onready var line_2d :Line2D  = get_node("..").get_node("Line2D")
onready var player_detector :RayCast2D = get_node("player_detector")

var enemy_timer  =  preload("res://object_scenes/enemy_timer.tscn")
var e_timer

var status  = true

export var speed: = Vector2(100,500)
export var gravity = 1000;
export var  _direction : = Vector2(1,1)
var _previous_direction = Vector2.ZERO
var _velocity = Vector2.ZERO

#VARIABLES USED IN CHECKING LOOT
var my_initial_pos : = position
var my_initial_pos_2 :Vector2
var loot_pos :Vector2
var path :PoolVector2Array
var path2 :PoolVector2Array
var i  :int  = 0 
var path_last_point : int
var move_velocity :Vector2

# enemy_properties used in animations.
enum _ENEMY_IS_LOOKING {LEFT, RIGHT}
enum  _ENEMY_STATE {PATROLL, IDLE,CHECK_LOOT,RETURN_FROM_CHECKLOOT,FOLLOW_PLAYER,ATTACK,RETREAT,DIE}

var _enemy_is_looking : int = _ENEMY_IS_LOOKING.LEFT
var _enemy_state : int = _ENEMY_STATE.CHECK_LOOT


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#	 CALCULATION USED IN CHECK LOOT
	
#	path = nav_to_loot.get_simple_path(global_position,loot_pos,true)
#	move_velocity =  (path[i] - global_position)
#	my_initial_pos_2 = global_position
#	path_last_point = path.size() - 1
#	my_initial_pos = global_position
#
#	line_2d.points = path
	
	# TIMER CALCULATIONS USED TO CHANGE ENEMY STATE
	e_timer =  enemy_timer.instance()
	e_timer.connect("time_finished", self, "_on_timer_timeout")
	
	
	
	print(e_timer.name," e timers name")
	
	print("############# timer added successfully")
	
#	print("path [i ]",path[i])
#	print("path [0] ",path[0])
#	print("move velocity",move_velocity,"  ::")
#	print("path[i] - global_position = ", (path[i] - (global_position)))
#	print("enemy position IN ENEMY SCRIPT : ")
#	print(global_position)
#	print("loot position" ,loot_pos)
#	print("path i ",path[i])
#	for k in path.size() :
#		print("point ",k)
#		print(path[k])
#		print("path size is : ",path.size())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	_player_detector_is_colliding()
	while (status):
		
		loot_pos =  get_node("..").get_node("loot").position
		
		print("loot position at status is  ::",get_node("..").get_node("loot").position)
		print("enemy position at status :: ",global_position)
		path  = []
		path = nav_to_loot.get_simple_path(position,loot_pos,true)
		
		
		move_velocity =  (path[0] - position)
		my_initial_pos_2 = position
		path_last_point = path.size() - 1
		my_initial_pos = position
		line_2d.points = path2
		get_tree().get_root().add_child(e_timer)
		print(get_node("..").name," is parents name")
		print(move_velocity, ": is the move velocity")
		print("path last point :: ",path[path.size()-1])
	
		print("loot pos ",loot_pos)
		
		print("path [i ]",path[i])
		print("path [0] ",path[0])
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
		status = false
	
	
	
	#ENEMY SHOULD
	#1 PATROLL
	#CHECK LOOT         & RETURN FROM CHECKLOOT
	#2 BE IDLE
	#4 SEEYOU  & FOLLOW U
	#5 ATTACK YOU IF YOU STEAL
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
	elif(_enemy_state == _ENEMY_STATE.FOLLOW_PLAYER):
		# know players position 
		#know my position 
		# know the range where i can patrol
		#make path to player 
		#go to him by repeating if my area doesent colide with him.
		
		# check every frame if his position changed __>>> if it changed ::: make a new ppath.
		# if we reach player  wee change state to idle
		
		
		
		
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
		var x = get_node("player_detector").cast_to.x
		_direction.x = _direction.x * -1
		if !(_direction.x > 0 ) :
			get_node("Sprite").flip_h = true
			get_node("player_detector").cast_to.x = -400
		else:
			get_node("Sprite").flip_h = false
			get_node("player_detector").cast_to.x = 400

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
	_reset_sprite_and_player_detector(move_velocity)
	
	
	
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
			
			if((position.x <= path[i].x or position.y <= path[i].y) and i <= path_last_point):
				i = i + 1
				if(i == path.size()): #check if we have reached end of path.
					_on_reaching_destination(next_enemy_state,target_pos)
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = position
				
				print("i = :",i)
				move_velocity = path[i] - position
		
		elif my_initial_pos_2.x >= path[i].x and my_initial_pos_2.y <= path[i].y :
			#lesser in x and greater in y means we have reached.
			print("sec 2")
			if((position.x <= path[i].x or position.y >= path[i].y) and i <= path_last_point):
				i = i + 1
				if(i == path.size()):
					_on_reaching_destination(next_enemy_state,target_pos)
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = position
				
				print("i = :",i)
				move_velocity = path[i] - position
			
		elif my_initial_pos_2.x <= path[i].x and my_initial_pos_2.y >= path[i].y :
			print("sec 3")
			print("in 3 i  = ",i)
			#greater in x and lesser in y means we have reached.
			if((position.x >= path[i].x and position.y <= path[i].y) and (i <= path_last_point)):
				i = i + 1
				if(i == path.size()): #check if we have reached end of path.
					_on_reaching_destination(next_enemy_state,target_pos)
					return
					
				#reset initial position to your pos
				my_initial_pos_2 = position
				print("i = :",i)
				move_velocity = path[i] - position
				
		elif my_initial_pos_2.x <= path[i].x and my_initial_pos_2.y <= path[i].y :
			#greater in x and greater in y means we have reached.
			print("sec 4")
			print(move_velocity)
			if((position.x >= path[i].x or position.y >= path[i].y) and i <= path_last_point):
				i = i + 1
				print("i in section 4 increased ")
				print("i   =  ",i)
				if(i == path.size()): #check if we have reached end of path.
					_on_reaching_destination(next_enemy_state,target_pos)
					
					return
				#reset initial position to your pos
				my_initial_pos_2 = position
				
				print("i = :",i)
				move_velocity = path[i] - position


func _on_reaching_destination(next_enemy_state:int,target_pos : Vector2)->void:
	i = 0
	print(get_node("..").name," is parent :destination reached ")
	move_velocity = Vector2(0,-200)
	position = target_pos
	_enemy_state = next_enemy_state
	my_initial_pos_2 = global_position
	if(next_enemy_state == _ENEMY_STATE.PATROLL):
		#make a new timer to count until next checkloot
		e_timer = enemy_timer.instance()
		e_timer.connect("time_finished", self, "_on_timer_timeout")
		get_tree().get_root().add_child(e_timer)
		_reset_sprite_and_player_detector(_velocity)

func _on_timer_timeout() ->void:
	
	print("Timer timeout was recived bpoooooiizi \n")
	if(_enemy_state == _ENEMY_STATE.PATROLL and is_on_floor() and !(is_on_wall())):
		path = nav_to_loot.get_simple_path(position,loot_pos,true)
		i = 0
		move_velocity =  (path[i] - position)
		my_initial_pos_2 = position
		path_last_point = path.size() - 1
		my_initial_pos = position
		_enemy_state = _ENEMY_STATE.CHECK_LOOT
	else :
		e_timer = enemy_timer.instance()
		e_timer.connect("time_finished", self, "_on_timer_timeout")
		get_tree().get_root().add_child(e_timer)

func _player_detector_is_colliding() ->void:
	if(player_detector.is_colliding()):
		if player_detector.get_collider().name == "player":
			print("COllided with PLAYER  booooizzz :::::::::::::::::\n\n\n")
			#THIS MEANS WE HAVE SEEN A PLAYER AND SHOULD ATTACK HIM
			#_enemy_state = _ENEMY_STATE.FOLLOW_PLAYER
		else:
			print("Collided with ",player_detector.get_collider().name)

func _reset_sprite_and_player_detector(velocity : Vector2) -> void:
	if(velocity.x>0):
		get_node("Sprite").flip_h = false
		player_detector.cast_to.x  = 400
	else:
		var x  = get_node("player_detector").cast_to.x
		$Sprite.flip_h = true
		player_detector.cast_to.x  = -400
		player_detector.cast_to.x  = -400
