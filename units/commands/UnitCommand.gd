class_name UnitCommand

enum Type {	MOVE, ATTACK }

var type: Type

var target_pos: Vector3
var target_obj: Node3D

func _init(type: Type, target_pos: Vector3, target_obj: Node3D) -> void:
	self.type = type
	self.target_pos = target_pos
	self.target_obj = target_obj
