extends ProgramState


signal is_initialized


const image_loader: PackedScene = preload("res://src/scenes/main/image_loader.tscn")
const image_window: PackedScene = preload("res://src/scenes/main/image.tscn")


var is_image_loaded: bool = false


func _ready() -> void:
	program.image_closed.connect(_on_program_image_closed)


func enter(_msg := {}) -> void:
	############################################################################
	if Globals.PRINT_DEBUGGING:
		print("Paused program state")
	############################################################################

	get_tree().paused = true
	

func update(_delta: float) -> void:
	pass


func exit() -> void:
	pass


func _init_simulation() -> void:
	if is_image_loaded:
		if Globals.PRINT_DEBUGGING:
			print("Simulation initialized")
		
		is_initialized.emit()


func _on_UI_init_simulation() -> void:
	_init_simulation()
	

func _on_UI_start_simulation() -> void:
	state_machine.transition_to("Running")
	

func _on_UI_image_dropped(path_to_image) -> void:
	_load_image(path_to_image)

	
func _on_UI_launch_image_loader() -> void:
	var img_loader_instance = image_loader.instantiate() as FileDialog
	img_loader_instance.file_selected.connect(_load_image)
	program.add_child(img_loader_instance)
	

func _on_program_image_closed() -> void:
	is_image_loaded = false
	
	
func _load_image(path_to_image: String) -> void:
	if Globals.PRINT_DEBUGGING:
		print(path_to_image)
		
	# take care of the previously loaded image (if any) before loading a new one
	if is_image_loaded:
		image.queue_free()
		is_image_loaded = false
		
	# instantiate a new image window
	image = image_window.instantiate() as Window
	
	# connect image window signal(s) to the main program
	image.tree_exited.connect(program._on_image_tree_exited)
	state_machine.transitioned.connect(image._on_state_machine_transitioned)
	
	# load an image & image texture into the image window & texture rect
	image.initialize(path_to_image)
	
	program.add_child(image)
	is_image_loaded = true


