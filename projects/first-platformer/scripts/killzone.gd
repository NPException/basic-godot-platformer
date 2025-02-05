extends Area2D

@onready var timer: Timer = $Timer
@onready var freeze_frames: FreezeFrames = $FreezeFrames

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player:
		player.kill()
		Music.volume_db = -20.0
		await freeze_frames.freeze(5)
		Engine.time_scale = 0.5
		timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	Music.volume_db = 0.0
	get_tree().reload_current_scene()
