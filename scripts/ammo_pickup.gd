class_name AmmoPickup
extends StaticBody3D

@export var amount := 6

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	add_to_group("interactable")
	_build_visual()

func _build_visual() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.42, 0.18, 0.30)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.50, 0.43, 0.22)
	mat.metallic = 0.25
	mat.roughness = 0.72
	mesh.material = mat
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.position.y = 0.09
	add_child(visual)

	var shape := BoxShape3D.new()
	shape.size = Vector3(0.42, 0.18, 0.30)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.09
	add_child(collision)

func interact(player: SurvivorPlayer) -> String:
	player.add_ammo(amount)
	queue_free()
	return "+%d munições" % amount

func interaction_label() -> String:
	return "Pegar munição"
