extends Node2D

const SPEED : float = 60.0

var direction : int = 1

@onready var ray_cast_wall: RayCast2D = $RayCastWall
@onready var ray_cast_floor: RayCast2D = $RayCastFloor
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# TODO: make slime a rigid body or CharacterBody2D, to have it affected by gravity
func _physics_process(delta: float) -> void:
	# if we approach a wall or ledge
	if ray_cast_wall.is_colliding() || !ray_cast_floor.is_colliding():
		# flip direction
		direction *= -1
		animated_sprite.flip_h = direction == -1
		# flip ray cast directions
		ray_cast_wall.target_position.x = -ray_cast_wall.target_position.x;
		ray_cast_floor.target_position.x = -ray_cast_floor.target_position.x;

	position.x += direction * SPEED * delta
