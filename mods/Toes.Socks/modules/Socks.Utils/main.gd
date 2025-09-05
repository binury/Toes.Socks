class_name Utils

const last_call_times := {}


static func call_debounced(key: String, func_ref: FuncRef, delay_secs: float, args := []) -> void:
	var now = OS.get_ticks_msec()
	var last = last_call_times.get(key, -delay_secs * 1000.0)
	if now - last >= delay_secs * 1000.0:
		last_call_times[key] = now
		func_ref.call_funcv(args)
