class_name CustomMesh
extends MeshInstance3D

# Public variables
@export var verts: PackedVector3Array
@export var uvs: PackedVector2Array
@export var normals: PackedVector3Array
@export var indices: PackedInt32Array
@export var material: Material
@export var enable_simple_model_viewer: bool = false


# Engine methods
func _ready():
	# Create arrays
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(0, material)


func _process(delta):
	if !enable_simple_model_viewer:
		return

	if Input.is_key_label_pressed(KEY_RIGHT):
		rotate(Vector3.UP, 1 * delta)
	if Input.is_key_label_pressed(KEY_LEFT):
		rotate(Vector3.UP, -1 * delta)
	if Input.is_key_label_pressed(KEY_UP):
		rotate(Vector3.RIGHT, -1 * delta)
	if Input.is_key_label_pressed(KEY_DOWN):
		rotate(Vector3.RIGHT, 1 * delta)
