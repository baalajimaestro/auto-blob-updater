#! /bin/bash
##### Script to auto-extract blobs and push them.
##### No more blob kang issue

python3 get_rom.py
unzip rom.zip -d miui
git clone https://github.com/LineageOS/android_vendor_lineage vendor/lineage
bash extract-utils.sh miui
bash setup-makefiles.sh
