#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Update package list and install necessary packages
sudo yum update -y
sudo yum install -y \
    git \
    python3 \
    python3-pip

# Clean up
sudo yum clean all

# Install Flask and SQLite
pip3 install flask flask-SQLAlchemy

# Set the working directory inside the container
mkdir -p /app
cd /app

# Clone the git repository
git clone https://github.com/Venkatakarthik0211/Zeek-ELK.git

# Navigate to the specified directory
cd /app/Zeek-ELK/aws-basics/aws/three-tier

# Run app.py
python3 app.py
