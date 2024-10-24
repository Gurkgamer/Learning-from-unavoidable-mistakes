extends AnimatedSprite2D

signal bonfire_touched(value : int, reference : Node2D)
var my_id : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	my_id = get_meta("id")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" :
		bonfire_touched.emit(my_id, self)
