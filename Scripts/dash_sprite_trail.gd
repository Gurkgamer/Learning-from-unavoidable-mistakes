extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a",0,0.1).finished.connect(func() -> void: queue_free())