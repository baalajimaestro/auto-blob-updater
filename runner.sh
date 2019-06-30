#! /bin/bash
##### Script to auto-extract blobs and push them.
##### No more blob kang issue
echo "***Auto Blob Updater***"
apt update > /dev/null 2>&1
apt upgrade -y > /dev/null 2>&1
apt install sudo git lsb-core apt-utils -y > /dev/null 2>&1
echo 'Initial dependencies Installed'
sudo echo "ci ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
useradd -m -d /home/ci ci
useradd -g ci wheel
echo `pwd` > /tmp/loc
sudo -Hu ci bash -c "bash runner_user.sh"
