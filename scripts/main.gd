extends Node3D

const PlayerClass = preload("res://scripts/player.gd")
const EnemyClass = preload("res://scripts/enemy.gd")
const DoorClass = preload("res://scripts/door.gd")
const AmmoClass = preload("res://scripts/ammo_pickup.gd")
const PresentationFXClass = preload("res://scripts/presentation_fx.gd")

const CAMERA_DIRECTIONS := ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]

var player: SurvivorPlayer
var camera_pivot: Node3D
var camera: Camera3D
var fx: PresentationFX
var camera_step := 0
var camera_target_angle := 0.0
var camera_follow_position := Vector3.ZERO
var status_label: Label
var prompt_label: Label
var message_label: Label
var camera_angle_label: Label
var crosshair: Label
var damage_overlay: ColorRect
var message_timer := 0.0
var damage_flash := 0.0
var crosshair_feedback_timer := 0.0
var current_interactable: Node
var pending_shot := false
var occluded_bodies: Array[Node3D] = []
var flicker_lamps: Array[OmniLight3D] = []
var flicker_clock := 0.0

func _ready() -> void:
	_build_environment()
	_build_level()
	_spawn_player()
	_spawn_gameplay_objects()
	_build_camera()
	_build_presentation_fx()
	_build_ui()
	camera_follow_position = player.global_position + Vector3(0, 0.72, 0)
	player.stats_changed.connect(_update_status)
	player.damaged.connect(_on_player_damaged)
	player.died.connect(_on_player_died)
	_update_status()
	_update_camera_angle_label()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var desired_follow := player.global_position + Vector3(0, 0.72, 0)
	camera_follow_position = camera_follow_position.lerp(desired_follow, clampf(delta * 6.5, 0.0, 1.0))
	camera_pivot.global_position = camera_follow_position
	camera_pivot.rotation.y = lerp_angle(camera_pivot.rotation.y, camera_target_angle, clampf(delta * 7.0, 0.0, 1.0))
	player.set_camera_basis(camera.global_transform.basis)
	_update_camera_occlusion()
	_update_aim()
	_update_interaction_prompt()
	_update_lamp_flicker(delta)
	_update_damage_feedback(delta)
	_update_crosshair_feedback(delta)
	if pending_shot:
		pending_shot = false
		_fire()
	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0:
			message_label.text = ""

func _exit_tree() -> void:
	_restore_occluders()

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
	env.background_color = Color(0.012, 0.016, 0.021)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.14, 0.17, 0.20)
	env.ambient_light_energy = 0.36
	env.fog_enabled = true
	env.fog_light_color = Color(0.055, 0.065, 0.078)
	env.fog_density = 0.032
	env.fog_height = 3.6
	env.fog_height_density = 0.22
	world_environment.environment = env
	add_child(world_environment)

	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-52, -34, 0)
	moon.light_color = Color(0.48, 0.58, 0.72)
	moon.light_energy = 0.42
	moon.shadow_enabled = true
	add_child(moon)

