#!/usr/bin/env bash

# This script installs dependencies needed to build CRRCSim on Mac OS.



# Installing the XCode Developer Tools
# Non-interactive installation inspired by brew's installation script,
# see: https://raw.githubusercontent.com/Homebrew/install/master/install
if [ -z "$(ls -A /Library/Developer/CommandLineTools)" ]; then
  CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  sudo touch $CLT_PLACEHOLDER
  CLT_LABEL=`softwareupdate -l | grep -B 1 -E "Command Line (Developer|Tools)" | awk -F"*" '/^ +\\*/ {print $2}' | sed 's/^ *//' | tail -n1 | sed -e 's/[[:space:]]*$//'`
  sudo softwareupdate -i "$CLT_LABEL"
  sudo rm $CLT_PLACEHOLDER
  sudo xcode-select --switch /Library/Developer/CommandLineTools
fi

# Installing MacPorts
if ! type "port" 2> /dev/null; then
  curl -LOs https://github.com/macports/macports-base/releases/download/v2.4.0/MacPorts-2.4.0-10.11-ElCapitan.pkg
  sudo installer -pkg MacPorts-2.4.0-10.11-ElCapitan.pkg -target /
  echo 'export PATH=/opt/local/bin:/opt/local/sbin:$PATH' >> ~/.profile
  echo 'export EDITOR=nano' >> ~/.profile
  source ~/.profile
  sudo port sync
fi

# Installing libraries
sudo port -N install plib jpeg portaudio libsdl gmp cgal

# Installing compiler and build tools
sudo port -N install wget gcc47 dylibbundler
