import os

def generate_gitignore(file_names, file_types, folders):
    # Check if there's anything to ignore
    if not file_names and not file_types and not folders:
        print("No file name, file type, or folder specified. Nothing to ignore.")
        return

    gitignore_content = []

    # Ignore specific file names
    if file_names:
        gitignore_content.extend(file_names)

    # Ignore specific file types
    if file_types:
        gitignore_content.extend(['*.' + file_type for file_type in file_types])

    # Ignore specific folders
    if folders:
        gitignore_content.extend([folder + '/' for folder in folders])

    # Get the current working directory
    current_directory = os.getcwd()

    # Check if .gitignore file already exists
    gitignore_path = os.path.join(current_directory, '.gitignore')
    if os.path.exists(gitignore_path):
        # Read existing content and update it
        with open(gitignore_path, 'r') as existing_gitignore:
            existing_content = existing_gitignore.read().splitlines()
            gitignore_content.extend(existing_content)

    # Write to .gitignore file
    with open(gitignore_path, 'w') as gitignore_file:
        gitignore_file.write('\n'.join(gitignore_content))

    print(".gitignore file generated/updated successfully!")

if __name__ == "__main__":
    print("Gitignore Generator")

    # Get user inputs
    file_names = input("Enter file names to ignore (comma-separated, e.g., 'myfile.txt,anotherfile.txt'): ").split(',')
    file_types = input("Enter file types to ignore (comma-separated, without dots, e.g., 'txt,zip'): ").split(',')
    folders = input("Enter folders to ignore (comma-separated, e.g., 'myfolder,.anotherfolder'): ").split(',')

    # Remove leading/trailing whitespaces and ignore if all inputs are empty
    file_names = [name.strip() for name in file_names if name.strip()]
    file_types = [ftype.strip() for ftype in file_types if ftype.strip()]
    folders = [folder.strip() for folder in folders if folder.strip()]

    # Generate .gitignore if there's anything to ignore
    generate_gitignore(file_names, file_types, folders)
