class_name GameManager
extends Node

@onready var score_label: Label = %ScoreLabel
@onready var camera: Camera = %Camera

@onready var music_bus_index: int = AudioServer.get_bus_index("Music")

@onready var max_coins := %Coins.get_children().size()

var score: int = 0

var mute_music := false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("mute_music"):
		mute_music = !mute_music
		AudioServer.set_bus_mute(music_bus_index, mute_music)


func add_point() -> void:
	score += 1
	score_label.text = "You collected " + str(score) + "/" + str(max_coins) + " coins."


func screen_shake(amount: float) -> void:
	camera.apply_shake(amount)
