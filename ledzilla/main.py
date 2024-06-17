import requests
import psycopg2
from datetime import datetime

# custom columns values
parsed_timestamp_var = datetime.now()   #.isoformat(" ", "seconds")
name_var = 'name name'

# pull orders
token = 'eyJhbGciOiJFUzI1NiIsImtpZCI6IjIwMjQwNTA2djEiLCJ0eXAiOiJKV1QifQ.eyJlbnQiOjEsImV4cCI6MTczMzc4NDM1MSwiaWQiOiJlOTg5NmU2Ni03MzlkLTQ1OGQtYTdjOC05ZTNmNDc4ZTEwMDkiLCJpaWQiOjMzNjIyMzkxLCJvaWQiOjEwNDY5MiwicyI6MTA3Mzc0MTgyNCwic2lkIjoiMWNlNjFmMTAtMjk3Yi01ZjU0LTkzMDQtZWMxODQ1YTFmZTRlIiwidCI6dHJ1ZSwidWlkIjozMzYyMjM5MX0.QXMYCOSGIKyCy4IQTfm9VKS8Qjju9NmHRq19G3TzSxYYOg-_I7cCoQyrC_pCT9MojyPraeaaz8LMZ0dXmfVaOw'
url = 'https://statistics-api-sandbox.wildberries.ru/api/v1/supplier/orders'
headers = {'Authorization': token}
params = {'dateFrom': "1017-03-25T00:00:00"}
response = requests.get(url, headers=headers, params=params).json()

for item in response:
    print(item)

pass
# push orders to remote
conn = psycopg2.connect(
    database="db",
    user="usr",
    password="ledzilla",
    host="rc1d-bn8fs5z95c3diqqu.mdb.yandexcloud.net",
    port="6432")

cursor = conn.cursor()

query = '''INSERT INTO "LEDZILLA"."WB API" VALUES(%s, %s, %s, %s, %s, %s, %s, %s)'''

for order in response:
    values = tuple([
        order['nmId'],
        order['warehouseName'],
        order['regionName'],
        order['gNumber'],
        order['srid'],
        datetime.strptime(order['date'], '%Y-%m-%dT%H:%M:%SZ'),
        parsed_timestamp_var,
        name_var]
        )
    cursor.execute(query, values)

conn.commit()
conn.close()
