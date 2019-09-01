#!/bin/bash
# Copyright (C) 2019 The Raphielscape Company LLC.
#
# Licensed under the Raphielscape Public License, Version 1.b (the "License");
# you may not use this file except in compliance with the License.
#
# CI Runner Script for Generation of blobs

# We need this directive
# shellcheck disable=1090

build_env() {
    export LOC=$(cat /tmp/loc)
    cd ~
    sudo apt install patchelf brotli unzip p7zip-full zip curl wget gpg python python-kerberos -y > /dev/null 2>&1
    sudo unlink /usr/bin/python
    sudo ln -s /usr/bin/python2.7 /usr/bin/python
    sudo curl -sLo /usr/bin/repo https://storage.googleapis.com/git-repo-downloads/repo
    sudo chmod a+x /usr/bin/repo
    . /drone/src/telegram
    TELEGRAM_TOKEN=$(cat /tmp/tg_token)
    export TELEGRAM_TOKEN
    tg_sendinfo "<code>[MaestroCI]: Vendor Cron Job rolled!</code>"
    pip3 install requests > /dev/null 2>&1
    echo "Build Dependencies Installed....."
}

rom() {
    rm -rf extract
    mkdir extract
    cd extract
    python3 /home/McFy/baalajimaestro/Blobs/auto-blob-updater/get_rom.py
    unzip rom.zip -d miui > /dev/null 2>&1
    cd miui
}

dec_brotli() {
    brotli --decompress system.new.dat.br
    brotli --decompress vendor.new.dat.br
    echo "Brotli decompressed....."
}

sdatimg() {
    echo "Converting to img....."
    curl -sLo sdat2img.py https://raw.githubusercontent.com/xpirt/sdat2img/master/sdat2img.py
    python3 sdat2img.py system.transfer.list system.new.dat > /dev/null 2>&1
    python3 sdat2img.py vendor.transfer.list vendor.new.dat vendor.img > /dev/null 2>&1
}

extract() {
    echo "Extracting the img's....."
    mkdir system
    mkdir vendor
    7z x system.img -y -osystem > /dev/null 2>&1
    7z x vendor.img -y -ovendor > /dev/null 2>&1
    cd ~
}

build_conf() {
    mkdir repo
    cd repo
    git config --global user.email "baalajimaestro@raphielgang.com"
    git config --global user.name "baalajimaestro"
}

init_repo() {
    echo "Repo initialised......."
    repo init -u git://github.com/AOSiP/platform_manifest.git -b pie --depth=1 > /dev/null 2>&1
    echo "Repo Syncing started......"
    repo sync --force-sync --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune -j$(nproc) -q > /dev/null 2>&1
    echo -e "\e[32mRepo Synced....."
}

dt() {
    echo "Cloning device tree......."
    git clone https://github.com/AOSiP-Devices/device_xiaomi_whyred device/xiaomi/whyred > /dev/null 2>&1
    git clone https://github.com/AOSiP-Devices/proprietary_vendor_xiaomi vendor/xiaomi > /dev/null 2>&1
    if [ "$(hostname)" == "Android-A320FL-Build-Box" ]; then
    cd /home/dyneteve/pe/device/xiaomi/whyred
    else
    cd device/xiaomi/whyred
    fi
}

gen_blob() {
    bash extract-files.sh ~/extract/miui
    echo "Blobs Generated!"
}

push_vendor() {
    if [ "$(hostname)" == "Android-A320FL-Build-Box" ]; then
    cd /home/McFy/dyneteve/pe/vendor/xiaomi/whyred
    else
    cd ~/repo/vendor/xiaomi/whyred
    fi
    git remote rm origin
    git remote add origin https://baalajimaestro:$(cat /tmp/GH_TOKEN)@github.com/baalajimaestro/vendor_xiaomi_whyred.git
    git add .
    git commit -m "[MaestroCI]: Re-gen blobs from MIUI $(cat /tmp/version)" --signoff
    git checkout -b $(cat /tmp/version)
    git push --force origin $(cat /tmp/version)
    tg_sendinfo "<code>Checked out and Pushed Vendor Blobs for MIUI $(cat /tmp/version)</code>"
    echo "Job Successful!"
}

if [ "$(hostname)" == "Android-A320FL-Build-Box" ]; then
cd /home/McFy/baalajimaestro/Blobs
tg_sendinfo "<code>[MaestroCI]: Vendor Cron Job rolled!</code>"
rom
dec_brotli
sdatimg
extract
build_conf
cp /home/McFy/baalajimaestro/proprietary-files.txt /home/dyneteve/pe/device/xiaomi/whyred
dt
gen_blob
push_vendor
rm -rf /home/McFy/baalajimaestro/extract
else
build_env
rom
dec_brotli
sdatimg
extract
build_conf
init_repo
dt
gen_blob
push_vendor
fi
