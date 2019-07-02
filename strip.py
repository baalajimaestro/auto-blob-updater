import os
API_KEY=os.environ.get("API_KEY", None)
GH_PERSONAL_TOKEN=API_KEY.split(" ")[0]
BOT_API_KEY=API_KEY.split(" ")[1]
with open('/tmp/tg_token','wb') as load:
    load.write(str.encode(BOT_API_KEY))
with open('/tmp/GH_TOKEN','wb') as load:
    load.write(str.encode(GH_PERSONAL_TOKEN))
