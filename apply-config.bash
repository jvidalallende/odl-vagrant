function configure_development_tools {
    mkdir ~/GIT
    git clone https://github.com/jvidalallende/config-files.git ~/GIT/config-files
    git clone https://github.com/drmad/tmux-git ~/GIT/tmux-git
    ln -s ~/GIT/config-files/vimrc ~/.vimrc
    ln -s ~/GIT/config-files/vim ~/.vim
    ln -s ~/GIT/config-files/tmux.conf ~/.tmux.conf
    ln -s ~/GIT/config-files/bash_aliases ~/.bash_aliases
    echo '. ~/GIT/config-files/bashrc' >> ~/.bashrc
    echo '. ~/.bashrc' >> ~/.bash_profile
}

echo "Configuring jvidalallende's environment..."
configure_development_tools
