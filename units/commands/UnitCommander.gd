extends Node

@onready var camera_controller: RtsCameraController = get_tree().get_first_node_in_group('camera_controller')

var selected_units: Array[Unit] = []

func _ready() -> void:
	SelectionEvents.on_selection_changed.connect(_on_selection_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("unit_command"):
		_on_command_selected_units()

func _on_selection_changed(new_selection: Array[Unit]):
	selected_units = new_selection

func _on_command_selected_units() -> void:
	if selected_units.is_empty():
		return
	
	var target_intersection = camera_controller.raycast_from_camera()
	if target_intersection.is_empty():
		print("No target found to command units")
		return
	
	_on_handle_units_command(selected_units, target_intersection.collider, 
		target_intersection.position)
		
func _on_handle_units_command(units: Array[Unit], target_obj: Node3D, target_pos: Vector3) -> void:
	if target_obj.is_in_group("terrain"):
		_handle_move_command(units, target_pos)
	elif target_obj.is_in_group("units"):
		_handle_attack_command(units, target_obj)
		
func _handle_move_command(units: Array[Unit], target_pos: Vector3) -> void:
	var cmd = UnitCommand.new(UnitCommand.Type.MOVE, target_pos, null)
	for unit in units:
		unit.set_command(cmd)
	UnitEvents.on_command_units.emit(units, cmd)

func _handle_attack_command(units: Array[Unit], target_obj: Node3D) -> void:
	var cmd = UnitCommand.new(UnitCommand.Type.ATTACK, target_obj.global_position, target_obj)
	for unit in units:
		unit.set_command(cmd)
	UnitEvents.on_command_units.emit(units, cmd)
