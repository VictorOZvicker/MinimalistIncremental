extends Control

## Selo de "novo" fixo no canto do node que o contém. Começa escondido
## (visible = false na cena) e some sozinho depois de $Timer.wait_time.

func start_timer():
	self.show()
	$Timer.start()

func _on_timer_timeout() -> void:
	self.hide()
