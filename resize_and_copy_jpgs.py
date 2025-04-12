import os
import sys
from PIL import Image

def resize_and_copy_jpgs(source_dir, destination_dir, max_height=1080):
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
    # Keep track of all valid destination files
    valid_destination_files = set()

    for root, _, files in os.walk(source_dir):
        for file in files:
            if file.lower().endswith(".jpg"):
                source_path = os.path.join(root, file)
                
                # Create the corresponding subdirectory in the destination
                relative_path = os.path.relpath(root, source_dir)
                destination_subdir = os.path.join(destination_dir, relative_path)
                if not os.path.exists(destination_subdir):
                    os.makedirs(destination_subdir)
                
                destination_path = os.path.join(destination_subdir, file)
                valid_destination_files.add(destination_path)

                try:
                    # Open the image
                    with Image.open(source_path) as img:
                        # Resize if the height exceeds max_height
                        if img.height > max_height:
                            aspect_ratio = img.width / img.height
                            new_height = max_height
                            new_width = int(new_height * aspect_ratio)
                            img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

                        # Save the resized image to the destination
                        img.save(destination_path, "JPEG")
                        print(f"Copied and resized: {source_path} -> {destination_path}")
                except Exception as e:
                    print(f"Failed to process {source_path}: {e}")

    # Remove files in the destination that are not in the source
    for root, _, files in os.walk(destination_dir):
        for file in files:
            destination_path = os.path.join(root, file)
            if destination_path not in valid_destination_files:
                os.remove(destination_path)
                print(f"Removed: {destination_path}")

    # Remove empty directories in the destination
    for root, dirs, _ in os.walk(destination_dir, topdown=False):
        for dir in dirs:
            dir_path = os.path.join(root, dir)
            if not os.listdir(dir_path):  # Check if the directory is empty
                os.rmdir(dir_path)
                print(f"Removed empty directory: {dir_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python resize_and_copy_jpgs.py <source_directory> <destination_directory>")
        sys.exit(1)

    source_directory = sys.argv[1]
    destination_directory = sys.argv[2]

    resize_and_copy_jpgs(source_directory, destination_directory)