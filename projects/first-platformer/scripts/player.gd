class_name Player
extends CharacterBody2D

@onready var game_manager: GameManager = %GameManager

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var tap_sound: AudioStreamPlayer2D = $TapSound

const MAX_SPEED = 130.0
const FLOOR_ACCELERATION_FRAMES = 5
const AIR_ACCELERATION_FRAMES = 10
const AIR_DRAG_FRAMES = 30

var floor_acceleration := (MAX_SPEED / FLOOR_ACCELERATION_FRAMES) * Engine.physics_ticks_per_second
var air_acceleration := (MAX_SPEED / AIR_ACCELERATION_FRAMES) * Engine.physics_ticks_per_second
var air_drag := (MAX_SPEED / AIR_DRAG_FRAMES) * Engine.physics_ticks_per_second

const JUMP_VELOCITY = -300.0
const DEATH_BUMP_VELOCITY = -200.0

const COYOTE_FRAMES = 6
var coyote_time := float(COYOTE_FRAMES) / Engine.physics_ticks_per_second

var alive := true
var can_jump := true

var time_since_floor := 0.0

# TODO:
# - quickly decay jump height when space is released mid jump (aka, increased gravity)

func _physics_process(delta: float) -> void:
	# get the input direction: negative, 0, positive
	var direction := Input.get_axis("move_left", "move_right")
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if alive:
		if is_on_floor():
			if time_since_floor > 0.1:
				tap_sound.play()
			time_since_floor = 0.0
		else:
			time_since_floor += delta
		
		# coyote time
		can_jump = is_on_floor() || can_jump && time_since_floor <= coyote_time
		
		# Play animations
		if can_jump:
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		
		# Handle jump.
		if Input.is_action_just_pressed("jump") and can_jump:
			can_jump = false
			velocity.y = JUMP_VELOCITY
			animated_sprite.play("jump")
			jump_sound.play()
		
		# Flip the sprite if necessary
		if direction != 0:
			animated_sprite.flip_h = direction < 0
		
		var target_speed := direction * MAX_SPEED
		if is_on_floor():
			velocity.x = move_toward(velocity.x, target_speed, floor_acceleration * delta)
		else:
			var sign_a := signf(velocity.x)
			var sign_b := signf(target_speed)
			# use air drag only when target speed is same direction and lower than current speed
			var use_air_drag := sign_a == sign_b && absf(target_speed) < absf(velocity.x)
			velocity.x = move_toward(velocity.x, target_speed, (air_drag if use_air_drag else air_acceleration) * delta)
	
	move_and_slide()


func kill() -> void:
	alive = false
	animated_sprite.play("death")
	hurt_sound.play()
	collision_shape.queue_free()
	# stop horizontal movement if we were moving downwards
	if velocity.y > 0:
		velocity.x = 0
	# bump up if we aren't already rising quicklyd
	if velocity.y > DEATH_BUMP_VELOCITY:
		velocity.y = DEATH_BUMP_VELOCITY
	# screenshake
	game_manager.screen_shake(10.0)
