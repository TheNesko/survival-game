extends StatisticsComponent

@onready var equipment = get_parent().get_node("Equipment")

func _ready() -> void:
	SignalBus.item_equip.connect(apply_equipment_stats)
	SignalBus.item_unequip.connect(apply_equipment_stats)

func apply_equipment_stats(slot):
	var equipped = equipment.equipped
	for item in equipped:
		if equipped[item] == null: continue
		var bonus = equipped[item].item.stat_bonus
		for stat in stats:
			for bonus_stat in bonus:
				if stat == bonus_stat:
					stats[stat] += bonus[stat]
