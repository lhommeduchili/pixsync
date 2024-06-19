extends ProgramState


func _ready() -> void:
	program.image_closed.connect(_on_program_image_closed)
	

func enter(_msg := {}) -> void:
	############################################################################
	if Globals.PRINT_DEBUGGING:
		print("Running program state")
	############################################################################
	# unpause the process
	get_tree().paused = false
	# emit signal to the image window


func update(_delta: float) -> void:
	pass


func exit() -> void:
	pass


func _on_UI_stop_simulation() -> void:
	state_machine.transition_to("Paused")


func _on_program_image_closed() -> void:
	state_machine.transition_to("Paused")
