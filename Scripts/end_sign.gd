extends Area2D

func _ready() -> void:
	var end_text = get_node("Control")
	end_text.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var end_text = get_node("Control")
		end_text.visible = true
		get_node("MessageRevealSFX").play()
