extends Area2D

onready var anim_player :AnimationPlayer = get_node("AnimationPlayer")

signal loot_box_award_player
var looted:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_loot_body_entered(body: Node) -> void:
	if (body.is_in_group("player"))and looted ==false:
		emit_signal("loot_box_award_player")
		looted = true
		anim_player.play("looting")
		$CollisionShape2D.disabled = true
		
	pass # Replace with function body.
