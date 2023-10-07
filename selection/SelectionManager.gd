extends Node

@onready var camera_controller: RtsCameraController = get_tree().get_first_node_in_group('camera_controller')

var highlighted_unit: Unit = null
var selected_units: Array[Unit] = []

func _ready():
	SelectionEvents.on_request_selection.connect(_handle_selection_request)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("unit_select"):
		_on_unit_select()

func _physics_process(delta: float) -> void:
	_update_highlight_unit()

func _update_highlight_unit():
	var target = camera_controller.raycast_from_camera()
	var new_highlighted_unit = null
	if not target.is_empty() and target.collider is Unit:
		new_highlighted_unit = target.collider
		
	if new_highlighted_unit != highlighted_unit:
		highlighted_unit = new_highlighted_unit
		SelectionEvents.on_highlight_changed.emit(highlighted_unit)

func _on_unit_select():
	var emit_selection_update = false
	
	if not Input.is_action_pressed("unit_select_multiple"):
		if not selected_units.is_empty():
			selected_units.clear()
			emit_selection_update = true
	
	if highlighted_unit != null and highlighted_unit not in selected_units:
		selected_units.push_back(highlighted_unit)
		emit_selection_update = true
	
	if emit_selection_update:
		SelectionEvents.on_selection_changed.emit(selected_units)

func _handle_selection_request(units: Array[Unit]):
	if Input.is_action_pressed("unit_select_multiple"):
		for u in units:
			if u not in selected_units:
				selected_units.append(u)
	else:
		selected_units.clear()
		selected_units.append_array(units)
	SelectionEvents.on_selection_changed.emit(selected_units)
