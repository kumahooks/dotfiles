#!/bin/bash
PID_FILE="/tmp/screen_recording.pid"

if [ -f "$PID_FILE" ]; then
	# Stop recording
	PID=$(cat "$PID_FILE")
	kill "$PID"
	rm -f "$PID_FILE"
	notify-send "Screen recording stopped" "Video saved to Videos folder"
else
	# Start recording
	FILENAME="$HOME/Videos/recording_$(date +%Y%m%d_%H%M%S).mp4"

	# Get screen region
	REGION=$(slop -f "%x %y %w %h")
	if [ -z "$REGION" ]; then
		notify-send "Recording cancelled" "No region selected"
		exit 0
	fi

	read X Y W H <<< "$REGION"

	# Start ffmpeg in background and save its PID
	ffmpeg -f x11grab -video_size ${W}x${H} -framerate 25 -i $DISPLAY+${X},${Y} -c:v libx264 -preset fast "$FILENAME" &
	echo $! > "$PID_FILE"

	notify-send "Screen recording started" "\nPress the keybind again to stop"
fi

