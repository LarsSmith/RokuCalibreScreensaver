import os
import sys
from PIL import Image

# ---- EDIT THIS VALUE TO CHANGE MAXIMUM HEIGHT FOR RESIZED IMAGES ----
MAX_HEIGHT = 1080
# ---------------------------------------------------------------------

def resize_and_copy_jpgs(source_dir, destination_dir, max_height=MAX_HEIGHT):
    """
    Copies and resizes all .jpg files from the source directory (including subdirectories)
    to the destination directory, maintaining aspect ratio with a maximum height.
    Preserves the directory structure of the source directory and removes any files
    in the destination that don't exist in the source directory structure.
    Also removes empty directories in the destination folder.

    :param source_dir: Path to the source directory
    :param destination_dir: Path to the destination directory
    :param max_height: Maximum height for resized images
    """
    print(f"Source directory: {source_dir}")
    print(f"Destination directory: {destination_dir}")

    valid_destination_files = set()
    jpg_files = []

    # Collect all jpg files to process, excluding .caltrash
    for root, _, files in os.walk(source_dir):
        relative_path = os.path.relpath(root, source_dir)
        if os.path.normpath(relative_path).startswith(os.path.join("Calibre", ".caltrash")) or ".caltrash" in relative_path.split(os.sep):
            continue
        for file in files:
            if file.lower().endswith(".jpg"):
                jpg_files.append((root, file, relative_path))

    total_files = len(jpg_files)
    copied_count = 0

    # Process files with progress indicator
    for idx, (root, file, relative_path) in enumerate(jpg_files, 1):
        source_path = os.path.join(root, file)
        destination_subdir = os.path.join(destination_dir, relative_path)
        if not os.path.exists(destination_subdir):
            os.makedirs(destination_subdir)
        destination_path = os.path.join(destination_subdir, file)
        valid_destination_files.add(destination_path)

        try:
            with Image.open(source_path) as img:
                if img.height > max_height:
                    aspect_ratio = img.width / img.height
                    new_height = max_height
                    new_width = int(new_height * aspect_ratio)
                    img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                img.save(destination_path, "JPEG")
                copied_count += 1
        except Exception as e:
            print(f"\nFailed to process {source_path}: {e}")

        # Progress indicator
        if idx % 10 == 0 or idx == total_files:
            print(f"\rProcessing images: {idx}/{total_files}", end='', flush=True)
    print(f"\rProcessing images: {total_files}/{total_files}")

    # Remove files in the destination that are not in the source
    for root, _, files in os.walk(destination_dir):
        for file in files:
            destination_path = os.path.join(root, file)
            if destination_path not in valid_destination_files:
                os.remove(destination_path)

    # Remove empty directories in the destination
    empty_dirs_cleared = 0
    for root, dirs, _ in os.walk(destination_dir, topdown=False):
        for dir in dirs:
            dir_path = os.path.join(root, dir)
            if not os.listdir(dir_path):
                os.rmdir(dir_path)
                empty_dirs_cleared += 1

    print(f"\nSummary:")
    print(f"  JPG files copied/resized: {copied_count}")
    print(f"  Empty directories cleared: {empty_dirs_cleared}")

def get_all_calibre_libraries_from_gui_json():
    import json
    import os
    config_path = os.path.expandvars(r'%APPDATA%\calibre\gui.json')
    if not os.path.exists(config_path):
        return []
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return list(data.get('library_usage_stats', {}).keys())
    except Exception:
        return []

if __name__ == "__main__":
    # Require destination drive letter as first argument
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: python resize_and_copy_jpgs.py <destination_drive_letter> [<source_directory>]")
        print("Example: python resize_and_copy_jpgs.py e: [C:\\Users\\me\\Documents\\Calibre\\Main]")
        print("Omit <source_directory> to use all Calibre libraries as sources.")
        sys.exit(1)

    # Accept drive letter with or without colon (e.g., "e" or "e:")
    drive_letter = sys.argv[1].rstrip(':\\').upper()
    destination_directory = f"{drive_letter}:\\Calibre"

    # Determine source directories
    if len(sys.argv) == 3:
        source_directories = [sys.argv[2]]
    else:
        source_directories = get_all_calibre_libraries_from_gui_json()
        if not source_directories:
            print("Could not determine any source directories from Calibre.")
            print("Usage: python resize_and_copy_jpgs.py <destination_drive_letter> [<source_directory>]")
            print("Omit <source_directory> to use all Calibre libraries as sources.")
            sys.exit(1)

    for source_directory in source_directories:
        # Use the library directory name as the subdirectory under Calibre
        library_name = os.path.basename(os.path.normpath(source_directory))
        final_destination = os.path.join(destination_directory, library_name)
        print(f"\nProcessing library: {source_directory}")
        print(f"Destination subdirectory: {final_destination}")
        resize_and_copy_jpgs(source_directory, final_destination)