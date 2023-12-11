class_name DiceRoll
extends Resource

# Enums
enum DiceType { BASE, SKILL, GEAR }

# Public variables
@export var dice_type: DiceType
@export var dice_result: int


# Engine methods
func _init(p_dice_type = DiceType.BASE, p_dice_result = 1):
	dice_type = p_dice_type
	dice_result = p_dice_result
