from requests import get
from datetime import datetime as dt
import json
with open('whyred_stable.json', 'wb') as load:
    load.write(get("https://raw.githubusercontent.com/XiaomiFirmwareUpdater/xiaomifirmwareupdater.github.io/master/data/devices/latest/stable/whyred.json").content)
fw_stable = json.loads(open('whyred_stable.json').read())
with open('whyred_weekly.json', 'wb') as load:
    load.write(get("https://raw.githubusercontent.com/XiaomiFirmwareUpdater/xiaomifirmwareupdater.github.io/master/data/devices/latest/weekly/whyred.json").content)
fw_weekly = json.loads(open('whyred_weekly.json').read())
stable_date = dt.strptime(fw_stable[0]["date"], "%Y-%m-%d")
weekly_date = dt.strptime(fw_weekly[0]["date"], "%Y-%m-%d")
if stable_date > weekly_date:
    URL="https://bigota.d.miui.com/"
    URL+=fw_stable[0]["versions"]["miui"]
    URL+="/"
    file=fw_stable[0]["file"]
    file=file[10:]
    URL+=file
    print("Fetching Stable ROM......")
else:
    URL="https://bigota.d.miui.com/"
    URL+=fw_weekly[0]["versions"]["miui"]
    URL+="/"
    file=fw_weekly[0]["file"]
    file=file[10:]
    URL+=file
    print(URL)
    print("Fetching Weekly ROM......")
with open('rom.zip', 'wb') as load:
    load.write(get(URL).content)
