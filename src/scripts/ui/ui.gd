extends CanvasLayer


signal init_simulation
signal start_simulation
signal stop_simulation
signal quit_program
signal launch_image_loader
signal image_dropped(path_to_image: String)


@export var running_state_path: NodePath
@export var paused_state_path: NodePath

@export var initialize_button_path: NodePath
@export var start_button_path: NodePath
@export var stop_button_path: NodePath

@onready var running_state = get_node(running_state_path) as ProgramState
@onready var paused_state = get_node(paused_state_path) as ProgramState

@onready var initialize_button = get_node(initialize_button_path) as Button
@onready var start_button = get_node(start_button_path) as Button
@onready var stop_button = get_node(stop_button_path) as Button


# Called when the node enters the scene tree for the first time.
func _ready():
	# connect root's files dropped signal
	get_tree().get_root().files_dropped.connect(_on_files_dropped)
	
	# connect UI signals to the program states
	quit_program.connect(running_state._on_UI_quit_program)
	quit_program.connect(paused_state._on_UI_quit_program)
	
	image_dropped.connect(paused_state._on_UI_image_dropped)
	
	launch_image_loader.connect(paused_state._on_UI_launch_image_loader)
	
	init_simulation.connect(paused_state._on_UI_init_simulation)
	
	start_simulation.connect(paused_state._on_UI_start_simulation)
	
	stop_simulation.connect(running_state._on_UI_stop_simulation)
	
	# connect program states' init_simulation signal to UI 
	paused_state.is_initialized.connect(_on_paused_state_is_initialized)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass
	

func _on_files_dropped(files_list: PackedStringArray) -> void:
	# for now we take only the first file of the dropped files
	# without any filter (should add some afterwards)
	var path_to_file: String = files_list[0]
	image_dropped.emit(path_to_file)


func _on_initialize_pressed():
	init_simulation.emit()


func _on_start_pressed():
	initialize_button.disabled = true
	stop_button.disabled = false
	start_simulation.emit()


func _on_stop_pressed():
	initialize_button.disabled = false
	stop_button.disabled = true
	stop_simulation.emit()


func _on_quit_pressed():
	quit_program.emit()


func _on_paused_state_is_initialized() -> void:
	start_button.disabled = false
	

func _on_image_loader_button_pressed():
	launch_image_loader.emit()
