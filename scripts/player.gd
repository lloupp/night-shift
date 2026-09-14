class_name SurvivorPlayer
extends CharacterBody3D

signal stats_changed
signal died

const WALK_SPEED := 3.2
const RUN_SPEED := 5.0
const MAGAZINE_SIZE := 6
const MAX_HEALTH := 100

var health := MAX_HEALTH
var ammo := MAGAZINE_SIZE
var reserve_ammo := 18
var aiming := false
var aim_point := Vector3.ZERO
var camera_basis := Basis.IDENTITY
var fire_cooldown := 0.0
var reloading := false

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

	var mesh := CapsuleMesh.new()
	mesh.radius = 0.32
	mesh.height = 1.55
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.23, 0.31, 0.28)
	material.roughness = 0.92
	mesh.material = material
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.position.y = 0.78
	add_child(visual)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.22
	head_mesh.height = 0.44
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.63, 0.50, 0.39)
	head_mesh.material = head_mat
	head.mesh = head_mesh
	head.position = Vector3(0, 1.72, 0)
	add_child(head)

	var flashlight := SpotLight3D.new()
	flashlight.position = Vector3(0.18, 1.25, -0.28)
	flashlight.rotation_degrees.x = -8
	flashlight.light_energy = 2.6
	flashlight.spot_range = 8.0
	flashlight.spot_angle = 31.0
	flashlight.shadow_enabled = true
	flashlight.light_color = Color(1.0, 0.91, 0.72)
	add_child(flashlight)

func _physics_process(delta: float) -> void:
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	_apply_movement(delta)
	_update_facing()

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
	if aiming:
		var flat_target := Vector3(aim_point.x, global_position.y, aim_point.z)
		if global_position.distance_squared_to(flat_target) > 0.03:
			look_at(flat_target, Vector3.UP)
	elif Vector2(velocity.x, velocity.z).length_squared() > 0.1:
		var flat_velocity := Vector3(velocity.x, 0, velocity.z)
		look_at(global_position + flat_velocity, Vector3.UP)

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
