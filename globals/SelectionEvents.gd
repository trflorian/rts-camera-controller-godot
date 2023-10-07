extends Node

signal on_highlight_changed(unit: Unit)
signal on_selection_changed(units: Array[Unit])

signal on_request_selection(units: Array[Unit])

func _ready():
	await get_tree().process_frame
	on_highlight_changed.emit(null)
	on_selection_changed.emit([])
