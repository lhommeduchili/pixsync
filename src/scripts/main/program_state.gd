class_name ProgramState
extends State


var image: Window


@onready var program: Node = owner


func _on_UI_quit_program() -> void:
	if image != null:
		image.queue_free()
	get_tree().quit()
