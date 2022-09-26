#!/bin/bash

# Convert all files in current directory to mp4.
for f in *.mkv; do ffmpeg -i "$f" -c copy "${f%.mkv}.mp4"; done
