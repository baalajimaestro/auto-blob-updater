
#!/bin/bash
# Copyright (C) 2019 The Raphielscape Company LLC.
#
# Licensed under the Raphielscape Public License, Version 1.b (the "License");
# you may not use this file except in compliance with the License.
#
# CI Runner Script for Generation of blobs

# We need this directive
# shellcheck disable=1090


##### Build Env Dependencies
build_env()
{
. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/telegram
TELEGRAM_TOKEN=$(cat /tmp/tg_token)
export TELEGRAM_TOKEN
tg_sendinfo "<code>[RashedCI]: Vendor Cron Job rolled!</code>"
cd ~
git clone https://github.com/akhilnarang/scripts > /dev/null 2>&1
cd scripts
bash setup/android_build_env.sh  > /dev/null 2>&1
echo "Build Dependencies Installed....."
sudo unlink /usr/bin/python
sudo apt-get install p7zip-full p7zip-rar -y > /dev/null 2>&1
sudo ln -s /usr/bin/python2.7 /usr/bin/python
sudo apt install brotli -y  > /dev/null 2>&1
cd ..
rm -rf scripts
}
##### Build Configs

build_conf()
{
mkdir repo
cd repo
git config --global user.email "asifrashed2@gmail.com"
git config --global user.name "rashedsahaji"
curl -sL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py > /dev/null 2>&1
sudo python3 -m pip install requests  > /dev/null 2>&1
export LOC=$(cat /tmp/loc)
}

##### Initialise Repo with lineage-16.0

init_repo()
{
echo "Repo initialised......."
repo init -u https://github.com/MoKee/android.git -b mkp --depth=1 > /dev/null 2>&1
echo "Repo Syncing started......"
repo sync -j20 --no-tags --no-clone-bundle -c > /dev/null 2>&1
echo -e "\e[32mRepo Synced....."
}

##### Clone DT and gear up for blob extraction

# git clone https://github.com/baalajimaestro/LineageOS_DT device/xiaomi/whyred > /dev/null 2>&1
dt()
{
git clone https://github.com/GuaiYiHu/android_device_xiaomi_violet device/xiaomi/violet > /dev/null 2>&1
cd device/xiaomi/violet
git clone https://github.com/GuaiYiHu/android_vendor_xiaomi_violet vendor/xiaomi/violet > /dev/null 2>&1
}
##### Fetch MIUI-Chinese ROM latest
rom()
{
mkdir extract
sudo mv $LOC/get_rom.py get_rom.py
python3 get_rom.py
unzip rom.zip -d miui > /dev/null 2>&1
cd miui
}
##### Workaround for > Android 8.1 using brotli
dec_brotli()
{
brotli --decompress system.new.dat.br
brotli --decompress vendor.new.dat.br
echo "Brotli decompressed."
}
##### Convert our dat files into raw images
sdatimg()
{
curl -sLo sdat2img.py https://raw.githubusercontent.com/xpirt/sdat2img/master/sdat2img.py
python3 sdat2img.py system.transfer.list system.new.dat > /dev/null 2>&1
python3 sdat2img.py vendor.transfer.list vendor.new.dat vendor.img > /dev/null 2>&1
mv system.img ../extract
mv vendor.img ../extract
}
##### Workaround the inability to mount images on drone CI
extract()
{
cd ../extract
mkdir system
7z x system.img -y -osystem > /dev/null 2>&1
mkdir vendor
7z x vendor.img -y -ovendor > /dev/null 2>&1
cd ..
}
##### Here's the blecc megik
gen_blob()
{
bash extract-files.sh extract > /dev/null 2>&1
bash setup-makefiles.sh > /dev/null 2>&1
echo "Blobs Generated!"
}
##### Push the vendor
push_vendor()
{
cd /home/ci/repo/vendor/xiaomi/violet
git init
git add .
git checkout -b $(cat /tmp/version)
git commit -m "[RashedCI]: Re-gen Blobs" --signoff
git remote add origin https://rashedsahaji:$(cat /tmp/GH_TOKEN)@github.com/rashedsahaji/vendor_xiaomi_violet.git
git remote rm origin
git push --force origin $(cat /tmp/version)
tg_sendinfo "<code>Checked out and pushed Vendor Blobs for MIUI Version $(cat /tmp/version)</code>"
echo "Job Successful!"
}



build_env
build_conf
init_repo
dt
rom
dec_brotli
sdatimg
extract
gen_blob
push_vendor
