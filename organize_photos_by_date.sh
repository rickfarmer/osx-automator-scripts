destination=$(osascript -e 'POSIX path of (choose folder with prompt "Select the destination folder:")')

for item in "$@"
do
    if [ -d "$item" ]; then
        find "$item" -type f \( -iname "*.arw" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" \) -exec bash -c '
            f="$1"
            destination="$2"
            dateString=$(stat -f "%Sm" -t "%Y/%m" "$f")
            newFolderPath="$destination/$dateString"
            mkdir -p "$newFolderPath"
            cp "$f" "$newFolderPath"
        ' _ {} "$destination" \;
    else
        dateString=$(stat -f "%Sm" -t "%Y/%m" "$item")
        newFolderPath="$destination/$dateString"
        mkdir -p "$newFolderPath"
        cp "$item" "$newFolderPath"
    fi
done
