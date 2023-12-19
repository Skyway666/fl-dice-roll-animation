class_name DiceRollAnimation
extends Node

# Signals
signal animation_started
signal animation_ended

#Enums
enum ResultOrientation { LOOK_AT_CAMERA, LOOK_IN_CAMERA_DIRECTION }

# Public variables
@export_group("Input")
@export var dice_roll_result: DiceRollResult
@export_group("Parameters")
@export_subgroup("Scenes")
@export var physical_dice_type_scenes: Dictionary = {
	DiceRoll.DiceType.BASE: preload("res://roll_3d_dice/scenes/entities/base_physical_dice.tscn"),
	DiceRoll.DiceType.SKILL: preload("res://roll_3d_dice/scenes/entities/gear_physical_dice.tscn"),
	DiceRoll.DiceType.GEAR: preload("res://roll_3d_dice/scenes/entities/skill_physical_dice.tscn"),
}
@export_subgroup("Throw")
@export var throw_origin: Node3D
@export var throw_layout: CircularLayout3DParameters
@export_subgroup("Physics")
@export var generic_collision_layer: int = 1
@export var throw_force: float
@export var throw_force_random_variation: float
@export var throw_torque_range: float
@export_subgroup("Critical")
@export var critical: bool
@export var slowdown_time_scale: float
@export var slowdowns: int
@export var slowdown_duration: float
@export var slowdown_interval: float
@export var slowdown_stream_player: AudioStreamPlayer
@export_subgroup("Physics animation")
@export var physics_duration: float
@export var final_slowdown_duration: float
@export_subgroup("Result distribution")
@export var result_origin: Node3D
@export var result_max_row_elements: int
@export var result_layout: HorizontalLayout3DParameters
@export_subgroup("Result animation")
@export var result_animation_duration: float
@export var result_rotation_delay: float
@export var result_rotation_duration: float
@export var result_orientation: ResultOrientation
@export var dice_animated_angular_velocity: Vector3
@export var camera: Camera3D
@export var camera_result_position: Vector3

# Private variables
var _physical_dices: Array[RigidBody3D] = []
var _camera_initial_position: Vector3
var _animating = false
var _time_scale_animation: Tween
var _dice_position_tweens: Array[Tween]
var _dice_rotation_tweens: Array[Tween]
var _camera_animation: Tween


# Engine methods
func _ready():
	_camera_initial_position = camera.position


func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and _animating:
		_skip_animation()

# TODO: Figure out why this is not working
func _input(event):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
		and _animating
	):
		_skip_animation()


# Public methods
func set_critical(value: bool):
	critical = value


func start_animation():
	if dice_roll_result.result.size() > 0:
		# Sort dices
		dice_roll_result.sort_by_dice_type()
		# Reset everything
		_reset()
		# Start animation
		_destroy_dices()
		_instantiate_dices()
		_throw_dices()
		_play_time_scale_animation()
		# Emit event
		_animating = true
		animation_started.emit()


# Private methods
func _reset():
	# Kill tweens
	if _camera_animation != null && _camera_animation.is_valid():
		_camera_animation.kill()
	if _time_scale_animation != null && _time_scale_animation.is_valid():
		_time_scale_animation.kill()
	for dice_position_tween in _dice_position_tweens:
		dice_position_tween.kill()
	_dice_position_tweens.clear()
	for dice_rotation_tween in _dice_rotation_tweens:
		dice_rotation_tween.kill()
	_dice_rotation_tweens.clear()
	# Reset modified variables
	camera.position = _camera_initial_position
	Engine.time_scale = 1
	_stop_dices_animated_angular_velocity()


func _instantiate_dices():
	# Get dice positions for circular layout
	var circular_layout = Layouts3D.get_circular_layout(
		throw_origin.global_transform, dice_roll_result.result.size(), throw_layout
	)

	# Iterate positions in circular layout
	for i in dice_roll_result.result.size():
		# Instantiate and save physical dice
		var dice_roll = dice_roll_result.result[i]
		var physical_dice = physical_dice_type_scenes[dice_roll.dice_type].instantiate()
		add_child(physical_dice)
		_physical_dices.append(physical_dice)
		# Set position
		physical_dice.position = circular_layout[i]
		# Set rotation
		physical_dice.quaternion = throw_origin.quaternion


func _destroy_dices():
	for physical_dice in _physical_dices:
		physical_dice.queue_free()

	_physical_dices.clear()


func _throw_dices():
	# Throw dices
	for physical_dice in _physical_dices:
		physical_dice.apply_central_impulse(
			(
				throw_origin.basis.z
				* (
					throw_force
					* randf_range(
						1 - throw_force_random_variation, 1 + throw_force_random_variation
					)
				)
			)
		)
		physical_dice.angular_velocity = (Vector3(
			randf_range(-throw_torque_range, throw_torque_range),
			randf_range(-throw_torque_range, throw_torque_range),
			randf_range(-throw_torque_range, throw_torque_range)
		))


# Invoked when a dice collides with the inside of the roll zone
func _on_dice_entered_roll_zone(body):
	# Change layer mask to make dices collide with walls
	(body as CollisionObject3D).collision_layer = generic_collision_layer
	(body as CollisionObject3D).collision_mask = generic_collision_layer


