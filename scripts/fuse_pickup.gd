class_name FusePickup
extends StaticBody3D

signal collected

@export var key_id := "shop_fuse"

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	add_to_group("interactable")
	_build_visual()

func _build_visual() -> void:
	var body_mesh := CylinderMesh.new()
	body_mesh.top_radius = 0.07
	body_mesh.bottom_radius = 0.07
	body_mesh.height = 0.30
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.72, 0.66, 0.45)
	body_mat.metallic = 0.42
	body_mat.roughness = 0.44
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.14, 0.10, 0.02)
	body_mat.emission_energy_multiplier = 1.4
	body_mesh.material = body_mat
	var body := MeshInstance3D.new()
	body.mesh = body_mesh
	body.position.y = 0.19
	body.rotation_degrees.z = 90.0
	add_child(body)

	var glow := OmniLight3D.new()
	glow.position = Vector3(0, 0.28, 0)
	glow.light_color = Color(0.92, 0.73, 0.28)
	glow.light_energy = 0.45
	glow.omni_range = 1.2
	glow.shadow_enabled = false
	add_child(glow)

	var shape := BoxShape3D.new()
	shape.size = Vector3(0.50, 0.38, 0.50)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.19
	add_child(collision)

func interact(player: SurvivorPlayer) -> String:
	player.add_key(key_id)
	collected.emit()
	queue_free()
	return "Fusível encontrado"

func interaction_label() -> String:
	return "Pegar fusível"
