class_name DiceRollResult
extends Resource

# Public variables
@export var result: Array[DiceRoll]


# Public methods
func sort_by_dice_type():
	result.sort_custom(func(a, b): return a.dice_type < b.dice_type)
