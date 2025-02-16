extends Area3D

@onready var main: Node3D = $".."

@export var clicks_to_pop : int = 3
@export var size_increase : float = 0.2
@export var score_to_give : int = 1


func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var mb_event := event as InputEventMouseButton
	if mb_event and mb_event.button_index == MOUSE_BUTTON_LEFT and mb_event.pressed:
		scale += Vector3.ONE * size_increase
		clicks_to_pop -= 1
		
		if clicks_to_pop == 0:
			main.increase_score(score_to_give)
			queue_free()
