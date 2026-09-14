extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures.append(message)
	push_error("PROGRESSION TEST: " + message)

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	_check(packed != null, "main scene must load")
	if packed == null:
		_finish()
		return

	var level := packed.instantiate()
	get_root().add_child(level)
	await process_frame
	await process_frame
	await process_frame

	var player := level.get_node_or_null("Player") as SurvivorPlayer
	_check(player != null, "player must spawn")
	if player == null:
		_finish()
		return

	for enemy in get_nodes_in_group("enemy"):
		if is_instance_valid(enemy):
			enemy.set_physics_process(false)

	var hunter := level.get_node_or_null("Hunter") as StalkerEnemy
	_check(hunter != null, "Hunter archetype must spawn")
	if hunter != null:
		_check(hunter.health == 2, "Hunter must remain fragile")
		_check(hunter.move_speed > 1.45, "Hunter must remain faster than a Stalker")

	var health_pickup := level.get_node_or_null("HealthPickup") as HealthPickup
	_check(health_pickup != null, "health pickup must spawn")
	if health_pickup != null:
		player.health = 60
		health_pickup.interact(player)
		_check(player.health == 90, "health pickup must restore 30 health")

	_check(level.get_node_or_null("ServiceKey") == null, "service key must be gated before power restoration")

	var fuse := level.get_node_or_null("ShopFuse") as FusePickup
	var panel := level.get_node_or_null("ShopPowerPanel") as PowerPanel
	_check(fuse != null, "fuse must spawn")
	_check(panel != null, "power panel must spawn")
	if fuse == null or panel == null:
		_finish()
		return

	var locked_result := panel.interact(player)
	_check(not panel.is_powered, "panel must stay off without fuse")
	_check(locked_result == "Painel sem fusível", "panel must explain missing fuse")

	fuse.interact(player)
	_check(player.has_key("shop_fuse"), "collecting fuse must register key item")

	panel.interact(player)
	_check(panel.is_powered, "panel must turn on with fuse")
	await process_frame

	var service_key := level.get_node_or_null("ServiceKey") as KeyPickup
	_check(service_key != null, "service key must spawn after power restoration")
	if service_key == null:
		_finish()
		return

	service_key.interact(player)
	_check(player.has_key("service_key"), "service key must enter key-item inventory")

	var exit_gate := level.get_node_or_null("ExitGate") as ExitGate
	_check(exit_gate != null, "exit gate must spawn")
	if exit_gate != null:
		exit_gate.interact(player)
		_check(exit_gate.opened, "exit gate must open with service key")
		_check(bool(level.get("run_completed")), "opening exit gate must complete the run")

	_finish()

func _finish() -> void:
	if failures.is_empty():
		print("PROGRESSION TEST: PASS")
		quit(0)
	else:
		print("PROGRESSION TEST: FAIL (%d)" % failures.size())
		quit(1)
