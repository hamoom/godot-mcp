#!/usr/bin/env -S godot --script
extends SceneTree

# Screenshot helper script for godot-mcp
# Runs a scene, waits for frames to render, captures screenshot, and quits

var output_path: String = ""
var frame_delay: int = 2
var frames_waited: int = 0

func _init():
	var args = OS.get_cmdline_args()

	# Parse command line arguments
	var i = 0
	while i < args.size():
		if args[i] == "--screenshot-output" and i + 1 < args.size():
			output_path = args[i + 1]
			i += 2
		elif args[i] == "--delay-frames" and i + 1 < args.size():
			frame_delay = int(args[i + 1])
			i += 2
		else:
			i += 1

	if output_path.is_empty():
		printerr("[ERROR] Screenshot output path is required (--screenshot-output)")
		quit(1)

	print("[INFO] Screenshot helper initialized")
	print("[INFO] Output path: " + output_path)
	print("[INFO] Frame delay: " + str(frame_delay))

func _process(_delta):
	frames_waited += 1

	if frames_waited >= frame_delay:
		capture_and_quit()

func capture_and_quit():
	print("[INFO] Capturing screenshot...")

	# Get the root viewport
	var viewport = get_root()
	if viewport == null:
		printerr("[ERROR] Could not get root viewport")
		quit(1)
		return

	# Get the viewport texture and convert to image
	var texture = viewport.get_texture()
	if texture == null:
		printerr("[ERROR] Could not get viewport texture")
		quit(1)
		return

	var image = texture.get_image()
	if image == null:
		printerr("[ERROR] Could not get image from texture")
		quit(1)
		return

	# Ensure output directory exists
	var output_dir = output_path.get_base_dir()
	if not output_dir.is_empty():
		var dir = DirAccess.open("res://")
		if dir != null and not DirAccess.dir_exists_absolute(output_dir):
			var err = DirAccess.make_dir_recursive_absolute(output_dir)
			if err != OK:
				printerr("[ERROR] Failed to create output directory: " + output_dir)
				quit(1)
				return

	# Save the screenshot
	var error = image.save_png(output_path)
	if error == OK:
		print("[INFO] Screenshot saved to: " + output_path)
	else:
		printerr("[ERROR] Failed to save screenshot: " + str(error))
		quit(1)
		return

	quit(0)
