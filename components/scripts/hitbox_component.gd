extends Area3D
class_name Hitbox


func _on_area_entered(area: Area3D) -> void:
	var tatget_stats = area.get_parent().find_child("Stats")
	var stats = get_parent().get_node("Stats")
	if tatget_stats == null or stats == null: return
	tatget_stats.remove_health(stats.stats["damage"])
