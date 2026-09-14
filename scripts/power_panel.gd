class_name PowerPanel
extends StaticBody3D

signal powered

@export var required_key := "shop_fuse"
var is_powered := false
var indicator: OmniLight3D

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	add_to_group("interactable")
	_build_panel()

func _build_panel() -> void:
	var case_mesh := BoxMesh.new()
	case_mesh.size = Vector3(0.72, 1.05, 0.24)
	var case_mat := StandardMaterial3D.new()
	case_mat.albedo_color = Color(0.15, 0.17, 0.16)
	case_mat.metallic = 0.35
	case_mat.roughness = 0.62
	case_mesh.material = case_mat
	var case_visual := MeshInstance3D.new()
	case_visual.mesh = case_mesh
	case_visual.position = Vector3(0, 0.72, 0)
	add_child(case_visual)

	var slot_mesh := BoxMesh.new()
	slot_mesh.size = Vector3(0.34, 0.18, 0.05)
	var slot_mat := StandardMaterial3D.new()
	slot_mat.albedo_color = Color(0.04, 0.045, 0.04)
	slot_mesh.material = slot_mat
	var slot := MeshInstance3D.new()
	slot.mesh = slot_mesh
	slot.position = Vector3(0, 0.72, -0.145)
	add_child(slot)

	indicator = OmniLight3D.new()
	indicator.position = Vector3(0, 1.02, -0.16)
	indicator.light_color = Color(0.85, 0.10, 0.05)
	indicator.light_energy = 0.55
	indicator.omni_range = 1.1
	indicator.shadow_enabled = false
	add_child(indicator)

	var shape := BoxShape3D.new()
	shape.size = Vector3(0.78, 1.10, 0.30)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(0, 0.72, 0)
	add_child(collision)

func interact(player: SurvivorPlayer) -> String:
	if is_powered:
		return "Energia restaurada"
	if not player.has_key(required_key):
		return "Painel sem fusível"
	player.consume_key(required_key)
	is_powered = true
	indicator.light_color = Color(0.14, 1.0, 0.35)
	indicator.light_energy = 1.0
	powered.emit()
	return "Energia restaurada"

func interaction_label() -> String:
	return "Painel energizado" if is_powered else "Examinar painel elétrico"
