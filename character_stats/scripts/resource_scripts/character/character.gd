class_name Character
extends Resource

# TODO: Kin and Profession types are complex enough that it would be
# interesting for it to hold their own metadata, therefore it would be more
# scalable to build it as a separate resource of its own.

# Enums
enum Kin { HUMAN, ELF, HALF_ELF, DWARF, HALFING, WOLFKIN, ORC, GOBLIN }

enum Profession {
	DRUID,
	FIGHTER,
	HUNTER,
	MINSTREL,
	PEDDLER,
	RIDER,
	ROGUE,
	SORCERER,
}

# Public variables
@export var kin: Kin
@export var profession: Profession
@export var attributes: Dictionary = {
	preload("res://character_stats/assets/data/system/attributes/strength.tres"): 0,
	preload("res://character_stats/assets/data/system/attributes/agility.tres"): 0,
	preload("res://character_stats/assets/data/system/attributes/wits.tres"): 0,
	preload("res://character_stats/assets/data/system/attributes/empathy.tres"): 0,
}
@export var skills: Dictionary = {
	preload("res://character_stats/assets/data/system/skills/strength/might.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/strength/endurance.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/strength/melee.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/strength/crafting.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/agility/stealth.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/agility/sleight_of_hand.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/agility/move.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/agility/marksmanship.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/wits/scouting.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/wits/lore.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/wits/survival.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/wits/insight.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/empathy/manipulation.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/empathy/performance.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/empathy/healing.tres"): 0,
	preload("res://character_stats/assets/data/system/skills/empathy/animal_handling.tres"): 0
}
