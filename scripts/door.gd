class_name PrototypeDoor
extends StaticBody3D

var opened := false
var target_angle := 0.0

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	add_to_group("interactable")
	_build_door()

func _build_door() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.5, 2.35, 0.16)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.19, 0.12, 0.08)
	mat.roughness = 0.88
	mesh.material = mat
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.position = Vector3(0.75, 1.175, 0)
	add_child(visual)

	var shape := BoxShape3D.new()
	shape.size = Vector3(1.5, 2.35, 0.16)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(0.75, 1.175, 0)
	add_child(collision)

func _process(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, target_angle, clampf(delta * 6.0, 0.0, 1.0))

func interact(_player: SurvivorPlayer) -> String:
	opened = not opened
	target_angle = deg_to_rad(-92.0) if opened else 0.0
	return "Porta aberta" if opened else "Porta fechada"

func interaction_label() -> String:
	return "Fechar porta" if opened else "Abrir porta"
