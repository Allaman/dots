#!/bin/bash

# SMB Share Mover Script
# Copies all files from an SMB share to a destination using gopass for authentication
# Written by Claude

set -euo pipefail

# Configuration - modify these variables as needed
SMB_SERVER="//192.168.178.62/scan"
GOPASS_USERNAME_PATH="unraid/share/user"
GOPASS_PASSWORD_PATH="unraid/share/pass"
LOCAL_DESTINATION="$HOME/Downloads/todo-scan/"
MOUNT_POINT="/tmp/smb_mount_$$"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function to cleanup on exit
cleanup() {
  if mountpoint -q "$MOUNT_POINT" 2>/dev/null || [[ "$OS" == "macos" && -d "$MOUNT_POINT" && $(ls -A "$MOUNT_POINT" 2>/dev/null) ]]; then
    print_status "Unmounting SMB share..."
    if [[ "$OS" == "macos" ]]; then
      umount "$MOUNT_POINT" || print_warning "Failed to unmount $MOUNT_POINT"
    else
      sudo umount "$MOUNT_POINT" || print_warning "Failed to unmount $MOUNT_POINT"
    fi
  fi

  if [ -d "$MOUNT_POINT" ]; then
    rmdir "$MOUNT_POINT" || print_warning "Failed to remove mount point directory"
  fi
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM

# Detect operating system
detect_os() {
  case "$(uname -s)" in
  Darwin*) OS="macos" ;;
  Linux*) OS="linux" ;;
  *) OS="unknown" ;;
  esac
}

