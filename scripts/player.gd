class_name SurvivorPlayer
extends CharacterBody3D

signal stats_changed
signal died

const WALK_SPEED := 3.2
const RUN_SPEED := 5.0
const MAGAZINE_SIZE := 6
const MAX_HEALTH := 100
const FACING_STEP := PI / 4.0

var health := MAX_HEALTH
var ammo := MAGAZINE_SIZE
var reserve_ammo := 18
var aiming := false
var aim_point := Vector3.ZERO
var camera_basis := Basis.IDENTITY
var fire_cooldown := 0.0
var reloading := false
var visual_root: Node3D
var left_leg: MeshInstance3D
var right_leg: MeshInstance3D
var left_arm: MeshInstance3D
var right_arm: MeshInstance3D
var gun: MeshInstance3D
var walk_phase := 0.0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1 | 4 | 8
	_build_body()
	stats_changed.emit()

func _build_body() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.32
	shape.height = 1.55
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.78
	add_child(collision)

	visual_root = Node3D.new()
	visual_root.name = "VisualRoot"
	add_child(visual_root)

	_add_box_part("Torso", Vector3(0.58, 0.82, 0.34), Vector3(0, 1.12, 0), Color(0.18, 0.27, 0.24))
	_add_box_part("Shoulders", Vector3(0.72, 0.18, 0.36), Vector3(0, 1.42, 0), Color(0.15, 0.23, 0.21))
	left_leg = _add_box_part("LeftLeg", Vector3(0.20, 0.72, 0.22), Vector3(-0.16, 0.43, 0), Color(0.10, 0.12, 0.12))
	right_leg = _add_box_part("RightLeg", Vector3(0.20, 0.72, 0.22), Vector3(0.16, 0.43, 0), Color(0.10, 0.12, 0.12))
	left_arm = _add_box_part("LeftArm", Vector3(0.18, 0.72, 0.20), Vector3(-0.43, 1.12, 0), Color(0.20, 0.29, 0.25))
	right_arm = _add_box_part("RightArm", Vector3(0.18, 0.72, 0.20), Vector3(0.43, 1.12, 0), Color(0.20, 0.29, 0.25))

	var head := MeshInstance3D.new()
	head.name = "Head"
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.22
	head_mesh.height = 0.44
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.58, 0.44, 0.34)
	head_mat.roughness = 0.98
	head_mesh.material = head_mat
	head.mesh = head_mesh
	head.position = Vector3(0, 1.72, 0)
	visual_root.add_child(head)

	gun = _add_box_part("Pistol", Vector3(0.10, 0.10, 0.42), Vector3(0.22, 1.16, -0.40), Color(0.08, 0.085, 0.09))
	gun.visible = false

	var flashlight := SpotLight3D.new()
	flashlight.name = "Flashlight"
	flashlight.position = Vector3(0.18, 1.27, -0.34)
	flashlight.rotation_degrees.x = -8
	flashlight.light_energy = 2.7
	flashlight.spot_range = 8.5
	flashlight.spot_angle = 31.0
	flashlight.shadow_enabled = true
	flashlight.light_color = Color(1.0, 0.90, 0.70)
	add_child(flashlight)

func _add_box_part(part_name: String, size: Vector3, position: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.96
	mesh.material = material
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.position = position
	visual_root.add_child(part)
	return part

func _physics_process(delta: float) -> void:
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	_apply_movement(delta)
	_update_facing()
	_animate_visual(delta)

func _apply_movement(delta: float) -> void:
	var input := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A):
		input.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		input.x += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		input.y += 1.0
	if Input.is_physical_key_pressed(KEY_S):
		input.y -= 1.0
	input = input.normalized()

	var forward := -camera_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := camera_basis.x
	right.y = 0.0
	right = right.normalized()
	var direction := (right * input.x + forward * input.y).normalized()
	var running := Input.is_physical_key_pressed(KEY_SHIFT) and not aiming
	var speed := RUN_SPEED if running else WALK_SPEED
	if aiming:
		speed *= 0.58

	velocity.x = move_toward(velocity.x, direction.x * speed, 14.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, 14.0 * delta)
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = -0.1
	move_and_slide()

func _update_facing() -> void:
	var direction := Vector3.ZERO
	if aiming:
		direction = Vector3(aim_point.x - global_position.x, 0, aim_point.z - global_position.z)
	elif Vector2(velocity.x, velocity.z).length_squared() > 0.1:
		direction = Vector3(velocity.x, 0, velocity.z)
	if direction.length_squared() < 0.01:
		return
	var angle := atan2(-direction.x, -direction.z)
	rotation.y = snappedf(angle, FACING_STEP)

func _animate_visual(delta: float) -> void:
	if not is_instance_valid(visual_root):
		return
	var planar_speed := Vector2(velocity.x, velocity.z).length()
	if planar_speed > 0.18:
		walk_phase += delta * planar_speed * 4.6
		var swing := sin(walk_phase) * 0.32
		left_leg.rotation.x = swing
		right_leg.rotation.x = -swing
		left_arm.rotation.x = -swing * 0.55
		if not aiming:
			right_arm.rotation.x = swing * 0.55
		visual_root.position.y = abs(sin(walk_phase * 2.0)) * 0.018
	else:
		left_leg.rotation.x = lerpf(left_leg.rotation.x, 0.0, clampf(delta * 9.0, 0.0, 1.0))
		right_leg.rotation.x = lerpf(right_leg.rotation.x, 0.0, clampf(delta * 9.0, 0.0, 1.0))
		left_arm.rotation.x = lerpf(left_arm.rotation.x, 0.0, clampf(delta * 9.0, 0.0, 1.0))
		if not aiming:
			right_arm.rotation.x = lerpf(right_arm.rotation.x, 0.0, clampf(delta * 9.0, 0.0, 1.0))
		visual_root.position.y = lerpf(visual_root.position.y, 0.0, clampf(delta * 10.0, 0.0, 1.0))
	gun.visible = aiming
	if aiming:
		right_arm.rotation.x = lerpf(right_arm.rotation.x, -0.55, clampf(delta * 12.0, 0.0, 1.0))

func set_camera_basis(value: Basis) -> void:
	camera_basis = value

func try_fire() -> bool:
	if not aiming or reloading or fire_cooldown > 0.0:
		return false
	if ammo <= 0:
		return false
	ammo -= 1
	fire_cooldown = 0.22
	stats_changed.emit()
	return true

func reload() -> void:
	if reloading or ammo >= MAGAZINE_SIZE or reserve_ammo <= 0:
		return
	reloading = true
	await get_tree().create_timer(0.85).timeout
	var needed := MAGAZINE_SIZE - ammo
	var amount := mini(needed, reserve_ammo)
	ammo += amount
	reserve_ammo -= amount
	reloading = false
	stats_changed.emit()

func add_ammo(amount: int) -> void:
	reserve_ammo += amount
	stats_changed.emit()

func damage(amount: int) -> void:
	health = maxi(0, health - amount)
	stats_changed.emit()
	if health == 0:
		died.emit()

func heal(amount: int) -> void:
	health = mini(MAX_HEALTH, health + amount)
	stats_changed.emit()
