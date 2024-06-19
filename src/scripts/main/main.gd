extends Node


signal image_closed


func _on_image_tree_exited() -> void:
	image_closed.emit()
	
