class_name StalkerEnemy
extends CharacterBody3D

signal died(world_position: Vector3)

const FACING_STEP := PI / 4.0

var target: SurvivorPlayer
var health := 3
var move_speed := 1.45
var detection_range := 10.0
var attack_range := 1.25
var attack_cooldown := 0.0
var visual_root: Node3D
var visual_parts: Array[MeshInstance3D] = []
var walk_phase := 0.0
var hit_flash_timer := 0.0
var hit_material: StandardMaterial3D

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 2
	_build_body()
	_build_hit_material()

func _build_body() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.7
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.85
	add_child(collision)

	visual_root = Node3D.new()
	visual_root.name = "VisualRoot"
	add_child(visual_root)
	_add_part("Torso", Vector3(0.66, 0.94, 0.38), Vector3(0, 1.03, 0), Color(0.28, 0.12, 0.10))
	_add_part("LeftLeg", Vector3(0.23, 0.78, 0.24), Vector3(-0.17, 0.43, 0), Color(0.12, 0.07, 0.065))
	_add_part("RightLeg", Vector3(0.23, 0.78, 0.24), Vector3(0.17, 0.43, 0), Color(0.12, 0.07, 0.065))
	_add_part("LeftArm", Vector3(0.19, 0.78, 0.22), Vector3(-0.45, 1.03, -0.03), Color(0.31, 0.14, 0.11))
	_add_part("RightArm", Vector3(0.19, 0.78, 0.22), Vector3(0.45, 1.03, -0.03), Color(0.31, 0.14, 0.11))

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.24
	head_mesh.height = 0.48
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.30, 0.16, 0.13)
	head_mat.roughness = 1.0
	head_mesh.material = head_mat
	head.mesh = head_mesh
	head.position = Vector3(0, 1.70, -0.02)
	visual_root.add_child(head)
	visual_parts.append(head)

	var eye := OmniLight3D.new()
	eye.position = Vector3(0, 1.55, -0.30)
	eye.light_color = Color(0.78, 0.07, 0.035)
	eye.light_energy = 0.34
	eye.omni_range = 1.15
	add_child(eye)

func _build_hit_material() -> void:
	hit_material = StandardMaterial3D.new()
	hit_material.albedo_color = Color(1.0, 0.48, 0.32)
	hit_material.emission_enabled = true
	hit_material.emission = Color(1.0, 0.12, 0.06)
	hit_material.emission_energy_multiplier = 2.8
	hit_material.roughness = 0.9

func _add_part(part_name: String, size: Vector3, position: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 1.0
	mesh.material = mat
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.position = position
	visual_root.add_child(part)
	visual_parts.append(part)

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	_update_hit_flash(delta)
	if not is_instance_valid(target):
		return
	var distance := global_position.distance_to(target.global_position)
	if distance > detection_range:
		velocity.x = move_toward(velocity.x, 0.0, 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 4.0 * delta)
		move_and_slide()
		_animate_visual(delta)
		return

	var direction := target.global_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.01:
		direction = direction.normalized()
		var angle := atan2(-direction.x, -direction.z)
		rotation.y = snappedf(angle, FACING_STEP)

	if distance > attack_range:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if attack_cooldown <= 0.0:
			target.damage(12)
			attack_cooldown = 1.15
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = -0.1
	move_and_slide()
	_animate_visual(delta)

func _animate_visual(delta: float) -> void:
	if not is_instance_valid(visual_root):
		return
	var speed := Vector2(velocity.x, velocity.z).length()
	if speed > 0.15:
		walk_phase += delta * 7.0
		visual_root.rotation.z = sin(walk_phase) * 0.035
		visual_root.position.y = abs(sin(walk_phase * 2.0)) * 0.015
	else:
		visual_root.rotation.z = lerpf(visual_root.rotation.z, 0.0, clampf(delta * 6.0, 0.0, 1.0))
		visual_root.position.y = lerpf(visual_root.position.y, 0.0, clampf(delta * 6.0, 0.0, 1.0))

func _update_hit_flash(delta: float) -> void:
	if hit_flash_timer > 0.0:
		hit_flash_timer = maxf(0.0, hit_flash_timer - delta)
		for part in visual_parts:
			if is_instance_valid(part):
				part.material_override = hit_material
	else:
		for part in visual_parts:
			if is_instance_valid(part) and part.material_override != null:
				part.material_override = null

func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health -= amount
	hit_flash_timer = 0.11
	if health <= 0:
		died.emit(global_position + Vector3(0, 1.0, 0))
		queue_free()
