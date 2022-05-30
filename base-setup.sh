#!/bin/bash

CONFIG_DIR="configs"

# install base tools
sudo apt install vim

# move dot files into home directory
cp "$CONFIG_DIR/.bashrc" "$CONFIG_DIR/.bash_prompt" "$HOME"

# install docker via official install script
curl -sSL https://get.docker.com | sh
