#!/bin/bash
set -e

# Wait for cloud-init network to be ready
sleep 30

# Update packages
apt-get update -y && apt-get upgrade -y

# Install Java
apt-get install -y fontconfig openjdk-21-jre

# Add Jenkins repo key
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repo
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
  > /etc/apt/sources.list.d/jenkins.list

# Install Jenkins
apt-get update -y
apt-get install -y jenkins

# Enable and start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Verify service
systemctl status jenkins --no-pager || journalctl -xeu jenkins --no-pager
