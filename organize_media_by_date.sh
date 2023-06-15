#!/bin/bash

destination=$(osascript -e 'POSIX path of (choose folder with prompt "Select the destination folder:")')

# Name of the file storing the hashes
hashFile="$destination/.hashes"

# Create the hash file if it doesn't exist
touch "$hashFile"

# File extension arrays
imageExtensions=("arw" "jpg" "jpeg" "png" "gif" "bmp" "heif" "heic" "dng" "raw" "tiff" "tif" "psd" "svg" "svgz" "dib" "pxd" "webp" "jp2" "psd" "eps" "ai" "cr2" "nrw" "k25")
video360Extensions=("insv" "insp")
videoExtensions=("mp4" "mov" "avi" "mkv" "flv" "wmv" "vob" "m4p" "m4v" "mpg" "mp2" "mpeg" "mpe" "mpv" "webm" "qt" "swf" "asf")
audioExtensions=("mp3" "wav" "m4a" "flac" "aac" "midi" "ogg" "wma" "ape")

process_files () {
    local category=$1
    local extensions=("${!2}")
    for ext in "${extensions[@]}"; do
        if [ -d "$item" ]; then
            find "$item" -type f -iname "*.$ext" -exec bash -c '
                f="{}"
                destination="$1"
                hashFile="$2"
                category="$3"
                ext="$4"
                fileHash=$(shasum -a 256 "$f" | cut -d " " -f 1)
                if ! grep -q "$fileHash" "$hashFile"; then
                    dateString=$(stat -f "%Sm" -t "%Y/%m" "$f")
                    newFolderPath="$destination/$(echo $category | tr '[:upper:]' '[:lower:]')/$dateString"
                    mkdir -p "$newFolderPath"
                    originalFilename=$(basename "$f")
                    newFilePath="$newFolderPath/$originalFilename"
                    if [ -e "$newFilePath" ]; then
                        # If a file with the same name exists, append the hash to the filename
                        baseName=$(basename "$originalFilename" .$ext)
                        newFilePath="$newFolderPath/$baseName-$fileHash.$ext"
                    fi
                    cp "$f" "$newFilePath"
                    echo "$fileHash" >> "$hashFile"
                fi
            ' {} "$destination" "$hashFile" "$category" "$ext" \;
        else
            if [[ "$item" == *".$ext" ]]; then
                f="$item"
                fileHash=$(shasum -a 256 "$f" | cut -d " " -f 1)
                if ! grep -q "$fileHash" "$hashFile"; then
                    dateString=$(stat -f "%Sm" -t "%Y/%m" "$f")
                    newFolderPath="$destination/$(echo $category)/$dateString"
                    mkdir -p "$newFolderPath"
                    originalFilename=$(basename "$f")
                    newFilePath="$newFolderPath/$originalFilename"
                    if [ -e "$newFilePath" ]; then
                        # If a file with the same name exists, append the hash to the filename
                        baseName=$(basename "$originalFilename" .$ext)
                        newFilePath="$newFolderPath/$baseName-$fileHash.$ext"
                    fi
                    cp "$f" "$newFilePath"
                    echo "$fileHash" >> "$hashFile"
                fi
                break
            fi
        fi
    done
}


for item in "$@"
do
    process_files "image" imageExtensions[@]
    process_files "video360" video360Extensions[@]
    process_files "video" videoExtensions[@]
    process_files "audio" audioExtensions[@]
done