"""
to do: implement window's dragging capaibility so the user can move the window
around with the mouse. Research window_input(InputEvent event) fx.
"""

extends Window


@export var image_texture_rect_path: NodePath

var is_running: bool = false

var image: Image 
var image_texture: ImageTexture
var x_size: int
var y_size: int
var rng: RandomNumberGenerator


func _ready() -> void:
	rng = RandomNumberGenerator.new()
	
	
func _process(_delta: float) -> void:
	if is_running:
		_update_simulation()
	

func _get_neighborhood(x_coordinate: int, y_coordinate: int, r: int) -> Array:
	var neighbor_color: Color
	var neighbor_state: Vector4
	var neighbors: Array = []
	
	# we iterate over a square of r^2 sites centered at (i, j) = (0,0)
	for i in range(-r, r + 1):
		for j in range(-r, r + 1):
			# we skip the focal site at the origin
			if (i == 0 && j == 0): continue
			# we also skip sites that beyond (|i|+|j|) = r in order to match 
			# von Neumann's neighborhood connectivity
			elif (abs(i) + abs(j) > r): continue
			
			neighbor_color = image.get_pixel((x_size + x_coordinate + i) % x_size,
											 (y_size + y_coordinate + j) % y_size)
			neighbor_state = Vector4(neighbor_color.r, 
									 neighbor_color.g, 
									 neighbor_color.b, 
									 neighbor_color.a)
			neighbors.append(neighbor_state)
	return neighbors
	

func _compute_energy(state: Vector4, neighborhood: Array) -> float:
	var spin_product_sum: float = 0
	for neighbor_state in neighborhood:
		spin_product_sum += state.dot(neighbor_state)
	var state_energy: float = Globals.COUPLING * spin_product_sum
	return state_energy


func _update_simulation() -> void:
	var random_x_coordinate: int
	var random_y_coordinate: int
	var focal_site_color: Color
	var focal_site_state: Vector4
	var perturbed_focal_site_color: Color
	var perturbed_focal_site_state: Vector4
	var neighborhood: Array
	
	var current_state_energy: float
	var proposal_state_energy: float
	var transition_energy: float
	var transition_probability: float
	
	for site: int in (x_size * y_size):
		# pick a random focal pixel
		random_x_coordinate = rng.randi_range(0, x_size - 1)
		random_y_coordinate = rng.randi_range(0, y_size - 1)

		# compute focal's point transition energy using some kind of
		# Vicsek model's alignment rule
		focal_site_color = image.get_pixel(random_x_coordinate, random_y_coordinate)
		focal_site_state = Vector4(focal_site_color.r, 
								   focal_site_color.g, 
								   focal_site_color.b, 
								   focal_site_color.a)
		
		perturbed_focal_site_state = Vector4(focal_site_color.r + rng.randfn(focal_site_color.r, 0.1), 
											 focal_site_color.g + rng.randfn(focal_site_color.r, 0.1), 
											 focal_site_color.b + rng.randfn(focal_site_color.r, 0.1), 
											 focal_site_color.a + rng.randfn(focal_site_color.r, 0.1))

		neighborhood = _get_neighborhood(random_x_coordinate, random_y_coordinate, 
										 Globals.MANHATTAN_DISTANCE)
		
		current_state_energy = _compute_energy(focal_site_state, neighborhood)
		proposal_state_energy = _compute_energy(perturbed_focal_site_state, neighborhood)
		transition_energy = proposal_state_energy - current_state_energy
		transition_probability = exp(-transition_energy/Globals.TEMPERATURE)
		
		if transition_energy < 0 || rng.randf() < transition_probability:
			perturbed_focal_site_color = Color(perturbed_focal_site_state[0],
											   perturbed_focal_site_state[1],
											   perturbed_focal_site_state[2],
											   perturbed_focal_site_state[3])
			image.set_pixel(random_x_coordinate, random_y_coordinate,
							perturbed_focal_site_color)
		
	image_texture.update(image)
	
	
func _on_state_machine_transitioned(state: String) -> void:
	match state:
		"Paused": 
			is_running = false
		"Running":
			is_running = true


func initialize(path_to_image: String) -> void:
	if Globals.PRINT_DEBUGGING:
		print(path_to_image)
	
	image = Image.load_from_file(path_to_image)
	x_size = image.get_width()
	y_size = image.get_height()
	
	image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	var image_texture_rect = get_node(image_texture_rect_path) as TextureRect
	image_texture_rect.texture = image_texture

	
