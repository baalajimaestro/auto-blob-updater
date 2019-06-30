
cd ~
git clone https://github.com/akhilnarang/scripts > /dev/null 2>&1
cd scripts
bash setup/android_build_env.sh  > /dev/null 2>&1
echo "Build Dependencies Installed....."
cd ..
rm -rf scripts
mkdir repo
cd repo
git config --global user.email "baalajimaestro@computer4u.com"
git config --global user.name "baalajimaestro"
sudo unlink /usr/bin/python
sudo ln -s /usr/bin/python2.7 /usr/bin/python
sudo apt install brotli -y  > /dev/null 2>&1
curl -sL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py > /dev/null 2>&1
sudo python3 -m pip install requests  > /dev/null 2>&1
export LOC=$(cat /tmp/loc)
echo "Repo initialised......."
repo init -u git://github.com/LineageOS/android.git -b lineage-16.0 > /dev/null 2>&1
echo "Repo Syncing started......"
repo sync -j$(nproc) > /dev/null 2>&1
echo "Repo Synced....."
git clone https://github.com/baalajimaestro/LineageOS_DT device/xiaomi/whyred > /dev/null 2>&1
# git clone https://github.com/ResurrectionRemix-Devices/vendor_xiaomi_whyred vendor/xiaomi/whyred > /dev/null 2>&1
ls -la
cd device/xiaomi/whyred
mkdir extract
sudo mv $LOC/get_rom.py get_rom.py
python3 get_rom.py
unzip rom.zip -d miui
cd miui
brotli.exe --decompress --in system.new.dat.br --out system.new.dat
brotli.exe --decompress --in vendor.new.dat.br --out vendor.new.dat
echo "Brotli decompressed."
curl -sLo sdat2img.py https://raw.githubusercontent.com/xpirt/sdat2img/master/sdat2img.py
python3 sdat2img.py system.trasfer.list system.new.dat system.img
python3 sdat2img.py vendor.trasfer.list vendor.new.dat vendor.img
mv system.img ../extract
mv vendor.img ../extract
cd ../extract
mkdir system
sudo mount system.img system
mkdir vendor
sudo mount vendor.img vendor
cd ..
bash extract-files.sh extract
ls -la
