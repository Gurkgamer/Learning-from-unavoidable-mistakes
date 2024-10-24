extends Control

const LEVEL = preload("res://Scenes/level.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween := create_tween()
	tween.set_loops()
	#tween.set_trans(Tween.TRANS_SINE)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(%PressStart,"scale",Vector2(1.2,1.2),0.4)
	tween.tween_property(%PressStart,"scale",Vector2(1,1),0.4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("Jump"):
		var game_instance = LEVEL.instantiate()
		get_parent().add_child(game_instance)
		queue_free()
