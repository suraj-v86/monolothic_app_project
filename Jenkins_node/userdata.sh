#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/userdata.log|logger -t userdata -s 2>/dev/console) 2>&1

# Avoid interactive prompts
export DEBIAN_FRONTEND=noninteractive

# Update packages
apt-get update -y
apt-get upgrade -y

# Install Java (Jenkins node requirement)
apt-get install -y openjdk-11-jre-headless

# Verify Java installation
java -version
