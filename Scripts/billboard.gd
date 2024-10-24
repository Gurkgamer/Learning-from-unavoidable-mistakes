extends Node2D

@onready var allow_skip_timer: Timer = %AllowSkipTimer
var allow_skip : bool = false
var player
@onready var controls: Label = %Controls

func _ready() -> void:
	allow_skip_timer.start()
	if !player :
		player = get_tree().get_first_node_in_group("Player")
	

func set_ability_board(value : int) -> void:
	
	match value:
		0: #Run
			%Ability_Name.text = "Run!"
			%RunAbility.visible = true
			%Controls.text ="Press Z"
			player.enable_run()
		1: #Jump
			%Ability_Name.text = "Jump!"
			%JumpAbility.visible = true
			player.enable_jump()
			%Controls.text ="Press Space"
		2: #Dash
			%Ability_Name.text = "Dash!"
			%DashAbility.visible = true
			player.enable_dash()
			%Controls.text ="Press X"
		3: #DoubleJump
			%Ability_Name.text = "Double Jump!"
			%DoubleJumpAbility.visible = true
			player.enable_double_jump()
			%Controls.text ="Press Space after jumping"

func _input(event: InputEvent) -> void:
	if allow_skip :
		player.stop_player_control(false)
		player.show_dots(false)
		queue_free()

func _on_allow_skip_timer_timeout() -> void:	
	allow_skip = true
	
