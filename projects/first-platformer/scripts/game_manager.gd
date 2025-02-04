class_name GameManager
extends Node

@onready var score_label: Label = %ScoreLabel
@onready var camera: Camera = %Camera

@onready var max_coins := %Coins.get_children().size()

var score: int = 0


func add_point() -> void:
	score += 1
	score_label.text = "You collected " + str(score) + "/" + str(max_coins) + " coins."


func screen_shake(amount: float) -> void:
	camera.apply_shake(amount)
