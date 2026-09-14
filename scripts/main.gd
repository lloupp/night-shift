extends Node3D

const PlayerClass = preload("res://scripts/player.gd")
const EnemyClass = preload("res://scripts/enemy.gd")
const DoorClass = preload("res://scripts/door.gd")
const AmmoClass = preload("res://scripts/ammo_pickup.gd")

var player: SurvivorPlayer
var camera_pivot: Node3D
var camera: Camera3D
var camera_step := 0
var camera_target_angle := 0.0
var status_label: Label
var prompt_label: Label
var message_label: Label
var crosshair: Label
var message_timer := 0.0
var current_interactable: Node
var pending_shot := false

func _ready() -> void:
	_build_environment()
	_build_level()
	_spawn_player()
	_spawn_gameplay_objects()
	_build_camera()
	_build_ui()
	player.stats_changed.connect(_update_status)
	player.died.connect(_on_player_died)
	_update_status()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	camera_pivot.global_position = player.global_position + Vector3(0, 0.7, 0)
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, camera_target_angle, clampf(delta * 7.0, 0.0, 1.0))
	player.set_camera_basis(camera.global_transform.basis)
	_update_aim()
	_update_interaction_prompt()
	if pending_shot:
		pending_shot = false
		_fire()
	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0:
			message_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(player):
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_Q:
				_rotate_camera(-1)
			KEY_E:
				_rotate_camera(1)
			KEY_F:
				_interact()
			KEY_R:
				player.reload()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			player.aiming = event.pressed
			crosshair.visible = player.aiming
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pending_shot = true

func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.018, 0.022, 0.026)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.17, 0.20, 0.22)
	env.ambient_light_energy = 0.42
	env.fog_enabled = true
	env.fog_light_color = Color(0.07, 0.08, 0.09)
	env.fog_density = 0.025
	env.fog_height = 3.5
	env.fog_height_density = 0.18
	world_environment.environment = env
	add_child(world_environment)

	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-52, -34, 0)
	moon.light_color = Color(0.54, 0.62, 0.72)
	moon.light_energy = 0.48
	moon.shadow_enabled = true
	add_child(moon)

func _build_level() -> void:
	_add_static_box("Ground", Vector3(18, 0.22, 18), Vector3(0, -0.11, 0), Color(0.11, 0.12, 0.12))
	_add_static_box("NorthWall", Vector3(18, 2.8, 0.35), Vector3(0, 1.4, -9), Color(0.17, 0.18, 0.17))
	_add_static_box("SouthWall", Vector3(18, 2.8, 0.35), Vector3(0, 1.4, 9), Color(0.17, 0.18, 0.17))
	_add_static_box("WestWall", Vector3(0.35, 2.8, 18), Vector3(-9, 1.4, 0), Color(0.17, 0.18, 0.17))
	_add_static_box("EastWall", Vector3(0.35, 2.8, 18), Vector3(9, 1.4, 0), Color(0.17, 0.18, 0.17))
	_add_static_box("PartitionA", Vector3(7.0, 2.8, 0.28), Vector3(-5.5, 1.4, 1.5), Color(0.22, 0.20, 0.18))
	_add_static_box("PartitionB", Vector3(4.0, 2.8, 0.28), Vector3(6.5, 1.4, 1.5), Color(0.22, 0.20, 0.18))
	_add_static_box("RoomWall", Vector3(0.28, 2.8, 5.5), Vector3(3.1, 1.4, 6.2), Color(0.20, 0.20, 0.18))
	_add_static_box("Counter", Vector3(3.2, 0.95, 0.7), Vector3(-4.2, 0.475, -3.0), Color(0.22, 0.16, 0.11))
	_add_static_box("Crate", Vector3(1.0, 1.0, 1.0), Vector3(5.5, 0.5, -4.0), Color(0.25, 0.18, 0.10))
	_add_lamp(Vector3(-5.6, 2.45, -4.7), Color(1.0, 0.64, 0.36), 4.0)
	_add_lamp(Vector3(5.4, 2.45, 5.7), Color(0.45, 0.65, 1.0), 2.6)
	_add_lamp(Vector3(0.0, 2.6, -0.5), Color(0.82, 0.52, 0.28), 2.0)

func _spawn_player() -> void:
	player = PlayerClass.new()
	player.name = "Player"
	player.position = Vector3(0, 0.05, 5.5)
	add_child(player)

func _spawn_gameplay_objects() -> void:
	var door: PrototypeDoor = DoorClass.new()
	door.name = "Door"
	door.position = Vector3(-1.25, 0, 1.5)
	add_child(door)

	var ammo: AmmoPickup = AmmoClass.new()
	ammo.name = "AmmoPickup"
	ammo.position = Vector3(-4.0, 0.05, -2.2)
	add_child(ammo)

	for spawn_position in [Vector3(5.8, 0.05, -5.5), Vector3(-6.3, 0.05, 5.8)]:
		var enemy: StalkerEnemy = EnemyClass.new()
		enemy.name = "Stalker"
		enemy.position = spawn_position
		enemy.target = player
		add_child(enemy)

