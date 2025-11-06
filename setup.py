#!/usr/bin/env python3
"""
Setup script for SoBrief scraper
Installs dependencies and configures Playwright
"""

import subprocess
import sys
import os

def run_command(command):
    """Run a command and handle errors"""
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(f"✓ {command}")
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"✗ {command}")
        print(f"Error: {e.stderr}")
        return None

def main():
    """Main setup function"""
    print("Setting up SoBrief scraper environment...")
    
    # Install Python dependencies
    print("\n1. Installing Python dependencies...")
    run_command(f"{sys.executable} -m pip install --upgrade pip")
    run_command(f"{sys.executable} -m pip install -r requirements.txt")
    
    # Install Playwright browsers
    print("\n2. Installing Playwright browsers...")
    run_command("playwright install chromium")
    
    # Create output directory
    print("\n3. Creating output directory...")
    os.makedirs("sobrief_frontend", exist_ok=True)
    print("✓ Created sobrief_frontend directory")
    
    print("\n✅ Setup complete! You can now run the scraper with:")
    print("python sobrief_scraper.py")

if __name__ == "__main__":
    main()