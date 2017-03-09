#!/bin/bash

# Setup your username for OpenDaylight's gerrit
ODL_USERNAME="juanvidal"

# Distribution name, as stored in opendaylight nexus
DISTRIBUTION_NAME="distribution-karaf-0.6.0-*.tar.gz"

# This global variable stores the PID for the download of ODL distribution
# It is ugly to use global variables, but using local ones and waiting for
# them to be returned seems to be locking in bash, thus avoiding the
# background processing that is intended
WAIT_PID=0

function get_odl_distribution_in_background {
    local snapshot_url="https://nexus.opendaylight.org/content/repositories/opendaylight.snapshot"
    local distribution_path="org/opendaylight/integration/distribution-karaf/0.6.0-SNAPSHOT/"
    local url=${snapshot_url}/${distribution_path}

    # This command does the following:
    # 1) retrieve the directory listing of snapshots (curl)
    # 2) get the distribution gzipped tarballs only, skipping checkum files (grep 'tar.gz' | grep -vE '(md5|sha1)'
    # 3) from the latest one, extract the URL, which is enclosed into double
    #    quotes (tail -n1 | cut -d '"' -f2)
    latest_distribution_url=$(curl --silent ${url} | grep 'tar.gz' | grep -vE '(md5|sha1)' | tail -n1 | cut -d'"' -f2)
    wget -o /tmp/wget.log -q ${latest_distribution_url} &
    WAIT_PID=$!
}

function wait_for_odl_distribution {
    if [ ${WAIT_PID} -ne 0 ]; then
        wait ${WAIT_PID}
    else
        echo "Error downloading ODL distribution"
        exit 1
    fi
}

function install_packages {
    sudo apt-get update -y
    sudo apt-get install -y \
        git\
        openjdk-8-jdk-headless\
        maven\
        tmux\
        git-review \
        openvswitch-switch
}

function configure_java_env {
    echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bash_profile
    echo "export MAVEN_OPTS='-Xmx2048m'" >> ~/.bash_profile
}

function retrieve_odl_maven_settings {
    mkdir -p ~/.m2/
    local settings_url="https://raw.githubusercontent.com/opendaylight/odlparent/master/settings.xml"
    wget -q -O - ${settings_url} > ~/.m2/settings.xml
}

function get_odl_repositories {
    git clone https://github.com/opendaylight/sfc.git ~/odl-sfc
    git clone https://github.com/opendaylight/netvirt.git ~/odl-netvirt
    git clone https://github.com/opendaylight/docs.git ~/odl-docs
}

function install_git_hooks {
    local hook_url="git.opendaylight.org:hooks/commit-msg"
    local ssh_options="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    scp ${ssh_options} -p -P 29418 ${ODL_USERNAME}@${hook_url} /tmp/commit-msg
    chmod 755 /tmp/commit-msg
    cp /tmp/commit-msg ~/odl-sfc/.git/hooks/commit-msg
    cp /tmp/commit-msg ~/odl-netvirt/.git/hooks/commit-msg
    rm /tmp/commit-msg
}

function build_ovs_with_nsh {
    sudo apt-get install -y \
        libtool\
        m4\
        autoconf\
        automake\
        make\
        libssl-dev\
        libcap-ng-dev\
        python3\
        python-six\
        vlan\
        iptables

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
}

function extract_odl_distribution {
    tar xzf ${DISTRIBUTION_NAME}
    rm ${DISTRIBUTION_NAME}
}


# Execution section

echo "Retrieving ODL distribution in background..."
get_odl_distribution_in_background
echo "Installing dependencies..."
install_packages
echo "Configuring environment variables..."
configure_java_env
echo "Retrieving Opendaylight's Maven settings.xml..."
retrieve_odl_maven_settings
echo "Cloning SFC and NetVirt repositories..."
get_odl_repositories
echo "Installing git hooks..."
install_git_hooks
echo "Building OvS with NSH support..."
build_ovs_with_nsh
echo "Waiting for ODL distribution download to finish..."
wait_for_odl_distribution
echo "Extracting ODL distribution..."
extract_odl_distribution
