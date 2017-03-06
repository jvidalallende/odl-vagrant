#!/bin/bash

# Setup your username for OpenDaylight's gerrit
ODL_USERNAME=JuanVidal

echo "Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y \
    git\
    openjdk-8-jdk-headless\
    maven\
    tmux\
    git-review \
    openvswitch-switch

echo "Configuring environment variables..."
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bash_profile
echo "export MAVEN_OPTS='-Xmx2048m'" >> ~/.bash_profile

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
git clone https://github.com/opendaylight/docs.git ~/odl-docs

echo "Installing git hooks..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p -P 29418 $ODL_USERNAME@git.opendaylight.org:hooks/commit-msg /tmp/commit-msg
chmod 755 /tmp/commit-msg
cp /tmp/commit-msg ~/odl-sfc/.git/hooks/commit-msg
cp /tmp/commit-msg ~/odl-netvirt/.git/hooks/commit-msg

echo "Building OvS with NSH support..."
sudo apt-get install -y libtool m4 autoconf automake make libssl-dev libcap-ng-dev python3 python-six vlan iptables
git clone https://github.com/openvswitch/ovs.git
git clone https://github.com/yyang13/ovs_nsh_patches.git
cd ovs
git reset --hard v2.6.1
cp ../ovs_nsh_patches/v2.6.1/*.patch ./
git config user.email "nsh_patcher@ovs_user.com"
git config user.name "nsh_patcher"
git am *.patch
./boot.sh
./configure --prefix=/usr --with-linux=/lib/modules/`uname -r`/build
sudo make -j3 modules_install
sudo make install
sudo systemctl restart openvswitch-switch
cd ~
