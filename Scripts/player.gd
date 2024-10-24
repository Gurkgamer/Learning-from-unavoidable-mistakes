extends CharacterBody2D

signal player_dead() 

@onready var animation_sprite_2d: AnimatedSprite2D = %AnimationSprite2D
@onready var dots: Sprite2D = %Dots
@onready var exclamation: Sprite2D = %Exclamation

#Jump Ability Related
@onready var coyote_timer: Timer = %CoyoteTimer
@onready var jump_buffer_timer: Timer = %JumpBufferTimer
const DASH_SPRITE_TRAIL = preload("res://Scenes/dash_sprite_trail.tscn")

const WALK_SPEED = 80.0
const RUN_SPEED = 160.0
const DASH_SPEED = 400.0
var speed : float = WALK_SPEED
const JUMP_VELOCITY = -400.0
var stop_control : bool = false

func stop_player_control(value : bool) -> void:
	stop_control = value
	
func show_exclamation(value : bool) -> void:
	exclamation.visible = value
	
func show_dots(value : bool) -> void:
	dots.visible = value

func _physics_process(delta: float) -> void:
	if stop_control:
		velocity += get_gravity() * delta
		move_and_slide()
		return
	# Add the gravity.
	if not is_on_floor() and !dashing:
		velocity += get_gravity() * delta
	
	if is_on_floor() :
		coyote_available = true
		jumped = false
		double_jumped = false
		dash_possible = true
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
		if !allow_run :
			animation_sprite_2d.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	
	run_ability(direction)
	jump_ability()
	dash_ability(direction)
	double_jump_ability()

	# FLIP SPRITE TO DIRECTION
	if direction > 0 :
		animation_sprite_2d.flip_h = false
	elif direction < 0:
		animation_sprite_2d.flip_h = true
		
	if direction == 0 and is_on_floor():
		animation_sprite_2d.play("idle")

	if dashing :
		var dash_trail_instance = DASH_SPRITE_TRAIL.instantiate()
		dash_trail_instance.flip_h = animation_sprite_2d.flip_h
		dash_trail_instance.global_position = global_position
		get_parent().add_child(dash_trail_instance)

	move_and_slide()

# ABILITIES

# RUN
@export var allow_run : bool = false
func run_ability(direction) -> void:
	if !allow_run or !direction:
		return
		
	var animation_to_play : String = ""
		
	if Input.is_action_pressed("Run") and is_on_floor() :
		if !(animation_sprite_2d.animation == "dash" and animation_sprite_2d.is_playing()):
			speed = RUN_SPEED
			animation_to_play = "run"
	
	if is_on_floor() and !Input.is_action_pressed("Run"):
		if !(animation_sprite_2d.animation == "dash" and animation_sprite_2d.is_playing()):
			animation_to_play = "walk"
			speed = WALK_SPEED
			
	if animation_to_play != "" :
		animation_sprite_2d.play(animation_to_play)

# JUMP
@export var allow_jump : bool = false
@onready var jump_sfx: AudioStreamPlayer2D = %JumpSFX
var coyote_available : bool = true
var jump_buffered : bool = false
var jumped : bool = false
func jump_ability() -> void:
	if !allow_jump :
		return
		
	# Buffered Jump
	if jump_buffered and is_on_floor():
		jumped = true
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()
		coyote_available = false
		double_jumped = false
		return
		
	#Enough jump
	if Input.is_action_just_released("Jump") and !is_on_floor() and velocity.y < 0:
		velocity.y = 0

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()
		coyote_available = false
		jumped = true
		return
	
	# AIR DASH JUMP
	if !is_on_floor() and dashed and allow_dash and !jumped and Input.is_action_just_pressed("Jump"):
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()
		coyote_available = false
		jumped = true
		return
	
	# Start Coyote Time
	if !is_on_floor() and coyote_available and coyote_timer.is_stopped() :
		double_jumped = true
		coyote_timer.start()
	
	# Coyote jump
	if Input.is_action_just_pressed("Jump") and coyote_available and !is_on_floor():
		jumped = true
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()
		coyote_available = false
		return
		
	# Start Jump Buffer
	if !is_on_floor() and Input.is_action_just_pressed("Jump") and !jump_buffered :
		jump_buffer_timer.start()
		jump_buffered = true
		
	if !is_on_floor() and !dashing:
		animation_sprite_2d.play("jump")

func _on_coyote_timer_timeout() -> void:
	coyote_available = false
	double_jumped = false

func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false

# DOUBLE JUMP
@export var allow_double_jump : bool = false
var double_jumped : bool = false
func double_jump_ability() -> void:
	if !allow_double_jump :
		return
		
	if !is_on_floor() and !double_jumped and Input.is_action_just_pressed("Jump") and jumped:
		double_jumped = true
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()
		animation_sprite_2d.play("jump")

# DASH
@export var allow_dash : bool = false
@onready var dash_sfx: AudioStreamPlayer2D = %DashSFX
var dash_possible : bool = true
var dashing : bool = false
var dashed : bool = false
func dash_ability(direction) -> void:
	if !allow_dash  or direction == 0:
		return
		
	if dashed and !is_on_floor():
		return
		
	if dashed and is_on_floor() and !dashing:
		dashed = false
	
	if Input.is_action_just_pressed("Dash") and dash_possible:
		dash_sfx.play()
		animation_sprite_2d.play("dash")
		speed = speed + DASH_SPEED
		dash_possible = false
		dashing = true
		velocity.y = 0
		dashed = true
		get_tree().create_timer(0.1).timeout.connect(func()->void :
			speed = speed - DASH_SPEED
			animation_sprite_2d.stop()
			dashing = false
			)

func kill_player() -> void:
	animation_sprite_2d.play("dead")
	%DamageSFX.play()
	velocity = Vector2.ZERO
	on_player_dead()
	
func play_animation(animation_name : String) -> void :
	animation_sprite_2d.play(animation_name)

func set_facing_sprite(reverse_sprite : bool) -> void:
	animation_sprite_2d.flip_h = reverse_sprite

func on_player_dead() -> void:
	player_dead.emit()
	
func enable_run() -> void:
	allow_run = true
	
func enable_jump() -> void:
	allow_jump = true
	
func enable_dash() -> void:
	allow_dash = true

func enable_double_jump() -> void:
	allow_double_jump = true
