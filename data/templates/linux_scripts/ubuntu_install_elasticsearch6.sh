#!/usr/bin/env bash
#
# Script to install Elasticsearch 6 on Ubuntu
#
# This file is generated by l2tdevtools update-dependencies.py.

# Exit on error.
set -e

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -q
sudo apt-get install -y apt-transport-https

# Add the Elasticseach repository key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Add the Elasticseach repository
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list

sudo apt-get update -q

# Install Elasticsearch 6
sudo apt-get install -y elasticsearch

sudo service elasticsearch start
sudo systemctl enable elasticsearch

# Install the Elasticsearch 6 Python bindings
sudo apt-get install -y python3-elasticsearch6
