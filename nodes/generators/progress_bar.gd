extends Control

var total_wait_time: float = 0.0

signal progress_complete()

func _process(_delta: float) -> void:
	var elapsed: float  = total_wait_time - $productionTimer.time_left
	$progressBar.value  = (elapsed / total_wait_time) * 100.0
	$progressLabel.text = "%.1f / %.1f" % [elapsed, total_wait_time]

func on_production_timer_timeout() -> void:
	progress_complete.emit()

func start_timer(_time: float):
	total_wait_time = _time
	$productionTimer.start(total_wait_time)

func set_generator_color(_color: Color):
	$generatorColor.color = _color
