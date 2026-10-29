extends PanelContainer

@onready var chart_area: Control = $MarginContainer/VBoxContainer/ChartArea

var execution_segments: Array[Dictionary] = []
var completed_processes: Array[Process] = []
var total_time: int = 1

var process_colors: Dictionary = {
	1: Color("#8B5CF6"),
	2: Color("#2563EB"),
	3: Color("#0D9488")
}


func _ready() -> void:
	chart_area.draw.connect(_draw_chart)
	chart_area.resized.connect(chart_area.queue_redraw)

func setup(duration: int) -> void:
	total_time = maxi(duration, 1)
	completed_processes.clear()
	execution_segments.clear()
	chart_area.queue_redraw()

func add_execution_segment(
	process: Process,
	start_time: int,
	end_time: int
) -> void:
	execution_segments.append({
		"process": process,
		"start": start_time,
		"end": end_time
	})

	chart_area.queue_redraw()

func add_completed_process(process: Process) -> void:
	completed_processes.append(process)
	chart_area.queue_redraw()


func _draw_chart() -> void:
	var width: float = chart_area.size.x
	var bar_height: float = 35.0
	var top: float = 8.0

	if width <= 0:
		return

	var font: Font = ThemeDB.fallback_font

	# FCFS e SJF: processos completos.
	for process in completed_processes:
		_draw_segment(
			process,
			process.start_time,
			process.completion_time,
			width,
			bar_height,
			top,
			font
		)

	# Round Robin: trechos de execução.
	for segment in execution_segments:
		_draw_segment(
			segment["process"],
			segment["start"],
			segment["end"],
			width,
			bar_height,
			top,
			font
		)

	# Marca o término do último trecho.
	var last_end: int = -1

	if not execution_segments.is_empty():
		last_end = execution_segments.back()["end"]
	elif not completed_processes.is_empty():
		last_end = completed_processes.back().completion_time

	if last_end >= 0:
		var end_x: float = (float(last_end) / float(total_time)) * width

		chart_area.draw_string(
			font,
			Vector2(minf(end_x, width - 25), top + 55),
			str(last_end),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			12,
			Color.WHITE
		)

func _draw_segment(
	process: Process,
	start_time: int,
	end_time: int,
	width: float,
	bar_height: float,
	top: float,
	font: Font
) -> void:
	var start_x: float = (
		float(start_time) / float(total_time)
	) * width

	var end_x: float = (
		float(end_time) / float(total_time)
	) * width

	var rect := Rect2(
		Vector2(start_x, top),
		Vector2(end_x - start_x, bar_height)
	)

	var color: Color = process_colors.get(
		process.pid,
		Color("#64748B")
	)

	chart_area.draw_rect(rect, color)

	chart_area.draw_string(
		font,
		Vector2(start_x + 5, top + 23),
		"P%d" % process.pid,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		Color.WHITE
	)

	chart_area.draw_string(
		font,
		Vector2(start_x, top + 55),
		str(start_time),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		12,
		Color.WHITE
	)
