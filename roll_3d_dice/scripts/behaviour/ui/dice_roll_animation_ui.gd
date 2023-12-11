extends Node
class_name DiceRollAnimationUI

# Public variables
@export_group("References")
@export var dice_results_UI: Node
@export var roll_result_UI: PackedScene
@export_group("Output")
@export var dice_roll_result: DiceRollResult

var roll_result_UIs: Array[Node]


# Engine methods
func _ready():
	# TODO: Load dice_roll_result into UI
	dice_roll_result.result.clear()


# UI Callbacks
func on_add():
	# Instantiate roll result UI
	var new_roll_result_UI = roll_result_UI.instantiate()
	roll_result_UIs.append(new_roll_result_UI)
	dice_roll_result.result.append(DiceRoll.new())

	# Set below "add" and "remove" buttons
	dice_results_UI.add_child(new_roll_result_UI)
	dice_results_UI.move_child(new_roll_result_UI, dice_results_UI.get_child_count() - 3)

	# Connect to signals of the new UI binding its index
	new_roll_result_UI.dice_type_UI.item_selected.connect(
		on_dice_type_selected.bind(roll_result_UIs.size() - 1)
	)
	new_roll_result_UI.dice_result_UI.value_changed.connect(
		on_dice_result_set.bind(roll_result_UIs.size() - 1)
	)


func on_dice_type_selected(selected_item_id: int, roll_result_id: int):
	dice_roll_result.result[roll_result_id].dice_type = selected_item_id as DiceRoll.DiceType


func on_dice_result_set(new_value: int, roll_result_id: int):
	dice_roll_result.result[roll_result_id].dice_result = new_value


func on_remove():
	if !roll_result_UIs.is_empty():
		roll_result_UIs[roll_result_UIs.size() - 1].queue_free()
		roll_result_UIs.pop_back()
		dice_roll_result.result.pop_back()
