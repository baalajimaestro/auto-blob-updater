from requests import get
from datetime import datetime as dt
import json
with open('violet_stable.json', 'wb') as load:
    load.write(get("https://raw.githubusercontent.com/XiaomiFirmwareUpdater/xiaomifirmwareupdater.github.io/master/data/devices/latest/stable/violet.json").content)
fw_stable = json.loads(open('violet_stable.json').read())
with open('violet_weekly.json', 'wb') as load:
    load.write(get("https://raw.githubusercontent.com/XiaomiFirmwareUpdater/xiaomifirmwareupdater.github.io/master/data/devices/latest/weekly/violet.json").content)
fw_weekly = json.loads(open('violet_weekly.json').read())
stable_date = dt.strptime(fw_stable[1]["date"], "%Y-%m-%d")
weekly_date = dt.strptime(fw_weekly[1]["date"], "%Y-%m-%d")
if stable_date > weekly_date:
    URL="https://bigota.d.miui.com/"
    version=fw_stable[1]["versions"]["miui"]
    with open('/tmp/version','wb') as load:
        load.write(str.encode(version))
    URL+=version
    URL+="/"
    file=fw_stable[1]["file"]
    file=file[10:]
    URL+=file
    print("Fetching Stable ROM......")
else:
    URL="https://bigota.d.miui.com/"
    version=fw_weekly[1]["versions"]["miui"]
    with open('/tmp/version','wb') as load:
        load.write(str.encode(version))
    URL+=version
    URL+="/"
    file=fw_weekly[1]["file"]
    file=file[10:]
    URL+=file
    print("Fetching Weekly ROM......")
with open('rom.zip', 'wb') as load:
    load.write(get(URL).content)
