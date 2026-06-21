extends MeshInstance3D

var ttl : float = 1
func _ready() -> void:
	$Timer.start(ttl)


func _on_timer_timeout() -> void:
	queue_free()
