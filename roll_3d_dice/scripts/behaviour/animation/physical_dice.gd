class_name PhysicalDice
extends RigidBody3D

# Public variables
@export var static_body_bounce_force: float
@export var result_rotations: Dictionary = {
	1: Vector3.ZERO,
	2: Vector3.ZERO,
	3: Vector3.ZERO,
	4: Vector3.ZERO,
	5: Vector3.ZERO,
	6: Vector3.ZERO,
}

var animated_angular_velocity = Vector3.ZERO


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
		# Bounce of PhysicalDiceBounceWall objects
		if state.get_contact_collider_object(i) is PhysicalDiceBounceWall:
			state.apply_central_impulse(
				state.get_contact_local_normal(i) * static_body_bounce_force
			)
