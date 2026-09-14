class_name HealthPickup
extends StaticBody3D

@export var amount := 30

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	add_to_group("interactable")
	_build_visual()

func _build_visual() -> void:
	var case_mesh := BoxMesh.new()
	case_mesh.size = Vector3(0.48, 0.18, 0.34)
	var case_mat := StandardMaterial3D.new()
	case_mat.albedo_color = Color(0.72, 0.73, 0.67)
	case_mat.roughness = 0.72
	case_mesh.material = case_mat
	var case_visual := MeshInstance3D.new()
	case_visual.mesh = case_mesh
	case_visual.position.y = 0.09
	add_child(case_visual)

	var cross_mat := StandardMaterial3D.new()
	cross_mat.albedo_color = Color(0.56, 0.08, 0.065)
	cross_mat.emission_enabled = true
	cross_mat.emission = Color(0.22, 0.015, 0.01)
	cross_mat.emission_energy_multiplier = 1.3

	for data in [
		[Vector3(0.22, 0.04, 0.08), Vector3(0.0, 0.205, -0.175)],
		[Vector3(0.08, 0.04, 0.22), Vector3(0.0, 0.205, -0.175)]
	]:
		var cross_mesh := BoxMesh.new()
		cross_mesh.size = data[0]
		cross_mesh.material = cross_mat
		var cross_visual := MeshInstance3D.new()
		cross_visual.mesh = cross_mesh
		cross_visual.position = data[1]
		add_child(cross_visual)

	var glow := OmniLight3D.new()
	glow.position = Vector3(0, 0.28, 0)
	glow.light_color = Color(0.95, 0.16, 0.11)
	glow.light_energy = 0.38
	glow.omni_range = 1.15
	glow.shadow_enabled = false
	add_child(glow)

	var shape := BoxShape3D.new()
	shape.size = Vector3(0.52, 0.30, 0.42)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.15
	add_child(collision)

func interact(player: SurvivorPlayer) -> String:
	if player.health >= 100:
		return "Kit médico — vida já está cheia"
	var before := player.health
	player.heal(amount)
	var restored := player.health - before
	queue_free()
	return "+%d vida" % restored

func interaction_label() -> String:
	return "Usar kit médico"
