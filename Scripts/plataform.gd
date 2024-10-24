extends Node2D

var original_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var timer
		if body.allow_jump:
			timer = 0.3
		elif body.allow_run :
			timer = 0.2
		else:
			timer = 0.02
		await get_tree().create_timer(timer).timeout.connect(func():fall())

var tween
func fall() -> void:
	%CollisionShape2D.disabled = true
	if tween :
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y" ,position.y + 30.0 , 0.2)
	tween.tween_property(%Sprite2D, "modulate:a", 0, 0.2)
	tween.finished.connect(func(): 
		await get_tree().create_timer(2).timeout.connect(
			func():
				global_position = original_position
				%Sprite2D.modulate.a = 1
				%CollisionShape2D.disabled = false)
		)
	
	
