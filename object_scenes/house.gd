extends Node2D

# WE NEED TO MAKE LOOTBOX SPAWN IN RANDOM
onready var loot_box : = get_node("loot")
onready var enemy : = get_node("enemy")
var loot_pos_x :int
var guarded_area_length_px  = 925

# x points for the loot

var point_one :int = 97
var point_two :int = 286
var point_three:int = 532
var point_four:int = 728

# y for the loot
var loot_pos_y  =  190
enum side{LEFT,RIGHT}

var choice_of_side:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	choice_of_side = rand_range(side.LEFT,2)
	print("the system chose side :::: ",choice_of_side)
	if(choice_of_side == side.RIGHT):
		randomize()
		loot_pos_x = rand_range(point_three,point_four)
	elif(choice_of_side == side.LEFT):
		randomize()
		loot_pos_x = rand_range(point_one,point_two)
	
	# set the loot box position to its vaue
	loot_box.global_position = ( global_position + Vector2(loot_pos_x,loot_pos_y))
	
	print("House code has run ")
	print(get_node("enemy").global_position,"is enemys global position")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
