extends Node
# Keeps track of recent inputs in order to make timing windows more flexible.
# Intended use: Add this file to your project as an Autoload script and have other objects call the class' methods.
# (more on AutoLoad: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)

# TODO: change such that `is_action_press_buffered` takes an optional second parameter for the number of frames since it was last pressed

const DEFAULT_BUFFER_WINDOW: int = 5

# The godot default deadzone is 0.2 so I chose to have it the same
const JOY_DEADZONE: float = 0.2

# TODO: use typed dictionaries once Godot 4.4 lands
var keyboard_timestamps: Dictionary
var joypad_timestamps: Dictionary
var joymotion_timestamps: Dictionary

# TODO: build map from possible button keys to to action strings
var mapped_actions: Dictionary
# TODO: map from action string to timestamp
var timestamps: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Initialize all dictionary entris.
	keyboard_timestamps = {}
	joypad_timestamps = {}
	joymotion_timestamps = {}


func _axis_code(event: InputEventJoypadMotion) -> int:
	# offset the axis since they start at 0
	return (event.axis + 1) * int(signf(event.axis_value))


# Called whenever the player makes an input.
func _unhandled_input(event: InputEvent) -> void:
	# Unhandled_input is called between physics ticks, so the tick hasn't incremented yet.
	# That's why we add 1 frame here, to associate this input with the upcoming physics frame.
	var elapsed_frames := Engine.get_physics_frames() + 1
	
	if event is InputEventKey:
		if !event.pressed or event.is_echo():
			return
		keyboard_timestamps[event.physical_keycode] = elapsed_frames
	elif event is InputEventJoypadButton:
		if !event.pressed || event.button_index == JOY_BUTTON_INVALID:
			return
		joypad_timestamps[event.button_index] = elapsed_frames
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) < JOY_DEADZONE || event.axis == JOY_AXIS_INVALID:
			return
		joymotion_timestamps[_axis_code(event)] = elapsed_frames


# Returns whether any of the keyboard keys or joypad buttons in the given action were pressed within the buffer window.
# Consumes that buffered input.
func is_action_press_buffered(action: String, buffer_window: int = DEFAULT_BUFFER_WINDOW) -> bool:
	var elapsed_frames := Engine.get_physics_frames()
	# Get the inputs associated with the action. If any one of them was pressed in the last BUFFER_WINDOW milliseconds,
	# the action is buffered.
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var keycode: int = event.physical_keycode
			if keyboard_timestamps.has(keycode):
				if elapsed_frames - keyboard_timestamps[keycode] <= buffer_window:
					# Prevent this method from returning true repeatedly and registering duplicate actions
					keyboard_timestamps[keycode] = 0
					return true;
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				if elapsed_frames - joypad_timestamps[button_index] <= buffer_window:
					# Prevent this method from returning true repeatedly and registering duplicate actions
					joypad_timestamps[button_index] = 0
					return true
		elif event is InputEventJoypadMotion:
			if abs(event.axis_value) < JOY_DEADZONE:
				return false
			var axis_code: int = _axis_code(event)
			if joymotion_timestamps.has(axis_code):
				if elapsed_frames - joymotion_timestamps[axis_code] <= buffer_window:
					# Prevent this method from returning true repeatedly and registering duplicate actions
					joymotion_timestamps[axis_code] = 0
					return true
	return false
