class_name HorizontalLayout3DParameters
extends Resource

@export var element_width : float
@export var spacing : float
	
func _init(_element_width : float = 0,
	_spacing : float = 0):
		element_width = _element_width
		spacing = _spacing

static func create_copy(source : HorizontalLayout3DParameters):
	return HorizontalLayout3DParameters.new(source.element_width,
		source.spacing)
