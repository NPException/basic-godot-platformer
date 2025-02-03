extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player:
		Engine.time_scale = 0.5
		player.kill()
		Music.volume_db = -20.0
		timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	Music.volume_db = 0.0
	get_tree().reload_current_scene()
