extends Camera2D

var player : CharacterBody2D
var follow_player : bool
const DEFAULT_CAMERA_ZOOM : Vector2 = Vector2(3,3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_player_node()
	zoom = DEFAULT_CAMERA_ZOOM
	#Engine.time_scale = 0.01z

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !player :
		get_player_node()
	
	if follow_player :
		position = player.position

func get_player_node() -> void:
	if !player :
		player = get_tree().get_first_node_in_group("Player")
		follow_player = true
