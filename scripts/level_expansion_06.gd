extends Node

const FusePickupClass = preload("res://scripts/fuse_pickup.gd")
const PowerPanelClass = preload("res://scripts/power_panel.gd")
const KeyPickupClass = preload("res://scripts/key_pickup.gd")

var level: Node3D
var player: SurvivorPlayer
var shop_light: OmniLight3D
var sequence_active := false
var power_restored := false

func _ready() -> void:
	call_deferred("_install_sequence")

func _install_sequence() -> void:
	level = get_parent() as Node3D
	if not is_instance_valid(level):
		return
	player = level.get_node_or_null("Player") as SurvivorPlayer
	if not is_instance_valid(player):
		return

	var original_key := level.get_node_or_null("ServiceKey")
	if is_instance_valid(original_key):
		original_key.queue_free()

	_build_east_shop_interior()
	_spawn_fuse()
	_spawn_power_panel()
	_build_shop_light()
	sequence_active = true
	level.call("_update_objective", "Encontre o fusível na loja leste")

func _build_east_shop_interior() -> void:
	level.call("_add_static_box", "EastInteriorWestA", Vector3(0.24, 2.6, 1.9), Vector3(4.8, 1.3, -3.55), Color(0.15, 0.16, 0.16), true)
	level.call("_add_static_box", "EastInteriorWestB", Vector3(0.24, 2.6, 2.0), Vector3(4.8, 1.3, 0.55), Color(0.15, 0.16, 0.16), true)
	level.call("_add_static_box", "EastShelfA", Vector3(2.0, 1.15, 0.48), Vector3(7.15, 0.575, -2.15), Color(0.16, 0.13, 0.10), false)
	level.call("_add_static_box", "EastShelfB", Vector3(1.8, 1.15, 0.48), Vector3(9.15, 0.575, -0.65), Color(0.15, 0.12, 0.095), false)
	level.call("_add_decor_box", "EastShopFloor", Vector3(5.5, 0.035, 5.5), Vector3(7.65, 0.05, -1.45), Color(0.085, 0.09, 0.09))
	level.call("_add_decor_box", "EastShopMat", Vector3(1.25, 0.025, 0.75), Vector3(5.45, 0.075, -1.45), Color(0.13, 0.08, 0.07))

func _spawn_fuse() -> void:
	var fuse: FusePickup = FusePickupClass.new()
	fuse.name = "ShopFuse"
	fuse.position = Vector3(8.35, 0.05, -3.55)
	fuse.collected.connect(_on_fuse_collected)
	level.add_child(fuse)

func _spawn_power_panel() -> void:
	var panel: PowerPanel = PowerPanelClass.new()
	panel.name = "ShopPowerPanel"
	panel.position = Vector3(10.45, 0.0, 0.55)
	panel.rotation_degrees.y = -90.0
	panel.powered.connect(_on_power_restored)
	level.add_child(panel)

func _build_shop_light() -> void:
	shop_light = OmniLight3D.new()
	shop_light.name = "EastShopCeilingLight"
	shop_light.position = Vector3(7.8, 2.45, -1.6)
	shop_light.light_color = Color(0.76, 0.88, 0.78)
	shop_light.light_energy = 0.0
	shop_light.omni_range = 6.2
	shop_light.shadow_enabled = true
	level.add_child(shop_light)

func _on_fuse_collected() -> void:
	if not sequence_active or power_restored:
		return
	level.call("_update_objective", "Instale o fusível no painel elétrico")
	level.call("_show_message", "O fusível parece intacto")

func _on_power_restored() -> void:
	if power_restored:
		return
	power_restored = true
	if is_instance_valid(shop_light):
		shop_light.light_energy = 3.4
	_spawn_service_key()
	level.call("_update_objective", "Procure a chave de serviço na loja oeste")
	level.call("_show_message", "A energia voltou — algo destravou do outro lado")

func _spawn_service_key() -> void:
	var service_key: KeyPickup = KeyPickupClass.new()
	service_key.name = "ServiceKey"
	service_key.position = Vector3(-6.6, 0.05, -3.25)
	service_key.collected.connect(_on_service_key_collected)
	level.add_child(service_key)

func _on_service_key_collected(key_id: String) -> void:
	level.call("_on_key_collected", key_id)
