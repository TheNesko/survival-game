extends StateMachine

@onready var parent = self.get_parent()

var state_name : String

func _physics_process(delta: float) -> void:
	change_state(set_state())

func set_state() -> state:
	if parent.velocity.y > 0:
		return state.JUMP
	if parent.velocity.y < 0:
		return state.FALL
	if parent.velocity.x != 0 or parent.velocity.z != 0:
		return state.WALK
	return state.IDLE

func enter_state(new_state: state):
	match current_state:
		state.IDLE:
			if DEBUG.debuging:
				state_name = "Idle"
		state.WALK:
			if DEBUG.debuging:
				state_name = "Walk"
		state.JUMP:
			if DEBUG.debuging:
				state_name = "Jump"
		state.FALL:
			if DEBUG.debuging:
				state_name = "Fall"

func exit_state(old_state: state):
	return
