class_name CircularLayout3DParameters
extends Resource

@export var splits : int
@export var ring_radius : float
@export var central_element : bool
	
func _init(_splits : int = 0,
	_ring_radius : float = 0,
	_central_element : bool = false):
		splits = _splits
		ring_radius = _ring_radius
		central_element = _central_element
