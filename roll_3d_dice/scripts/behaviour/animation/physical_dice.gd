class_name PhysicalDice
extends RigidBody3D

# Public variables
@export_group("Physics")
@export var static_body_bounce_force: float
@export_group("Results")
@export var result_rotations: Dictionary = {
	1: Vector3.ZERO,
	2: Vector3.ZERO,
	3: Vector3.ZERO,
	4: Vector3.ZERO,
	5: Vector3.ZERO,
	6: Vector3.ZERO,
}
@export_group("SoundFX")
@export var max_sound_effect_cadence: float
@export var audio_stream_player: AudioStreamPlayer
@export var dice_on_dice_sound_fxs: Array[AudioStream]
@export var dice_on_wall_sound_fxs: Array[AudioStream]

var animated_angular_velocity = Vector3.ZERO

# Private variables
var _can_play_sound_fx = true


# Engine methods
func _process(delta):
	if animated_angular_velocity != Vector3.ZERO:
		rotation_degrees += animated_angular_velocity * delta


func _integrate_forces(state):
	_bounce_off_walls(state)


# Private methods
func _bounce_off_walls(state):
	# Iterate collisions
	for i in state.get_contact_count():
		# Collided with PhysicalDiceBounceWall
		if state.get_contact_collider_object(i) is PhysicalDiceBounceWall:
			# Bounce
			state.apply_central_impulse(
				state.get_contact_local_normal(i) * static_body_bounce_force
			)
			# Play sound
			_play_random_sound_fx(dice_on_wall_sound_fxs)
		# Collided with dice
		else:
			# Play sound
			_play_random_sound_fx(dice_on_dice_sound_fxs)


func _play_random_sound_fx(sound_fxs: Array[AudioStream]):
	# Abort if sound fx can't be played
	if !_can_play_sound_fx:
		return
	# Play audio
	audio_stream_player.stream = sound_fxs[randi_range(0, sound_fxs.size() - 1)]
	audio_stream_player.play()
	# Manage SoundFX cadence
	_can_play_sound_fx = false
	await get_tree().create_timer(max_sound_effect_cadence).timeout
	_can_play_sound_fx = true
