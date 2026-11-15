extends CharacterBody2D

const JUMP_VELOCITY = -400.0
var fall_speed = 1000.0
var dive_speed = 3000.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var oxycrystal = $"../../OxyCrystal"
@onready var gasoline = $"../../Gasoline"
@onready var stargel = $"../../StarGel"
@onready var oxycrystal_text = $Camera2D/OxyCrylabel
@onready var gasoline_text = $Camera2D/GasLabel
@onready var stargel_text = $Camera2D/StargelLabel
@onready var ship = $"../../Ship/Area2D"
@onready var timer = $Camera2D/Timer

var ground_speed = 100.0
var ground_acceleration = 5.0
var prev_y = 0.0

var coyote_time = 0.0

enum MovementStates {
	IDLE,
	WALKING,
	FALLING,
	DIVING,
}
var state = MovementStates.IDLE
var diving = false
var bounce = false

func handle_movement_states(delta):
	var direction := Input.get_axis("ui_left", "ui_right")
	match state:
		MovementStates.IDLE:
			velocity.x = move_toward(velocity.x, 0, ground_speed)
		MovementStates.WALKING:
			if direction:
				velocity.x = direction * ground_speed
				if Variables.sprint_enable:
					if direction == 1.0:
						ground_speed += direction * ground_acceleration
					else: 
						ground_speed -= direction * ground_acceleration
		MovementStates.FALLING:
			velocity.x = direction * ground_speed
			velocity += get_gravity().normalized() * fall_speed * delta
		MovementStates.DIVING:
			velocity.x = direction * ground_speed
			velocity += get_gravity().normalized() * dive_speed * delta
			if bounce:
				velocity.y = prev_y * -0.6
				bounce = false

func transition_movement_states(new_state: MovementStates) -> MovementStates:
	match new_state:
		MovementStates.IDLE:
			ground_speed = 300.0
			return MovementStates.IDLE
		MovementStates.WALKING:
			return MovementStates.WALKING
		MovementStates.FALLING:
			return MovementStates.FALLING
		MovementStates.DIVING:
			return MovementStates.DIVING
	return MovementStates.IDLE

func _physics_process(delta: float) -> void:
	var new_state = state
	# Add the gravity.
	if not is_on_floor():
		animated_sprite_2d.animation = "Jump"
		coyote_time += delta
	else:
		coyote_time = 0.0
		
	if velocity.x > 1 or velocity.x < -1:
		$AnimatedSprite2D.animation = "Move"
	else:
		new_state = MovementStates.IDLE
		$AnimatedSprite2D.animation = "Idle"
		
	if stargel.has_overlapping_bodies():
		stargel_text.text = "Stargel: O"
		stargel.visible = false
	if oxycrystal.has_overlapping_bodies():
		oxycrystal_text.text = "Oxycrystal: O"
		oxycrystal.visible = false
	if gasoline.has_overlapping_bodies():
		gasoline_text.text = "Gasoline: O"
		gasoline.visible = false
		
	if ship.has_overlapping_bodies() and not gasoline.visible and not stargel.visible and not oxycrystal.visible:
		match Variables.level:
			0:
				Variables.bounce_enable = true
				get_tree().change_scene_to_file("res://level2.tscn")
				Variables.level = 1
			1:
				print("yay")
				get_tree().change_scene_to_file("res://win_screen.tscn")
		
	var direction := Input.get_axis("ui_left", "ui_right")
	if is_on_floor() or coyote_time < 0.1:
		diving = false
		if prev_y > 100.0 and state == MovementStates.DIVING and not bounce and Variables.bounce_enable:
			bounce = true
			new_state = MovementStates.DIVING
		elif direction:
			new_state = MovementStates.WALKING
		else:
			new_state = MovementStates.IDLE
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_pressed("ui_up"):
			diving = true
		if diving:
			new_state = MovementStates.DIVING
		else:
			new_state = MovementStates.FALLING

	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	if direction == -1.0:
		animated_sprite_2d.flip_h = true
		
		
		
	state = transition_movement_states(new_state)
	handle_movement_states(delta)
	
	prev_y = velocity.y
	
	move_and_slide()
