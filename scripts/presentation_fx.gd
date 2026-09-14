class_name PresentationFX
extends Node3D

var camera: Camera3D
var base_camera_position := Vector3.ZERO
var trauma := 0.0
var trauma_decay := 1.8

func configure_camera(target_camera: Camera3D) -> void:
	camera = target_camera
	base_camera_position = camera.position

func add_camera_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if not is_instance_valid(camera):
		return
	trauma = maxf(0.0, trauma - trauma_decay * delta)
	var strength := trauma * trauma
	var shake := Vector3(
		randf_range(-0.08, 0.08) * strength,
		randf_range(-0.05, 0.05) * strength,
		0.0
	)
	camera.position = base_camera_position + shake

func muzzle_flash(world_position: Vector3) -> void:
	_spawn_flash(world_position, Color(1.0, 0.62, 0.22), 5.2, 2.6, 0.055)

func impact(world_position: Vector3, enemy_hit: bool) -> void:
	var color := Color(0.88, 0.10, 0.055) if enemy_hit else Color(1.0, 0.72, 0.30)
	var energy := 2.8 if enemy_hit else 1.8
	_spawn_flash(world_position, color, energy, 1.35, 0.10)

func death_burst(world_position: Vector3) -> void:
	_spawn_flash(world_position, Color(0.72, 0.055, 0.035), 4.0, 2.1, 0.16)

func _spawn_flash(world_position: Vector3, color: Color, energy: float, radius: float, lifetime: float) -> void:
	var root := Node3D.new()
	root.global_position = world_position
	add_child(root)

	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	light.shadow_enabled = false
	root.add_child(light)

	var marker := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.07
	mesh.height = 0.14
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 4.0
	mesh.material = material
	marker.mesh = mesh
	root.add_child(marker)

	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(root):
		root.queue_free()
