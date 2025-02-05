class_name FreezeFrames
extends Node

# calling freeze will pause the game after the the current physics tick.
# calling await freeze will pause immediately
func freeze(amount: int) -> void:
	var tree := get_tree()
	#tree.physics_interpolation = false
	tree.paused = true
	await tree.create_timer(amount / 60.0).timeout
	tree.paused = false
	#tree.physics_interpolation = true
