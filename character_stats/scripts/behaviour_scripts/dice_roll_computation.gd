extends Node
class_name DiceRollComputation

# Public variables
@export_group("Input")
@export var rolling_character : Character
@export var skill_to_roll_for : CharacterSkill

@export_group("Output")
@export var roll_result : DiceRollResult

# Public methods
func roll():
	# Clear previous result
	roll_result.result.clear()
	
	# Roll base dices
	var base_dice_to_roll = rolling_character.attributes[skill_to_roll_for.associated_attribute]
	for i in range(base_dice_to_roll):
		roll_result.result.append(
				DiceRoll.new(DiceRoll.DiceType.BASE, randi() % 6 + 1))
	
	# Roll skill dices
	var skill_dice_to_roll = rolling_character.skills[skill_to_roll_for]
	for i in range(skill_dice_to_roll):
		roll_result.result.append(
				DiceRoll.new(DiceRoll.DiceType.SKILL, randi() % 6 + 1))
	
	# TODO: Roll gear dices
	
	# Save result
	ResourceSaver.save(roll_result, roll_result.resource_path)
