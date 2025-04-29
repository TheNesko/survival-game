extends Node
class_name StateMachine

enum state {IDLE,WALK,JUMP,FALL}

@export var start_state : state
var current_state : state
var previous_state : state

func _ready() -> void:
	current_state = start_state
	previous_state = start_state

func change_state(new_state: state) -> bool:
	if new_state == current_state: return false
	previous_state = current_state
	current_state = new_state
	exit_state(previous_state)
	enter_state(new_state)
	return true

func set_state() -> state:
	return current_state

func enter_state(new_state: state):
	return

func exit_state(old_state: state):
	return
