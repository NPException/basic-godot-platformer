extends Node
# Keeps track of recent inputs in order to make timing windows more flexible.
# Intended use: Add this file to your project as an Autoload script and have other objects call the class' methods.
# (more on AutoLoad: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)

const DEFAULT_BUFFER_WINDOW: int = 5

# The godot default deadzone is 0.2 so I chose to have it the same
const JOY_DEADZONE: float = 0.2

# TODO: use typed dictionaries once Godot 4.4 lands
var mapped_actions: Dictionary = {}
# map to keep track of currently "active" joy axis inputs
var joy_motion_active: Dictionary = {}
# map from action string to timestamp when the action was last triggered
var timestamps: Dictionary = {}


func _axis_code(event: InputEventJoypadMotion) -> int:
	# offset the axis since they start at 0
	return (event.axis + 1) * int(signf(event.axis_value))


func _input_key(event: InputEvent) -> String:
	if event is InputEventKey:
		return "keyboard_" + str(event.physical_keycode)
	elif event is InputEventJoypadButton:
		return "joypad_" + str(event.button_index)
	elif event is InputEventJoypadMotion:
		return "joyaxis_" + str(_axis_code(event))
	return ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# build mapped actions
	for action: String in InputMap.get_actions():
		for event: InputEvent in InputMap.action_get_events(action):
			var input_key := _input_key(event)
			if !input_key.is_empty():
				mapped_actions[input_key] = action
				if event is InputEventJoypadMotion:
					joy_motion_active[input_key] = false
			else:
				assert(false, "unhandled input event! " + event.as_text())


# Called whenever the player makes an input.
func _unhandled_input(event: InputEvent) -> void:
	# Unhandled_input is called between physics ticks, so the tick hasn't incremented yet.
	# That's why we add 1 frame here, to associate this input with the upcoming physics frame.
	var next_physics_frame := Engine.get_physics_frames() + 1
	
	var input_key := _input_key(event)
	if input_key.is_empty():
		return
	if !mapped_actions.has(input_key):
		print("not an action")
		return
		
	if event is InputEventKey && (!event.pressed || event.is_echo()):
		return
	elif event is InputEventJoypadButton && (!event.pressed || event.button_index == JOY_BUTTON_INVALID):
		return
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) < JOY_DEADZONE || event.axis == JOY_AXIS_INVALID:
			# mark the axis as inactive once we're back in the deadzone
			joy_motion_active[input_key] = false
			return
		elif joy_motion_active[input_key]:
			# don't set timestamp if the axis was already activated
			return
		# mark axis as active
		joy_motion_active[input_key] = true
	
	timestamps[mapped_actions[input_key]] = next_physics_frame


func _clear_buffered_input(action: String) -> void:
	timestamps.erase(action)


# Returns whether any of the keyboard keys or joypad buttons in the given action were pressed within the buffer window.
# Consumes that buffered input.
func is_action_press_buffered(action: String, buffer_window: int = DEFAULT_BUFFER_WINDOW) -> bool:
	var current_physics_frame := Engine.get_physics_frames()
	if timestamps.has(action) && current_physics_frame - timestamps[action] <= buffer_window:
		# Prevent this method from returning true repeatedly for the same input on consecutive frames
		_clear_buffered_input.call_deferred(action)
		return true
	return false
