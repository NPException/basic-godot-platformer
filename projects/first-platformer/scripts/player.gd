class_name Player
extends CharacterBody2D

@onready var game_manager: GameManager = %GameManager

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var tap_sound: AudioStreamPlayer2D = $TapSound

const MAX_SPEED = 130.0
const MAX_FALL_SPEED = 300.0
const FLOOR_ACCELERATION_FRAMES = 5
const AIR_ACCELERATION_FRAMES = 10
const AIR_DRAG_FRAMES = 30

const FLOOR_ACCELERATION := MAX_SPEED / FLOOR_ACCELERATION_FRAMES
const AIR_ACCELERATION := MAX_SPEED / AIR_ACCELERATION_FRAMES
const AIR_DRAG := MAX_SPEED / AIR_DRAG_FRAMES

const JUMP_VELOCITY = -300.0
const DEATH_BUMP_VELOCITY = -200.0

const COYOTE_FRAMES = 6
const LAUNCH_LENIENCY_FRAMES = 6

var launch_frames_remaining := 0
var launch_velocity := Vector2.ZERO

var alive := true
var can_jump := true

var frames_since_floor := 0

var can_teleport := false

func check_speed() -> void:
	if velocity.x > 1000:
		print("weeeeee ", Engine.get_physics_frames(), " - ", velocity) # set breakpoint here

# TODO:
# - proportional jump. idea: quickly decay jump height when space is released mid jump (aka, increased gravity)
# - drop down through one-way platforms/tiles when pressing duck
# - separate floor acceleration and floor drag

func _physics_process(delta: float) -> void:
	if can_teleport && Input.is_action_just_pressed("yeet_reset"):
		global_position = Vector2(832, -16)
		velocity = Vector2.ZERO
	
	# get the input direction: negative, 0, positive
	var direction := Input.get_axis("move_left", "move_right")
	
	check_speed()
	
	# count frames since leaving the floor
	if is_on_floor():
		if frames_since_floor >= 6:
			tap_sound.play()
		frames_since_floor = 0
	else:
		frames_since_floor += 1
	
	# coyote time
	can_jump = is_on_floor() || can_jump && frames_since_floor <= COYOTE_FRAMES
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	
	if alive:
		# launch leniency
		# TODO: it seems like a jump on the very first frame of launch leniency will cause a massive yeet,
		#       so for consistency I should probably account for this... but it's funny if I don't
		
		var allow_launch_leniency := launch_frames_remaining > 0 # && launch_frames_remaining < LAUNCH_LENIENCY_FRAMES # don't allow launch on the frame that this happened
		var adjusted_velocity := launch_velocity if allow_launch_leniency else velocity
		launch_frames_remaining = maxi(0, launch_frames_remaining - 1)
		
		# Play animations
		if can_jump:
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		
		# Flip the sprite if necessary
		if direction != 0:
			animated_sprite.flip_h = direction < 0
		
		# Handle jump
		if Input.is_action_just_pressed("jump") and can_jump:
			if allow_launch_leniency:
				print("launching. launch frames left: ", launch_frames_remaining, " ticks: ", Engine.get_physics_frames())
			velocity = adjusted_velocity
			velocity.y = JUMP_VELOCITY if velocity.y > 0 else velocity.y + JUMP_VELOCITY
			check_speed()
			animated_sprite.play("jump")
			jump_sound.play()
			launch_frames_remaining = 0
			launch_velocity = Vector2.ZERO
			can_jump = false
		
		var target_speed := direction * MAX_SPEED
		
		if is_on_floor() && can_jump:
			velocity.x = move_toward(velocity.x, target_speed, FLOOR_ACCELERATION)
		else:
			var sign_a := signf(velocity.x)
			var sign_b := signf(target_speed)
			# use air drag only when target speed is same direction and lower than current speed
			var use_air_drag := sign_a == sign_b && absf(target_speed) < absf(velocity.x)
			velocity.x = move_toward(velocity.x, target_speed, AIR_DRAG if use_air_drag else AIR_ACCELERATION)
	
	move_and_slide()


func on_platform_velocity_shared(platform_velocity : Vector2) -> void:
	launch_frames_remaining = LAUNCH_LENIENCY_FRAMES
	launch_velocity = platform_velocity


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


func _on_teleport_enable_trigger_body_entered(body: Node2D) -> void:
	if body == self:
		can_teleport = true