func _build_level() -> void:
	_add_static_box("Ground", Vector3(24, 0.22, 20), Vector3(0, -0.11, 0), Color(0.075, 0.08, 0.082), false)
	_add_decor_box("Road", Vector3(8.4, 0.035, 19.0), Vector3(0, 0.018, 0), Color(0.055, 0.058, 0.06))
	_add_decor_box("WestWalk", Vector3(5.8, 0.055, 19.0), Vector3(-7.1, 0.028, 0), Color(0.13, 0.13, 0.125))
	_add_decor_box("EastWalk", Vector3(5.8, 0.055, 19.0), Vector3(7.1, 0.028, 0), Color(0.13, 0.13, 0.125))
	_add_decor_box("RoadStripeA", Vector3(0.12, 0.045, 2.1), Vector3(0, 0.045, -5.5), Color(0.42, 0.37, 0.22))
	_add_decor_box("RoadStripeB", Vector3(0.12, 0.045, 2.1), Vector3(0, 0.045, 0.0), Color(0.42, 0.37, 0.22))
	_add_decor_box("RoadStripeC", Vector3(0.12, 0.045, 2.1), Vector3(0, 0.045, 5.5), Color(0.42, 0.37, 0.22))

	_add_static_box("NorthWall", Vector3(24, 3.2, 0.35), Vector3(0, 1.6, -10), Color(0.13, 0.14, 0.14))
	_add_static_box("SouthWall", Vector3(24, 3.2, 0.35), Vector3(0, 1.6, 10), Color(0.13, 0.14, 0.14))
	_add_static_box("WestWall", Vector3(0.35, 3.2, 20), Vector3(-12, 1.6, 0), Color(0.13, 0.14, 0.14))
	_add_static_box("EastWall", Vector3(0.35, 3.2, 20), Vector3(12, 1.6, 0), Color(0.13, 0.14, 0.14))

	_add_static_box("StorefrontWest", Vector3(4.8, 3.4, 0.30), Vector3(-7.5, 1.7, -4.6), Color(0.20, 0.18, 0.16))
	_add_static_box("StorefrontEast", Vector3(4.8, 3.4, 0.30), Vector3(7.5, 1.7, -4.6), Color(0.16, 0.18, 0.19))
	_add_static_box("ShopPartitionA", Vector3(5.8, 2.8, 0.28), Vector3(-6.4, 1.4, 1.6), Color(0.20, 0.18, 0.16))
	_add_static_box("ShopPartitionB", Vector3(3.4, 2.8, 0.28), Vector3(7.3, 1.4, 1.6), Color(0.17, 0.18, 0.18))
	_add_static_box("RoomWall", Vector3(0.28, 2.8, 5.8), Vector3(3.25, 1.4, 6.4), Color(0.18, 0.18, 0.17))
	_add_static_box("Counter", Vector3(3.2, 0.95, 0.7), Vector3(-6.0, 0.475, -2.3), Color(0.24, 0.16, 0.10), false)
	_add_static_box("Dumpster", Vector3(1.6, 1.15, 0.9), Vector3(8.2, 0.575, 5.9), Color(0.11, 0.18, 0.15), false)
	_add_static_box("CrateA", Vector3(1.0, 1.0, 1.0), Vector3(5.8, 0.5, -6.2), Color(0.24, 0.17, 0.09), false)
	_add_static_box("CrateB", Vector3(0.85, 0.75, 0.85), Vector3(6.8, 0.375, -6.0), Color(0.20, 0.14, 0.08), false)

	_add_decor_box("WestAwning", Vector3(4.2, 0.12, 1.1), Vector3(-7.2, 2.65, -4.05), Color(0.27, 0.09, 0.08))
	_add_decor_box("EastSign", Vector3(2.2, 0.18, 0.12), Vector3(7.4, 2.4, -4.35), Color(0.11, 0.34, 0.31))

	_add_lamp(Vector3(-5.6, 2.65, -1.6), Color(1.0, 0.58, 0.31), 4.2, true)
	_add_lamp(Vector3(5.6, 2.65, 4.8), Color(0.40, 0.62, 1.0), 2.8)
	_add_lamp(Vector3(0.0, 3.4, -5.8), Color(0.78, 0.48, 0.25), 2.2, true)
	_add_lamp(Vector3(-8.6, 2.8, 6.2), Color(0.72, 0.78, 0.68), 1.6)

func _spawn_player() -> void:
	player = PlayerClass.new()
	player.name = "Player"
	player.position = Vector3(0, 0.05, 6.4)
	add_child(player)

func _spawn_gameplay_objects() -> void:
	var door: PrototypeDoor = DoorClass.new()
	door.name = "Door"
	door.position = Vector3(-2.0, 0, 1.6)
	add_child(door)

	var ammo: AmmoPickup = AmmoClass.new()
	ammo.name = "AmmoPickup"
	ammo.position = Vector3(-6.0, 0.05, -1.5)
	add_child(ammo)

	for spawn_position in [Vector3(6.2, 0.05, -7.1), Vector3(-8.0, 0.05, 6.6)]:
		var enemy: StalkerEnemy = EnemyClass.new()
		enemy.name = "Stalker"
		enemy.position = spawn_position
		enemy.target = player
		enemy.died.connect(_on_enemy_died)
		add_child(enemy)

func _build_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.name = "Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 11.0
	camera_pivot.add_child(camera)
	camera.position = Vector3(0, 8.5, 9.4)
	camera.look_at(Vector3(0, 0.55, 0), Vector3.UP)
	camera.current = true

func _build_presentation_fx() -> void:
	fx = PresentationFXClass.new()
	fx.name = "PresentationFX"
	add_child(fx)
	fx.configure_camera(camera)

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.name = "HUD"
	add_child(ui)

	damage_overlay = ColorRect.new()
	damage_overlay.position = Vector2.ZERO
	damage_overlay.size = Vector2(480, 270)
	damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_overlay.color = Color(0.42, 0.01, 0.005, 0.0)
	ui.add_child(damage_overlay)

	status_label = Label.new()
	status_label.position = Vector2(10, 8)
	status_label.add_theme_font_size_override("font_size", 13)
	ui.add_child(status_label)

	camera_angle_label = Label.new()
	camera_angle_label.position = Vector2(418, 8)
	camera_angle_label.size = Vector2(52, 18)
	camera_angle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	camera_angle_label.add_theme_font_size_override("font_size", 10)
	ui.add_child(camera_angle_label)

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

