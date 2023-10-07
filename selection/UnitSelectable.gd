extends Node3D

var is_highlighted: bool = false
var is_selected: bool = false

@export var default_color: Color
@export var highlighted_color: Color
@export var selected_color: Color

@onready var mesh: MeshInstance3D = %CapsuleMesh
var material: StandardMaterial3D

func _ready() -> void:
	# make material unique
	material = mesh.get_active_material(0).duplicate(true)
	mesh.set_surface_override_material(0, material)
	
	SelectionEvents.on_highlight_changed.connect(check_highlighted)
	SelectionEvents.on_selection_changed.connect(check_selected)

func check_highlighted(unit: Unit):
	is_highlighted = unit == owner
	_update_material_color()
	
func check_selected(units: Array[Unit]):
	is_selected = owner in units
	_update_material_color()
	
func _update_material_color():
	match [is_highlighted, is_selected]:
		[_, true]:
			material.albedo_color = selected_color
		[true, false]:
			material.albedo_color = highlighted_color
		[_, _]:
			material.albedo_color = default_color
