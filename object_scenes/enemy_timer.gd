extends Timer

signal time_finished
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	time = rand_range(20,25)
	wait_time = time
	start()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_enemy_timer_timeout() -> void:
	emit_signal("time_finished")
	queue_free()
	pass # Replace with function body.
