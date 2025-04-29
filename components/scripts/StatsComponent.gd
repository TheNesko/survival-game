extends Node
class_name StatisticsComponent

@export var base_stats : Dictionary = {
	"max_health": 10,
	"health": 10,
	"damage": 1,
}
var stats : Dictionary = base_stats

func set_health(value:int):
	stats["health"] = value
	if stats["health"] > stats["max_health"]:
		stats["health"] = stats["max_health"]

func add_health(value:int):
	stats["health"] += value
	if stats["health"] > stats["max_health"]:
		stats["health"] = stats["max_health"]

func remove_health(value:int):
	stats["health"] -= value
	is_alive()

func is_alive():
	if stats["health"] <= 0:
		stats["health"] = 0
		return false
	return true
