extends Node2D

var last_bonfire : int = -1
var _bonfire : Node2D
var bonfire : Node2D : 
	get:
		return _bonfire
	set (value):
		_bonfire = value

@onready var player: CharacterBody2D = %Player
@onready var player_dead_timer: Timer = %PlayerDeadTimer
const BILLBOARD = preload("res://Scenes/billboard.tscn")
@onready var tutorial_timer: Timer = %TutorialTimer

var abilities : Dictionary = {
	0 : false,
	1 : false,
	2 : false,
	3 : false
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for next_bonfire in get_tree().get_nodes_in_group("bonfire"):
		next_bonfire.bonfire_touched.connect(_on_bonfire_touch)
	player.player_dead.connect(_on_player_dead)


func _on_bonfire_touch(value : int, node : Node2D) -> void:
	if last_bonfire < value :
		last_bonfire = value
		bonfire = node

func _on_player_dead() -> void:
	player.stop_player_control(true)
	player_dead_timer.start()

func _on_player_dead_timer_timeout() -> void:
	player.global_position = bonfire.global_position
	player.global_position.x -= 20
	player.global_position.y += 8
	player.play_animation("idle")
	if abilities.has(last_bonfire) :
		player.set_facing_sprite(false)
		player.show_dots(true)
		if abilities[last_bonfire] :
			player.stop_player_control(false)
			player.show_dots(false)
		else:
			tutorial_timer.start()
	else:
		player.stop_player_control(false)

func _on_tutorial_timer_timeout() -> void:
	play_tutorial(last_bonfire)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" :
		player.kill_player()

func play_tutorial(last_bonfire_value : int) -> void :
	abilities[last_bonfire_value] = true
	var billboard_instance = BILLBOARD.instantiate()
	get_parent().add_child(billboard_instance)
	billboard_instance.set_ability_board(last_bonfire_value)
	billboard_instance.global_position = player.global_position


func _on_cheat_code_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.allow_run = true
		body.allow_jump = true
		body.allow_dash = true
		body.allow_double_jump = true
