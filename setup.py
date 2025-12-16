import subprocess
import platform
import sys
import shutil

EQUAL_SPACE = "=" * 50

def run_command(cmd: str, shell = False):
    try:
        if isinstance(cmd, str) and not shell:
            cmd = cmd.split()

        result = subprocess.run(cmd, check=True, shell=shell, capture_output=True, text=True)
        return result.returncode == 0
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        return False

def check_command_exists(cmd: str):
    return shutil.which(cmd) is not None

def setup_linux():
    print("Detected Linux/WSL")
    print("\nUpdating package lists...")
    run_command("sudo apt update")

    packages = {
        "Essential build tools": ["build-essential", "cmake", "curl", "wget", "git"],
        "Mason dependencies": ["unzip", "python3-pip", "python3-venv", "ripgrep"],
        "Go": ["golang-go"],
        "C/C++ tools": ["clang", "gdb", "valgrind"]
    }

    for category, pkgs in packages.items():
        print(f"\nInstalling {category}...")
        cmd = ["sudo", "apt", "install", "-y"] + pkgs
        run_command(cmd)

    print("\nInstalling Node.js...")
    run_command("curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -", shell=True)
    run_command("sudo apt install -y nodejs")
    print("Changing timezone to Argentina, Buenos Aires")
    run_command("sudo timedatectl set-timezone America/Argentina/Buenos_Aires")

def setup_windows():
    print("Detected Windows")

    if not check_command_exists("scoop"):
        print("\nScoop is not installed!")
        print("Please install Scoop first by running this in PowerShell:")
        print('  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser')
        print('  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression')
        sys.exit(1)

    packages = {
        "Essential build tools": ["mingw", "cmake", "curl", "wget", "git"],
        "Mason dependencies": ["unzip", "ripgrep"],
        "Go": ["go"],
        "Node.js": ["nodejs"],
        "C/C++ tools": ["llvm", "gdb"]
    }

    for category, pkgs in packages.items():
        print(f"\nInstalling {category}...")
        for pkg in pkgs:
            print(f"  Installing {pkg}...")
            run_command(f"scoop install {pkg}")

def print_versions():
    print("\n" + EQUAL_SPACE)
    print("Setup complete!")
    print(EQUAL_SPACE)
    print("\nInstalled versions:")

    version_commands = {
        "Go": "go version",
        "Node": "node --version",
        "npm": "npm --version",
        "Python": "python3 --version",
        "Clang": "clang --version"
    }

    for name, cmd in version_commands.items():
        try:
            result = subprocess.run(cmd.split(), capture_output=True, text=True, check=True)
            version = result.stdout.strip().split('\n')[0]
            print(f"  {name:8} {version}")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print(f"  {name:8} Not found or not in PATH")

def main():
    print(EQUAL_SPACE)
    print("Development Environment Setup")
    print(EQUAL_SPACE)

    system = platform.system()

    if system == "Linux":
        setup_linux()
    elif system == "Windows":
        setup_windows()
    else:
        print(f"Unsupported platform: {system}")
        sys.exit(1)

    print_versions()

    print("\nNext steps:")
    print("  1. Restart your terminal")
    print("  2. Open Neovim - Mason will auto-install LSP servers")
    print("")

if __name__ == "__main__":
    main()