func _add_static_box(node_name: String, size: Vector3, position: Vector3, color: Color, occludable: bool = true) -> void:
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
	visual.name = "Visual"
	visual.mesh = box
	body.add_child(visual)
	if occludable:
		body.add_to_group("camera_occluder")
	add_child(body)

func _add_decor_box(node_name: String, size: Vector3, position: Vector3, color: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	visual.position = position
	var box := BoxMesh.new()
	box.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.95
	box.material = mat
	visual.mesh = box
	add_child(visual)

func _add_lamp(position: Vector3, color: Color, energy: float, flicker: bool = false) -> void:
	var lamp := OmniLight3D.new()
	lamp.position = position
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = 6.2
	lamp.shadow_enabled = true
	lamp.set_meta("base_energy", energy)
	lamp.set_meta("flicker_phase", randf_range(0.0, 4.0))
	add_child(lamp)
	if flicker:
		flicker_lamps.append(lamp)

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
	_update_camera_angle_label()

func _update_camera_angle_label() -> void:
	if is_instance_valid(camera_angle_label):
		camera_angle_label.text = "CAM " + CAMERA_DIRECTIONS[camera_step]

func _restore_occluders() -> void:
	for body in occluded_bodies:
		if not is_instance_valid(body):
			continue
		var visual := body.get_node_or_null("Visual")
		if visual is GeometryInstance3D:
			visual.visible = true
	occluded_bodies.clear()

func _update_camera_occlusion() -> void:
	_restore_occluders()
	if not is_instance_valid(camera) or not is_instance_valid(player):
		return
	var origin := camera.global_position
	var target := player.global_position + Vector3(0, 1.0, 0)
	var excluded: Array[RID] = [player.get_rid()]
	for _index in range(6):
		var query := PhysicsRayQueryParameters3D.create(origin, target)
		query.collision_mask = 1
		query.exclude = excluded
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		if hit.is_empty():
			break
		var collider: Object = hit.collider
		if not (collider is StaticBody3D):
			break
		var body := collider as StaticBody3D
		excluded.append(body.get_rid())
		if not body.is_in_group("camera_occluder"):
			continue
		var visual := body.get_node_or_null("Visual")
		if visual is GeometryInstance3D:
			visual.visible = false
			occluded_bodies.append(body)

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

	if is_instance_valid(fx):
		fx.muzzle_flash(player.get_muzzle_position())
		fx.add_camera_trauma(0.16)
	crosshair.text = "×"
	crosshair.modulate = Color(1.0, 0.72, 0.34)
	crosshair_feedback_timer = 0.09

	var hit := _mouse_raycast()
	if not hit.is_empty():
		var collider: Object = hit.collider
		var enemy_hit := collider.has_method("take_damage")
		if is_instance_valid(fx):
			fx.impact(hit.position, enemy_hit)
		if enemy_hit:
			collider.take_damage(1)
			if is_instance_valid(fx):
				fx.add_camera_trauma(0.05)

func _update_lamp_flicker(delta: float) -> void:
	flicker_clock += delta
	for lamp in flicker_lamps:
		if not is_instance_valid(lamp):
			continue
		var base_energy := float(lamp.get_meta("base_energy", lamp.light_energy))
		var phase := float(lamp.get_meta("flicker_phase", 0.0))
		var wave := 0.91 + sin(flicker_clock * 11.0 + phase) * 0.09
		var dropout := 0.38 if fmod(flicker_clock + phase, 4.1) < 0.045 else 1.0
		lamp.light_energy = base_energy * maxf(0.20, wave * dropout)

func _update_damage_feedback(delta: float) -> void:
	if damage_flash > 0.0:
		damage_flash = maxf(0.0, damage_flash - delta * 2.8)
	if is_instance_valid(damage_overlay):
		damage_overlay.color = Color(0.42, 0.01, 0.005, damage_flash * 0.34)

func _update_crosshair_feedback(delta: float) -> void:
	if crosshair_feedback_timer > 0.0:
		crosshair_feedback_timer = maxf(0.0, crosshair_feedback_timer - delta)
		return
	if is_instance_valid(crosshair):
		crosshair.text = "+"
		crosshair.modulate = Color.WHITE

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

func _on_player_damaged(_amount: int) -> void:
	damage_flash = 1.0
	if is_instance_valid(fx):
		fx.add_camera_trauma(0.34)

func _on_enemy_died(world_position: Vector3) -> void:
	if is_instance_valid(fx):
		fx.death_burst(world_position)
		fx.add_camera_trauma(0.10)

func _on_player_died() -> void:
	player.set_physics_process(false)
	_show_message("VOCÊ NÃO SOBREVIVEU — reinicie a cena")
