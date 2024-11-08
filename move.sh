#!/bin/bash
# Script to merge multiple video files into one.

DEST_DIR="/mnt/storage-slow/.stash/streams"

# Exit script if any command fails.
set -e

# For each directory in destination directory, merge all mp4 files into one.
for dir in $DEST_DIR/*; do
    echo "Checking $dir"
    if [ -d "$dir" ]; then
        cd "$dir"

        OUTPUT_NAME=$(basename $dir)

        # Skip everything if theres no or only one mp4 file.
        if [ $(ls -1 *.mp4 2>/dev/null | wc -l) -le 1 ]; then
            echo "Skipping $dir as there's no or only one video file."
            continue
        fi

        # Create a output directory if it doesn't exist.
        if [ ! -d .output ]; then
            mkdir -p .output
        fi

        # For each mp4 file in the current directory, create a list that have the same date in the file name.
        for file in *.mp4; do
            echo "Processing stream: $file"
            # Match the YYYYMMDD part of the date.
            date=$(echo "$file" | grep -oE "([0-9]{4})(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])")

            if [ ! -f "$OUTPUT_NAME-$date.list" ]; then
                echo "file '$file'" >"$OUTPUT_NAME-$date.list"
            else
                echo "file '$file'" >>"$OUTPUT_NAME-$date.list"
            fi
        done

        # Remove the list files that have only one file.
        for list_file in *.list; do
            echo "Processing list file: $list_file"
            if [ $(wc -l "$list_file" | cut -f 1 -d ' ') -eq 1 ]; then
                echo "Removing list file as there's only one video: $list_file"
                rm $list_file
            fi
        done

        # If no lists files exist, skip the rest of the process.
        if [ $(ls -1 *.list 2>/dev/null | wc -l) -eq 0 ]; then
            echo "Skipping $dir as there's no list files."
            continue
        fi

        # For each list file, merge the files into one mp4 file.
        for list_file in *.list; do
            echo "Processing list to combine video files: $list_file"
            file_name=$(echo "$list_file" | cut -f 1 -d '-')
            file_date=$(echo "$list_file" | grep -oE "([0-9]{4})(0[1-9]|1[0-2])(0[1-9]|[1-2][0-9]|3[0-1])")
            ffmpeg -f concat -safe 0 -i "$list_file" -c copy ".output/${file_name}_$file_date.XXX.mp4"
            
        done

        # Read the list file and remove the original files.
        for list_file in *.list; do
            while read -r line; do
                file=$(echo "$line" | cut -f 2 -d ' ' | sed "s/'//g")
                rm -v $file
            done <$list_file
        done

        # Move the merged files to the destination directory.
        echo "Moving files..."
        mv -v .output/*.mp4 "$dir"
    fi
done
