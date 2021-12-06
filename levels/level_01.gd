extends Node2D

onready var nav_2d : Navigation2D  = get_node("nav_to_loot")
onready var line_2d : Line2D = $Line2D
onready var enemy:KinematicBody2D = $enemy
onready var path : PoolVector2Array
var destination = Vector2(18400,320)
var move_vector : Vector2
var i :int
var j :int = 0
var loop  : =  true

func _ready() -> void:
	set_process(false)
	path = nav_2d.get_simple_path(enemy.global_position,destination,true)
	line_2d.points = path
	i  = path.size()
	move_vector = (path[j] - enemy.global_position) 
	
	# VALUES NEEDED FOR CALCULATION
	
#	print("enemy position : ")
#	print(enemy.global_position)
#	var size :=  path.size()
#	for i in path.size() :
#		print("point ",i)
#		print(path[i])
#		print("path size is : ",path.size())
		

func _process(delta: float) -> void:
	#print("process is true in level script ::")
	enemy.move_and_slide(move_vector)
	_move_check_enemy()
	
	pass


func _move_check_enemy() -> void:
	if (enemy.global_position != destination):
		if(j==path.size()):
				move_vector = Vector2(0,1)
				print("this function finishhed :::::")
				return
		elif(enemy.global_position >= path[j] and j< path.size()-1):
			j += 1
			move_vector = path[j] - (enemy.global_position)
