extends Node2D

#onready var nav_2d : Navigation2D  = get_node("nav_to_loot")
#onready var line_2d : Line2D = $Line2D
#onready var enemy:KinematicBody2D = $enemy
#onready var path : PoolVector2Array
#var destination = Vector2(18400,320)
#var move_vector : Vector2
#var i :int
#var j :int = 0
#var loop  : =  true
#var done:int  = 1
#var check_loot_delay : int 




func _ready() -> void:
	pass


func _process(delta: float) -> void:
#	yield(get_tree().create_timer(10),"timeout")
#	if(done == 1 and enemy._enemy_state == 0):
#		enemy.path = enemy.nav_to_loot.get_simple_path(enemy.global_position,enemy.loot_pos,true)
#		enemy.i = 0
#		enemy.move_velocity =  (enemy.path[i] - enemy.global_position)
#		enemy.my_initial_pos_2 = enemy.global_position
#		enemy.path_last_point = enemy.path.size() - 1
#		enemy.my_initial_pos = enemy.global_position
#		enemy._enemy_state = 2
#		done = 2;
#		print("####### size of  path ",path.size())
#	else :
#		check_loot_delay = rand_range(5,15)
	pass