func _build_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.name = "Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 10.5
	camera_pivot.add_child(camera)
	camera.position = Vector3(0, 8.2, 9.2)
	camera.look_at(Vector3(0, 0.5, 0), Vector3.UP)
	camera.current = true

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.name = "HUD"
	add_child(ui)
	status_label = Label.new()
	status_label.position = Vector2(10, 8)
	status_label.add_theme_font_size_override("font_size", 13)
	ui.add_child(status_label)
	prompt_label = Label.new()
	prompt_label.position = Vector2(172, 224)
	prompt_label.size = Vector2(136, 22)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 12)
	ui.add_child(prompt_label)
	message_label = Label.new()
	message_label.position = Vector2(120, 36)
	message_label.size = Vector2(240, 24)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 12)
	ui.add_child(message_label)
	var controls := Label.new()
	controls.text = "WASD mover  SHIFT correr  Q/E câmera  RMB mirar  LMB atirar  R recarregar  F interagir"
	controls.position = Vector2(10, 250)
	controls.add_theme_font_size_override("font_size", 9)
	ui.add_child(controls)
	crosshair = Label.new()
	crosshair.text = "+"
	crosshair.visible = false
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair.add_theme_font_size_override("font_size", 16)
	ui.add_child(crosshair)

func _add_static_box(node_name: String, size: Vector3, position: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.collision_layer = 1
	body.position = position
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	var box := BoxMesh.new()
	box.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.98
	box.material = mat
	var visual := MeshInstance3D.new()
	visual.mesh = box
	body.add_child(visual)
	add_child(body)

func _add_lamp(position: Vector3, color: Color, energy: float) -> void:
	var lamp := OmniLight3D.new()
	lamp.position = position
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = 6.0
	lamp.shadow_enabled = true
	add_child(lamp)
	var fixture := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.08
	mesh.height = 0.16
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 3.0
	mesh.material = mat
	fixture.mesh = mesh
	fixture.position = position
	add_child(fixture)

func _rotate_camera(direction: int) -> void:
	camera_step = (camera_step + direction + 8) % 8
	camera_target_angle = deg_to_rad(camera_step * 45.0)

func _update_aim() -> void:
	if not player.aiming:
		return
	var mouse := get_viewport().get_mouse_position()
	crosshair.position = mouse - Vector2(6, 11)
	var hit := _mouse_raycast()
	if not hit.is_empty():
		player.aim_point = hit.position

func _mouse_raycast() -> Dictionary:
	var mouse := get_viewport().get_mouse_position()
	var origin := camera.project_ray_origin(mouse)
	var direction := camera.project_ray_normal(mouse)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 100.0)
	query.exclude = [player.get_rid()]
	query.collision_mask = 1 | 4 | 8
	return get_world_3d().direct_space_state.intersect_ray(query)

func _fire() -> void:
	if not player.try_fire():
		if player.aiming and player.ammo == 0:
			_show_message("Sem munição — R para recarregar")
		return
	var hit := _mouse_raycast()
	if not hit.is_empty():
		var collider: Object = hit.collider
		if collider.has_method("take_damage"):
			collider.take_damage(1)

func _update_interaction_prompt() -> void:
	current_interactable = null
	var nearest_distance := 2.1
	for node in get_tree().get_nodes_in_group("interactable"):
		if not is_instance_valid(node) or not (node is Node3D):
			continue
		var node3d := node as Node3D
		var distance := player.global_position.distance_to(node3d.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			current_interactable = node3d
	if is_instance_valid(current_interactable):
		var label := "Interagir"
		if current_interactable.has_method("interaction_label"):
			label = current_interactable.interaction_label()
		prompt_label.text = "[F] " + label
	else:
		prompt_label.text = ""

func _interact() -> void:
	if not is_instance_valid(current_interactable):
		return
	if current_interactable.has_method("interact"):
		var result = current_interactable.interact(player)
		if result is String and not result.is_empty():
			_show_message(result)

func _update_status() -> void:
	if not is_instance_valid(player):
		return
	var reload_text := "  RECARREGANDO" if player.reloading else ""
	status_label.text = "VIDA %03d   MUNIÇÃO %d/%d%s" % [player.health, player.ammo, player.reserve_ammo, reload_text]

func _show_message(text: String) -> void:
	message_label.text = text
	message_timer = 1.6

func _on_player_died() -> void:
	player.set_physics_process(false)
	_show_message("VOCÊ NÃO SOBREVIVEU — reinicie a cena")
