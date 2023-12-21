class_name DiceRollAnimationUI
extends Node

# Public variables
@export_group("References")
@export var dice_results_ui: Node
@export var dice_roll_ui: PackedScene
@export_group("Output")
@export var dice_roll_result: DiceRollResult

var dice_roll_uis: Array[Node]


# Engine methods
func _ready():
	# TODO: Load dice_roll_result into UI
	dice_roll_result.result.clear()


# UI Callbacks
func on_add_dice():
	# Instantiate roll result UI
	var new_roll_result_ui = dice_roll_ui.instantiate()
	dice_roll_uis.append(new_roll_result_ui)
	dice_roll_result.result.append(DiceRoll.new())

	# Set below "add" and "remove" buttons
	dice_results_ui.add_child(new_roll_result_ui)
	dice_results_ui.move_child(new_roll_result_ui, dice_results_ui.get_child_count() - 3)

	# Connect to signals of the new UI binding its index
	new_roll_result_ui.dice_type_ui.item_selected.connect(
		on_dice_type_selected.bind(dice_roll_uis.size() - 1)
	)
	new_roll_result_ui.dice_result_ui.value_changed.connect(
		on_dice_result_set.bind(dice_roll_uis.size() - 1)
	)


func on_dice_type_selected(selected_item_id: int, roll_result_id: int):
	dice_roll_result.result[roll_result_id].dice_type = selected_item_id as DiceRoll.DiceType


func on_dice_result_set(new_value: int, roll_result_id: int):
	dice_roll_result.result[roll_result_id].dice_result = new_value


func on_remove_dice():
	if !dice_roll_uis.is_empty():
		dice_roll_uis[dice_roll_uis.size() - 1].queue_free()
		dice_roll_uis.pop_back()
		dice_roll_result.result.pop_back()

