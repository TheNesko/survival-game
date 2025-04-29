extends ResourceClass

func _physics_process(delta: float) -> void:
	if $Stats.is_alive() == false:
		queue_free()
		drop_resources()
		
