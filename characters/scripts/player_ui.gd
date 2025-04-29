extends Control

@onready var parent = get_parent()

@onready var cursor = $cursor
@onready var target_name = $target_name

func _physics_process(_delta: float) -> void:
	cursor.color = Color(1,1,1)
	target_name.text = ""
	if parent.interaction_target != null:
		cursor.color = Color(1,0,0)
		target_name.text = parent.interaction_target.name
