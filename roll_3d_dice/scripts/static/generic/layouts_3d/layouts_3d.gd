class_name Layouts3D

# TODO: Allow definition of a relative plane for the layouts to be build


static func get_circular_layout(
	transform: Transform3D,
	element_count: int,
	circular_layout_parameters: CircularLayout3DParameters
):
	# Initialize return value
	var positions = []

	# Compute parameters
	var split_angle = PI * 2 / circular_layout_parameters.splits

	# Initialize variables
	var level = 0 if circular_layout_parameters.central_element else 1
	var split = 0

	# Iterate elements
	for i in element_count:
		# Compute position
		var layout_position = transform.origin
		if level != 0:
			# Compute offset direction based on angle
			var current_split_angle = split * split_angle
			var offset = (
				transform.basis.x * cos(current_split_angle)
				+ transform.basis.y * sin(current_split_angle)
			)
			# Resize based on level and radious
			offset = offset.normalized() * level * circular_layout_parameters.ring_radius
			# Apply to dice
			layout_position += offset

			# Increase split index
			split += 1
			# Reset variables for next ring when circle is complete
			if split == circular_layout_parameters.splits:
				split = 0
				level += 1
		# Skip first circle level
		else:
			level += 1

		# Add position to return value
		positions.append(layout_position)

	return positions


static func get_horizontal_layout(
	transform: Transform3D,
	element_count: int,
	horizontal_layout_parameters: HorizontalLayout3DParameters
):
	# Initialize return value
	var positions = []

	# Compute parameters
	var total_length = (
		element_count * horizontal_layout_parameters.element_width
		+ horizontal_layout_parameters.spacing * (element_count - 1)
	)
	var initial_position = transform.origin - transform.basis.x * total_length / 2

	# Iterate elements in layout
	for i in element_count:
		# Compute position
		var position = initial_position
		position += (horizontal_layout_parameters.element_width / 2) * transform.basis.x
		position += (
			(horizontal_layout_parameters.element_width + horizontal_layout_parameters.spacing)
			* transform.basis.x
			* i
		)

		# Add as return value
		positions.append(position)

	return positions
