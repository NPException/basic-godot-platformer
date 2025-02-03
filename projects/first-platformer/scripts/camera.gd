class_name Camera
extends Camera2D

@export var shakeFade: float = 50.0

var rng := RandomNumberGenerator.new()

var shake_strength: float = 0.0


func apply_shake(strength: float) -> void:
	# only apply shake if new strength is higher than current strength
	if strength > shake_strength:
		shake_strength = strength

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if shake_strength > 0.0:
		shake_strength = move_toward(shake_strength, 0, shakeFade * delta) #clampf(shake_strength - shakeFade * delta, 0.0, INF)
		offset = randomOffset()
	else:
		offset = Vector2.ZERO

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))


#@export_category("Screenshake")
#@export var decay := 0.8  # How quickly the shaking stops [0, 1].
#@export var max_offset := Vector2(20, 15)  # Maximum hor/ver shake in pixels.
#@export var max_roll := 0.1  # Maximum rotation in radians (use sparingly).
#
#var trauma: float = 0.0  # Current shake strength.
#var trauma_power: float = 2  # Trauma exponent. Use [2, 3].
#
#func add_trauma(amount: float) -> void:
	#trauma = min(trauma + amount, 1.0)
#
#
#func _process(delta: float) -> void:
	#if trauma:
		#trauma = max(trauma - decay * delta, 0)
		#shake()
#
#
#func shake() -> void:
	#var amount := pow(trauma, trauma_power)
	#rotation = max_roll * amount * randi_range(-1, 1)
	#offset.x = max_offset.x * amount * randi_range(-1, 1)
	#offset.y = max_offset.y * amount * randi_range(-1, 1)
