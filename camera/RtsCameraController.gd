extends Node3D

class_name RtsCameraController

const RAY_DISTANCE: float = 100

@export var camera_move_speed: float = 10
@export var camera_rotate_speed: float = 2

@export var camera_zoom_speed: float = 10

@export var camera_zoom_steps: int = 5

@export var camera_zoom_min: float = 5
@export var camera_zoom_max: float = 10

@onready var camera = %MainCamera
@onready var camera_zoom_target: float = inverse_lerp(camera_zoom_min, camera_zoom_max, camera.position.z) * camera_zoom_steps

func _process(delta: float) -> void:
	_move(delta)
	_rotate(delta)
	_zoom(delta)
	
func _move(delta: float) -> void:
	var move_delta_z = Input.get_axis("camera_move_forward", "camera_move_backward")
	var move_delta_x = Input.get_axis("camera_move_left", "camera_move_right")
	var move_delta = transform.basis.z * move_delta_z + transform.basis.x * move_delta_x
	
	global_position += move_delta * delta * camera_move_speed

func _rotate(delta: float) -> void:
	var rotation_delta = Input.get_axis("camera_rotate_left", "camera_rotate_right")
	
	rotate_y(rotation_delta * delta * camera_rotate_speed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		camera_zoom_target -= 1
	if event.is_action_pressed("camera_zoom_out"):
		camera_zoom_target += 1
	camera_zoom_target = clamp(camera_zoom_target, 0, camera_zoom_steps)

func _zoom(delta: float) -> void:
	var zoom_dist = lerpf(camera_zoom_min, camera_zoom_max, camera_zoom_target / camera_zoom_steps)
	camera.position.z = lerpf(camera.position.z, zoom_dist, delta * camera_zoom_speed)
	
func raycast_from_camera() -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var rayOrigin = camera.project_ray_origin(mouse_position)
	var rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * RAY_DISTANCE
	var params = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	return space_state.intersect_ray(params)
