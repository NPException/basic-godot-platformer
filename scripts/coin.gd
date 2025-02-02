extends Area2D

@onready var game_manager: GameManager = %GameManager
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# start coin animation at random frame
	var frame_count := animated_sprite.sprite_frames.get_frame_count("default")
	animated_sprite.frame = randi_range(0, frame_count-1)

func _on_body_entered(_body: Node2D) -> void:
	game_manager.add_point()
	animation_player.play("pickup")
