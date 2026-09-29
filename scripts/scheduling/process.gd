class_name Process
extends RefCounted

var pid: int
var arrival_time: int
var burst_time: int
var priority: int

var remaining_time: int
var state: String = "ready"

var start_time: int = -1
var completion_time: int = -1
var waiting_time: int = 0
var turnaround_time: int = 0

func _init(
	process_pid: int,
	process_arrival_time: int,
	process_burst_time: int,
	process_priority: int = 0
) -> void:
	pid = process_pid
	arrival_time = process_arrival_time
	burst_time = process_burst_time
	priority = process_priority

	remaining_time = burst_time
