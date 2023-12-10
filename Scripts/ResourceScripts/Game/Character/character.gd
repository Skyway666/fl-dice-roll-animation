class_name Character
extends Resource

# TODO: Kin and Profession types are complex enough that it would be 
# interesting for it to hold their own metadata, therefore it would be more
# scalable to build it as a separate resource of its own.

# Enums
enum Kin {
	HUMAN,
	ELF,
	HALF_ELF,
	DWARF,
	HALFING,
	WOLFKIN,
	ORC,
	GOBLIN
}

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
@export var kin : Kin
@export var profession : Profession
@export var attributes : Dictionary = {
	preload("res://Data/System/Attributes/Strength.tres"): 0,
	preload("res://Data/System/Attributes/Agility.tres"): 0,
	preload("res://Data/System/Attributes/Wits.tres"): 0,
	preload("res://Data/System/Attributes/Empathy.tres"): 0,
}
@export var skills : Dictionary = {
	preload("res://Data/System/Skills/Strength/Might.tres") : 0,
	preload("res://Data/System/Skills/Strength/Endurance.tres") : 0,
	preload("res://Data/System/Skills/Strength/Melee.tres") : 0,
	preload("res://Data/System/Skills/Strength/Crafting.tres") : 0,
	
	preload("res://Data/System/Skills/Agility/Stealth.tres") : 0,
	preload("res://Data/System/Skills/Agility/SleightOfHand.tres") : 0,
	preload("res://Data/System/Skills/Agility/Move.tres") : 0,
	preload("res://Data/System/Skills/Agility/Marksmanship.tres") : 0,
	
	preload("res://Data/System/Skills/Wits/Scouting.tres") : 0,
	preload("res://Data/System/Skills/Wits/Lore.tres") : 0,
	preload("res://Data/System/Skills/Wits/Survival.tres") : 0,
	preload("res://Data/System/Skills/Wits/Insight.tres") : 0,
	
	preload("res://Data/System/Skills/Empathy/Manipulation.tres") : 0,
	preload("res://Data/System/Skills/Empathy/Performance.tres") : 0,
	preload("res://Data/System/Skills/Empathy/Healing.tres") : 0,
	preload("res://Data/System/Skills/Empathy/AnimalHandling.tres") : 0
}
