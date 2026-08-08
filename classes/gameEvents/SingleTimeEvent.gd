class_name SingleTimeEvent extends Node

@export var condition: String = ""
@export var execution: String = ""
@export var condition_args: Array = []
@export var execution_args: Array = []

var _condition: Callable
var _execution: Callable

func _ready() -> void:
	self._condition = Callable(SingleTimeEventsConditions, condition)
	self._execution = Callable(GameEventsManager, execution)

func _process(_delta: float) -> void:
	var result: Variant = _condition.call(condition_args)
	if result == null:
		push_error("SingleTimeEvent '%s': condição '%s' falhou (função inexistente em SingleTimeEventsConditions ou condition_args incompatível)." % [self.name, condition])
		set_process(false)
		return
	if not bool(result): return
	set_process(false)
	self._execution.callv(_resolve_execution_args())
	self.queue_free()

func _resolve_execution_args() -> Array:
	var resolved := []
	for arg in execution_args:
		resolved.append(arg.call() if arg is Callable else arg)
	return resolved
