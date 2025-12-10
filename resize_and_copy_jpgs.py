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

def find_drive_with_calibre_folder():
    """Return the first drive (like 'E:') that contains a top-level
    folder named 'Calibre' (e.g. 'E:\\Calibre'). Returns None if not found.
    """
    try:
        import string
        for letter in string.ascii_uppercase:
            path = f"{letter}:\\Calibre"
            if os.path.exists(path):
                return f"{letter}:"
    except Exception:
        pass
    return None

def find_drives_with_calibre_folders():
    """Return a list of drive letters (like ['E:', 'F:']) that contain a
    top-level 'Calibre' folder. Order A..Z. Empty list if none found.
    """
    drives = []
    try:
        import string
        for letter in string.ascii_uppercase:
            path = f"{letter}:\\Calibre"
            if os.path.exists(path):
                drives.append(f"{letter}:")
    except Exception:
        pass
    return drives

if __name__ == "__main__":
    print("=== Calibre Screensaver Image Resizer ===\n")
    
    # Prompt for destination drive letter. Show any drives that already contain
    # a top-level 'Calibre' folder before asking so the user can choose.
    detected_drives = find_drives_with_calibre_folders()
    default_drive = detected_drives[0] if detected_drives else None
    if detected_drives:
        print("Detected drives with a top-level 'Calibre' folder:")
        print('  ' + ', '.join(detected_drives))
    if default_drive:
        prompt = f"Enter destination drive letter (e.g., 'e' or 'e:') [default: {default_drive}]: "
    else:
        prompt = "Enter destination drive letter (e.g., 'e' or 'e:'): "

    while True:
        drive_input = input(prompt).strip()
        if not drive_input and default_drive:
            # Use the detected default drive
            drive_letter = default_drive.rstrip(':\\').upper()
            destination_directory = f"{drive_letter}:\\Calibre"
            break
        if drive_input:
            drive_letter = drive_input.rstrip(':\\').upper()
            if len(drive_letter) == 1 and drive_letter.isalpha():
                destination_directory = f"{drive_letter}:\\Calibre"
                break
        print("Invalid drive letter. Please try again.")
    # (Information about detected drives was shown before prompting.)
    
    # Prompt for source directories (auto-detect from Calibre if possible)
    detected_libs = get_all_calibre_libraries_from_gui_json()
    source_directories = []

    if detected_libs:
        if len(detected_libs) == 1:
            lib = detected_libs[0]
            print(f"\nSource directories:\n1. Use Calibre library detected [default: {lib}]\n2. Specify a single directory")
            choice = input("\nSelect option (1 or 2) [default: 1]: ").strip()
            if choice == "2":
                source_dir = input("Enter source directory path: ").strip()
                if not os.path.exists(source_dir):
                    print(f"Error: Directory does not exist: {source_dir}")
                    sys.exit(1)
                source_directories = [source_dir]
            else:
                source_directories = [lib]
        else:
            print("\nDetected Calibre libraries:")
            for i, lib in enumerate(detected_libs, 1):
                print(f"  {i}. {lib}")
            all_option = len(detected_libs) + 1
            specify_option = len(detected_libs) + 2
            print(f"  {all_option}. Use all detected libraries [default]")
            print(f"  {specify_option}. Specify a single directory")
            choice = input(f"\nSelect option (1-{specify_option}) [default: {all_option}]: ").strip()
            if choice == "" or choice == str(all_option):
                source_directories = detected_libs
            elif choice == str(specify_option):
                source_dir = input("Enter source directory path: ").strip()
                if not os.path.exists(source_dir):
                    print(f"Error: Directory does not exist: {source_dir}")
                    sys.exit(1)
                source_directories = [source_dir]
            else:
                try:
                    idx = int(choice) - 1
                    if 0 <= idx < len(detected_libs):
                        source_directories = [detected_libs[idx]]
                    else:
                        raise ValueError()
                except Exception:
                    print("Invalid selection.")
                    sys.exit(1)
        print(f"\nUsing {len(source_directories)} source directory(ies).")
    else:
        # No detected libraries; fall back to asking for a single directory
        print("\nNo Calibre libraries detected. Please specify a source directory.")
        source_dir = input("Enter source directory path: ").strip()
        if not os.path.exists(source_dir):
            print(f"Error: Directory does not exist: {source_dir}")
            sys.exit(1)
        source_directories = [source_dir]
    
    # Confirm before processing. Message varies based on whether destination exists.
    print(f"\nDestination: {destination_directory}")
    if os.path.exists(destination_directory):
        print("This Calibre folder will be used.")
    else:
        print("This Calibre folder will be created.")
    print(f"Source libraries: {len(source_directories)}")
    confirm = input("\nProceed with processing? [Y/n]: ").strip().lower()

    if confirm not in ('', 'y', 'yes'):
        print("Cancelled.")
        sys.exit(0)

    # Ensure top-level destination folder exists. Prompt before creating if missing.
    if not os.path.exists(destination_directory):
        # Default to yes when user presses Enter
        create_confirm = input(f"Destination folder {destination_directory} does not exist. Create it? [Y/n]: ").strip().lower()
        if create_confirm not in ('', 'y', 'yes'):
            print("Cancelled.")
            sys.exit(0)
        try:
            os.makedirs(destination_directory, exist_ok=True)
            print(f"Created destination folder: {destination_directory}")
        except Exception as e:
            print(f"Failed to create destination folder {destination_directory}: {e}")
            sys.exit(1)

    # Process libraries
    for source_directory in source_directories:
        library_name = os.path.basename(os.path.normpath(source_directory))
        final_destination = os.path.join(destination_directory, library_name)
        print(f"\nProcessing library: {source_directory}")
        print(f"Destination subdirectory: {final_destination}")
        resize_and_copy_jpgs(source_directory, final_destination)

    print("\n=== Complete ===")