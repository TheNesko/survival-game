extends StaticBody3D

func _physics_process(delta: float) -> void:
	if not $Stats.is_alive():
		queue_free()