# Check if required tools are installed
check_dependencies() {
  local missing_deps=()

  if ! command -v gopass &>/dev/null; then
    missing_deps+=("gopass")
  fi

  # On macOS, SMB mounting is built-in, on Linux we need cifs-utils
  if [[ "$OS" == "linux" ]] && ! command -v mount.cifs &>/dev/null; then
    missing_deps+=("cifs-utils")
  fi

  if [ ${#missing_deps[@]} -ne 0 ]; then
    print_error "Missing required dependencies: ${missing_deps[*]}"
    print_error "Please install them first:"
    if [[ "$OS" == "macos" ]]; then
      print_error "  macOS: brew install gopass"
    else
      print_error "  Ubuntu/Debian: sudo apt install gopass cifs-utils"
      print_error "  CentOS/RHEL: sudo yum install gopass cifs-utils"
      print_error "  Arch: sudo pacman -S gopass cifs-utils"
    fi
    exit 1
  fi
}

# Get credentials from gopass
get_credentials() {
  print_status "Retrieving credentials from gopass..."

  if ! USERNAME=$(gopass show -o "$GOPASS_USERNAME_PATH" 2>/dev/null); then
    print_error "Failed to retrieve username from gopass path: $GOPASS_USERNAME_PATH"
    print_error "Make sure the path exists in your gopass store"
    exit 1
  fi

  if ! PASSWORD=$(gopass show -o "$GOPASS_PASSWORD_PATH" 2>/dev/null); then
    print_error "Failed to retrieve password from gopass path: $GOPASS_PASSWORD_PATH"
    print_error "Make sure the path exists in your gopass store"
    exit 1
  fi

  if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    print_error "Username or password is empty"
    exit 1
  fi

  print_status "Credentials retrieved successfully"
}

# Create mount point and destination directory
prepare_directories() {
  print_status "Preparing directories..."

  # Create mount point
  if ! mkdir -p "$MOUNT_POINT"; then
    print_error "Failed to create mount point: $MOUNT_POINT"
    exit 1
  fi

  # Create destination directory
  if ! mkdir -p "$LOCAL_DESTINATION"; then
    print_error "Failed to create destination directory: $LOCAL_DESTINATION"
    exit 1
  fi
}

# Mount the SMB share
mount_smb_share() {
  print_status "Mounting SMB share: $SMB_SERVER"

  if [[ "$OS" == "macos" ]]; then
    # macOS uses mount_smbfs
    if ! mount -t smbfs "//$USERNAME:$PASSWORD@${SMB_SERVER#//}" "$MOUNT_POINT"; then
      print_error "Failed to mount SMB share on macOS"
      print_error "Please check:"
      print_error "  - Server address: $SMB_SERVER"
      print_error "  - Network connectivity"
      print_error "  - Credentials"
      print_error "  - Share permissions"
      exit 1
    fi
  else
    # Linux uses mount.cifs with sudo
    if ! sudo mount -t cifs "$SMB_SERVER" "$MOUNT_POINT" \
      -o username="$USERNAME",password="$PASSWORD",uid=$(id -u),gid=$(id -g),iocharset=utf8,file_mode=0644,dir_mode=0755; then
      print_error "Failed to mount SMB share on Linux"
      print_error "Please check:"
      print_error "  - Server address: $SMB_SERVER"
      print_error "  - Network connectivity"
      print_error "  - Credentials"
      print_error "  - Share permissions"
      exit 1
    fi
  fi

  print_status "SMB share mounted successfully"
}

# Copy files from SMB share to local destination, then delete from source
move_files() {
  print_status "Moving files from $MOUNT_POINT to $LOCAL_DESTINATION..."

  # Check if mount point has any files
  if [ -z "$(ls -A "$MOUNT_POINT" 2>/dev/null)" ]; then
    print_warning "No files found in SMB share or share is empty"
    FILES_MOVED=0
    return 0
  fi

  # Count files before moving
  local files_to_move
  files_to_move=$(find "$MOUNT_POINT" -type f | wc -l)

  # First copy files, then delete from source
  if command -v rsync &>/dev/null; then
    print_status "Using rsync for file move..."
    if rsync -avh --progress --remove-source-files "$MOUNT_POINT/" "$LOCAL_DESTINATION/"; then
      print_status "Files moved successfully using rsync"
      # Remove empty directories left behind by rsync
      find "$MOUNT_POINT" -type d -empty -delete 2>/dev/null || true
      FILES_MOVED=$files_to_move
    else
      print_error "rsync failed, falling back to cp+rm"
      move_with_cp_rm
    fi
  else
    print_status "rsync not available, using cp+rm..."
    move_with_cp_rm
  fi

  # Wait for any remaining file operations to complete
  print_status "Ensuring all file operations are complete..."
  sync
  sleep 3
}

# Fallback move method using cp and rm
move_with_cp_rm() {
  # Count files before moving
  local files_to_move
  files_to_move=$(find "$MOUNT_POINT" -type f | wc -l)

  print_status "Copying files first..."
  if cp -r "$MOUNT_POINT"/* "$LOCAL_DESTINATION/" 2>/dev/null; then
    print_status "Files copied successfully, now removing from source..."
    if rm -rf "$MOUNT_POINT"/* 2>/dev/null; then
      print_status "Files moved successfully using cp+rm"
      FILES_MOVED=$files_to_move
    else
      print_error "Files copied but failed to delete from source"
      print_warning "You may need to manually clean up files on the SMB share"
      FILES_MOVED=0
    fi
  else
    print_error "Failed to copy files"
    FILES_MOVED=0
    exit 1
  fi
}

# Show summary
show_summary() {
  print_status "Move operation completed!"

  if [ "${FILES_MOVED:-0}" -eq 0 ]; then
    print_status "No files were moved"
  else
    print_status "Files moved: $FILES_MOVED"

    # Show total files now in destination for reference
    local total_files_in_dest
    total_files_in_dest=$(find "$LOCAL_DESTINATION" -type f | wc -l)
    print_status "Total files in destination: $total_files_in_dest"
  fi

  print_status "Destination: $LOCAL_DESTINATION"
}

# Main execution
main() {
  print_status "Starting SMB share move operation..."
  print_status "SMB Server: $SMB_SERVER"
  print_status "Destination: $LOCAL_DESTINATION"

  # Initialize files moved counter
  FILES_MOVED=0

  detect_os
  print_status "Detected OS: $OS"

  check_dependencies
  get_credentials
  prepare_directories
  mount_smb_share
  move_files

  # Explicitly unmount before showing summary to avoid cleanup issues
  print_status "Unmounting SMB share..."
  if [[ "$OS" == "macos" ]]; then
    umount "$MOUNT_POINT" || print_warning "Failed to unmount $MOUNT_POINT"
  else
    sudo umount "$MOUNT_POINT" || print_warning "Failed to unmount $MOUNT_POINT"
  fi

  # Remove mount point directory
  if [ -d "$MOUNT_POINT" ]; then
    rmdir "$MOUNT_POINT" || print_warning "Failed to remove mount point directory"
  fi

  # Disable cleanup trap since we've already cleaned up
  trap - EXIT INT TERM

  show_summary
  print_status "Script completed successfully!"
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
