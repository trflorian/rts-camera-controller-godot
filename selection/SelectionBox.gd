extends Panel

const MIN_BOX_SIZE: int = 100

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var mouse_dragging: bool
var select_units: bool
var mouse_start_pos: Vector2
var mouse_end_pos: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("unit_select"):
		if event.is_pressed():
			mouse_dragging = true
			mouse_start_pos = get_global_mouse_position()
		elif event.is_released():
			mouse_dragging = false
			mouse_end_pos = get_global_mouse_position()
			select_units = true

func _process(delta: float) -> void:
	if mouse_dragging:
		var rect = _get_selection_rect(get_global_mouse_position())
		position = rect.position
		size = rect.size
	
	visible = mouse_dragging
	
func _get_selection_rect(end_pos: Vector2) -> Rect2:
	var box_size = end_pos - mouse_start_pos
	
	# convert to positive sized rectangle
	return Rect2(mouse_start_pos, box_size).abs()

func _physics_process(delta: float) -> void:
	if select_units:
		var rect = _get_selection_rect(mouse_end_pos)
		_select_units_in_box(rect)
		select_units = false

func _select_units_in_box(rect: Rect2):
	# prevent short clicks that deselect units
	if rect.size.length() < MIN_BOX_SIZE:
		return
	var units = get_tree().get_nodes_in_group("units")
	var selected_units: Array[Unit] = []
	for unit in units:
		var screen_pos = camera.unproject_position(unit.global_position)
		if rect.has_point(screen_pos):
			selected_units.append(unit)
	SelectionEvents.on_request_selection.emit(selected_units)