func _play_time_scale_animation():
	# Dices animation
	_time_scale_animation = create_tween()
	var animation_duration = physics_duration

	# Add slowdowns to animation
	if critical:
		for i in slowdowns:
			# Wait
			_time_scale_animation.tween_interval(slowdown_interval)
			# Start slowdown
			_time_scale_animation.tween_callback(func():
				Engine.time_scale = slowdown_time_scale
				slowdown_stream_player.play()
				)
			# Wait	(time is slower so we need to adjust slowdown duration)
			_time_scale_animation.tween_interval(slowdown_duration * slowdown_time_scale)
			# Stop slowdown
			_time_scale_animation.tween_callback(func(): Engine.time_scale = 1)
			# Remove spent time from animation duration
			animation_duration -= (slowdown_interval + slowdown_duration)

	# Let dices bounce for "animation_duration"
	_time_scale_animation.tween_interval(animation_duration)
	# Slowly get them to stop
	_time_scale_animation.tween_method(
		_handle_time_scale_animation_final_slowdown, 1.0, 0.01, final_slowdown_duration
	)
	# Finally stop them
	_time_scale_animation.tween_callback(_animate_dices_results)


func _handle_time_scale_animation_final_slowdown(progress: float):
	Engine.time_scale = progress
	_time_scale_animation.set_speed_scale(1 / progress)


func _animate_dices_results():
	# Disable physics
	Engine.time_scale = 1
	_freeze_dices()

	# Make a vertical layout for each row and store the positions
	var dice_result_positions = _get_dice_result_positions()

	# Animate dices
	for i in _physical_dices.size():
		# Give angular velocity
		_physical_dices[i].animated_angular_velocity = dice_animated_angular_velocity
		#Animate position
		var position_tween = _physical_dices[i].create_tween()
		position_tween.set_trans(Tween.TRANS_SPRING)
		position_tween.tween_property(
			_physical_dices[i], "position", dice_result_positions[i], result_animation_duration
		)
		_dice_position_tweens.append(position_tween)
		# Compute dice "camera look at" transform
		var dice_result_transform = _get_dice_result_transform(i, dice_result_positions)
		# Animate final rotation
		var rotation_tween = _physical_dices[i].create_tween()
		rotation_tween.tween_interval(result_rotation_delay)
		rotation_tween.tween_callback(_stop_dices_animated_angular_velocity)
		rotation_tween.tween_property(
			_physical_dices[i],
			"quaternion",
			dice_result_transform.basis.get_rotation_quaternion(),
			result_rotation_duration
		)
		rotation_tween.tween_callback(func():
			_animating = false
			animation_ended.emit()
			)
		_dice_rotation_tweens.append(rotation_tween)

	# Animate camera
	_camera_animation = camera.create_tween()
	(
		_camera_animation
		. tween_property(camera, "position", camera_result_position, result_animation_duration)
		. set_trans(Tween.TRANS_SPRING)
	)


func _skip_animation():
	# Reset everythig
	_reset()
	# Disable physics
	_freeze_dices()
	# Position camera
	camera.position = camera_result_position
	# Position and rotate dices
	var dice_result_positions = _get_dice_result_positions()
	for i in _physical_dices.size():
		_physical_dices[i].transform = _get_dice_result_transform(i, dice_result_positions)
	# End animation
	_animating = false
	animation_ended.emit()


func _get_dice_result_positions() -> Array[Vector3]:
	# Initialize variables for computation
	var dice_result_positions: Array[Vector3] = []
	var unpositioned_dices = _physical_dices.size()
	var next_row_transform = Transform3D(result_origin.global_transform)
	# Center vertical layouts
	var dice_rows = (
		_physical_dices.size() / result_max_row_elements
		+ (1 if _physical_dices.size() % result_max_row_elements != 0 else 0)
	)
	var centering_offset = (dice_rows - 1) * result_layout.spacing / 2
	next_row_transform.origin += (result_origin.global_transform.basis.y * centering_offset)

	# Compute positions
	while unpositioned_dices != 0:
		var row_positions
		# Full row
		if unpositioned_dices > result_max_row_elements:
			# Compute row positions
			row_positions = Layouts3D.get_horizontal_layout(
				next_row_transform, result_max_row_elements, result_layout
			)
			# Progress variables
			unpositioned_dices -= result_max_row_elements
			next_row_transform.origin += (
				-result_origin.global_transform.basis.y * result_layout.spacing
			)
		# Uncomplete row
		else:
			# Compute last row positions
			row_positions = Layouts3D.get_horizontal_layout(
				next_row_transform, unpositioned_dices, result_layout
			)
			unpositioned_dices = 0

		# Add new positions
		dice_result_positions.append_array(row_positions)

	return dice_result_positions


func _get_dice_result_transform(dice_index: int, dice_positions: Array[Vector3]):
	# Compute dice result local transform
	var dice_result_local_rotation = _physical_dices[dice_index].result_rotations[
		dice_roll_result.result[dice_index].dice_result
	]
	var dice_result_local_basis = Basis.from_euler(
		dice_result_local_rotation * PI / 180.0, EULER_ORDER_XYZ
	)
	var dice_result_local_transform = Transform3D(dice_result_local_basis, Vector3.ZERO)

	# Create "LOOK_IN_CAMERA_DIRECTION" transform
	var dice_result_layout_transform = Transform3D(camera.basis, dice_positions[dice_index])

	# Override if result_orientation is "LOOK_AT_CAMERA"
	if result_orientation == ResultOrientation.LOOK_AT_CAMERA:
		dice_result_layout_transform = dice_result_layout_transform.looking_at(
			camera_result_position, camera.basis.y, true
		)

	# Add transforms for final rotation
	return dice_result_layout_transform * dice_result_local_transform


func _stop_dices_animated_angular_velocity():
	for i in _physical_dices.size():
		_physical_dices[i].animated_angular_velocity = Vector3.ZERO


func _freeze_dices():
	for physical_dice in _physical_dices:
		physical_dice.freeze = true
