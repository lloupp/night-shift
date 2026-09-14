class_name StalkerEnemy
extends CharacterBody3D

var target: SurvivorPlayer
var health := 3
var move_speed := 1.45
var detection_range := 10.0
var attack_range := 1.25
var attack_cooldown := 0.0

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1 | 2
	_build_body()

func _build_body() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.7
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.85
	add_child(collision)

	var mesh := CapsuleMesh.new()
	mesh.radius = 0.34
	mesh.height = 1.7
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.31, 0.16, 0.13)
	mat.roughness = 1.0
	mesh.material = mat
	var body := MeshInstance3D.new()
	body.mesh = mesh
	body.position.y = 0.85
	add_child(body)

	var eye := OmniLight3D.new()
	eye.position = Vector3(0, 1.55, -0.26)
	eye.light_color = Color(0.75, 0.08, 0.04)
	eye.light_energy = 0.32
	eye.omni_range = 1.1
	add_child(eye)

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	if not is_instance_valid(target):
		return
	var distance := global_position.distance_to(target.global_position)
	if distance > detection_range:
		velocity.x = move_toward(velocity.x, 0.0, 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 4.0 * delta)
		move_and_slide()
		return

	var direction := target.global_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.01:
		direction = direction.normalized()
		look_at(global_position + direction, Vector3.UP)

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

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
