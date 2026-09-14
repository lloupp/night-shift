class_name ExitGate
extends StaticBody3D

signal unlocked

@export var required_key := "service_key"

var opened := false
var target_angle := 0.0
var indicator: OmniLight3D

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	add_to_group("interactable")
	_build_gate()

func _build_gate() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.3, 2.55, 0.18)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.13, 0.14)
	mat.metallic = 0.52
	mat.roughness = 0.54
	mesh.material = mat
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.position = Vector3(1.15, 1.275, 0)
	add_child(visual)

	var shape := BoxShape3D.new()
	shape.size = Vector3(2.3, 2.55, 0.18)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(1.15, 1.275, 0)
	add_child(collision)

	indicator = OmniLight3D.new()
	indicator.position = Vector3(0.18, 1.75, -0.20)
	indicator.light_color = Color(0.92, 0.08, 0.04)
	indicator.light_energy = 0.75
	indicator.omni_range = 1.2
	indicator.shadow_enabled = false
	add_child(indicator)

func _process(delta: float) -> void:
	rotation.y = lerp_angle(rotation.y, target_angle, clampf(delta * 5.5, 0.0, 1.0))

func interact(player: SurvivorPlayer) -> String:
	if opened:
		return "Saída liberada"
	if not player.has_key(required_key):
		return "Portão trancado — encontre a chave de serviço"
	opened = true
	target_angle = deg_to_rad(-96.0)
	indicator.light_color = Color(0.18, 0.95, 0.34)
	indicator.light_energy = 1.05
	unlocked.emit()
	return "Portão destrancado"

func interaction_label() -> String:
	return "Saída liberada" if opened else "Abrir portão de serviço"
