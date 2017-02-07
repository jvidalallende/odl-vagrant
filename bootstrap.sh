#!/bin/bash

echo "Installing dependencies..."
sudo apt-get install -y git openjdk-8-jdk-headless maven tmux git-review

echo "Configuring environment variables..."
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bash_profile
echo "export MAVEN_OPTS='-Xmx1048m'" >> ~/.bash_profile

echo "Retrieving Opendaylight's Maven settings.xml..."
mkdir -p ~/.m2/
wget -q -O - https://raw.githubusercontent.com/opendaylight/odlparent/master/settings.xml > ~/.m2/settings.xml

echo "Configuring jvidalallende's environment..."
mkdir ~/GIT
git clone https://github.com/jvidalallende/config-files.git ~/GIT/config-files
git clone https://github.com/drmad/tmux-git ~/GIT/tmux-git
ln -s ~/GIT/config-files/vimrc ~/.vimrc
ln -s ~/GIT/config-files/vim ~/.vim
ln -s ~/GIT/config-files/tmux.conf ~/.tmux.conf
ln -s ~/GIT/config-files/bash_aliases ~/.bash_aliases
echo '. ~/GIT/config-files/bashrc' >> ~/.bashrc
echo '. ~/.bashrc' >> ~/.bash_profile

echo "Cloning SFC and NetVirt repositories..."
git clone https://github.com/opendaylight/sfc.git ~/odl-sfc
git clone https://github.com/opendaylight/netvirt.git ~/odl-netvirt
