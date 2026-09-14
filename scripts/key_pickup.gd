class_name KeyPickup
extends StaticBody3D

signal collected(key_id: String)

@export var key_id := "service_key"
@export var display_name := "Chave de serviço"

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	add_to_group("interactable")
	_build_visual()

func _build_visual() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.28, 0.08, 0.12)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.72, 0.55, 0.16)
	mat.metallic = 0.65
	mat.roughness = 0.38
	mat.emission_enabled = true
	mat.emission = Color(0.28, 0.18, 0.025)
	mat.emission_energy_multiplier = 1.3
	mesh.material = mat
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.position.y = 0.16
	visual.rotation_degrees.y = 18.0
	add_child(visual)

	var ring := MeshInstance3D.new()
	var ring_mesh := BoxMesh.new()
	ring_mesh.size = Vector3(0.11, 0.04, 0.26)
	ring_mesh.material = mat
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.16, 0.13)
	add_child(ring)

	var glow := OmniLight3D.new()
	glow.position.y = 0.22
	glow.light_color = Color(1.0, 0.68, 0.20)
	glow.light_energy = 0.55
	glow.omni_range = 1.4
	glow.shadow_enabled = false
	add_child(glow)

	var shape := BoxShape3D.new()
	shape.size = Vector3(0.55, 0.35, 0.55)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.18
	add_child(collision)

func interact(player: SurvivorPlayer) -> String:
	player.add_key(key_id)
	collected.emit(key_id)
	queue_free()
	return "%s obtida" % display_name

func interaction_label() -> String:
	return "Pegar %s" % display_name.to_lower()
