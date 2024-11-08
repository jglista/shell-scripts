#! /usr/bin/bash

# This script is used to update the go version on the system

function check_go_version() {
    # check if the version is empty, if it is then check for the latest version
    if [ -z "$version" ]; then
        # get the latest version of go and pull the first line of text from the response
        version=$(curl -s https://go.dev/VERSION?m=TEXT | grep -o '[0-9]*\.[0-9]*\.[0-9]*' | head -n 1)
        if [ $? -ne 0 ]; then
            echo "Failed to get the latest version of go. Exiting..."
            exit 1
        fi
        echo "Latest version of go is $version"
    fi

    # check if the version installed is the same as the version we want to install
    if [ -d /usr/local/go ]; then
        installed_version=$(go version | grep -o 'go[0-9]*\.[0-9]*\.[0-9]*')
        if [ $installed_version == $version ]; then
            echo "Go is already installed on your system. Exiting..."
            exit 0
        fi
    fi
}

function check_go_install() {
    # if skip_prompt is set, remove the current go installation without prompting the user
    if [ "$skip_prompt" == "true" ]; then
        echo "Removing go..."
        clean_go_install
        echo "Go has been removed from your system"
    fi

    # prompt the user if we find a go installation
    if [ -d /usr/local/go ]; then
        echo "Go is already installed on your system. Do you want to update it?"
        read -p "Enter y/n: " response
        if [ $response == "y" ] || [$response == ""]; then
            echo "Removing go..."
            clean_go_install
            echo "Go has been removed from your system"
        else
            echo "Exiting..."
            exit 0
        fi
    fi
}

function clean_go_install() {
    sudo rm -rf /usr/local/go
    sudo rm -rf /usr/local/bin/go
    sudo rm -rf /usr/local/bin/gofmt
    sudo rm -rf /usr/local/bin/godoc
    sudo rm -rf /usr/local/bin/gorename
    sudo rm -rf /usr/local/bin/guru
    sudo rm -rf /usr/local/bin/goreturns
    sudo rm -rf /usr/local/bin/gomvpkg
    sudo rm -rf /usr/local/bin/godex
    sudo rm -rf /usr/local/bin/golint
    sudo rm -rf /usr/local/bin/gocyclo
    sudo rm -rf /usr/local/bin/gocov
    sudo rm -rf /usr/local/bin/gocov-xml
    sudo rm -rf /usr/local/bin/gocov-html
    sudo rm -rf /usr/local/bin/gocov-json
}

function download_go() {
    # download go to user home directory
    wget -ndH -P /home/$USER https://dl.google.com/go/go$version.linux-amd64.tar.gz
    if [ $? -ne 0 ]; then
        echo "Failed to download go. Exiting..."
        exit 1
    else
        echo "Go $1 downloaded successfully"
    fi
}

function install_go() {
    # extract the go tar file to /usr/local from the user home directory
    sudo tar -C /usr/local -xzf /home/$USER/go$version.linux-amd64.tar.gz
    if [ $? -ne 0 ]; then
        echo "Failed to install go. Exiting..."
        clean_downloaded_files
        exit 1
    else
        echo "Go $1 installed successfully"
        clean_downloaded_files
    fi
}

function clean_downloaded_files() {
    # remove the downloaded go tar file from the user home directory
    rm /home/$USER/go$version.linux-amd64.tar.gz
    if [ $? -ne 0 ]; then
        echo "Failed to remove the downloaded go tar file. Exiting..."
        exit 1
    else
        echo "Downloaded go tar file removed successfully"
    fi
}

# parse the command line arguments
# v - version of go to install
# s - skip the prompt to remove the current go installation
while getopts ":v:s" opt; do
    case $opt in
    v)
        version=$OPTARG
        ;;
    s)
        skip_prompt="true"
        ;;
    \?)
        echo "Invalid option: $OPTARG" 1>&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." 1>&2
        exit 1
        ;;
    esac
done

# check if the version is empty, if it is then check for the latest version
check_go_version $skip_prompt

# check if go is already installed on the system
check_go_install $skip_prompt

# download the go version
download_go $version

# install the go version
install_go $version
