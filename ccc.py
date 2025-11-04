#!/usr/bin/env python3

import re
import sys
import json,yaml
import requests
from datetime import datetime, timedelta, date

from diskcache import FanoutCache,Cache
MYcache = Cache('/dev/shm/pycache')

def Myfin_conv(FROM, TO, DATE):
    DATE2=( date .fromisoformat(  DATE )  - timedelta( days  = 1   ) ) .strftime("%d.%m.%Y")
    #print( DATE , DATE2 )
    if TO == 'byn': 
        Q=FROM
        POW=1
    elif FROM == 'byn' :
        Q=TO
        POW=-1
    else:
        raise Exception("can only convert from / to  byn")

    headers = {
        'User-agent': 'curl/7.81.0' ,
        'Accept-Language': 'en-US,en;q=0.9',    # 2024-10-25 added for LTE2122GR_h
        }

    URL=f"https://myfin.by/ajaxnew/pair-rate-chart?type_to={Q}&type_from=byn&sum=1"
    try:
        r=requests.get( URL , headers = headers, timeout=4  ) 
    except Exception as e:
        print(e)
        return None

    if not r.ok:
        raise Exception (f"err getting rate from {URL}")

    for l in r.text.split("\n"):
        if re.search('dataProvider',  l) :
            #print(l)
            DB =  json.loads("{" + l + "}")
            break
    #print(DB)

    for i in DB['dataProvider']:
        if i.get('date') == DATE2:
            RATE=float ( i.get('byn')) ** POW
            break
    return RATE

@MYcache.memoize( expire=3600*24  )
def grandtrunk_get(FROM, TO, DATE):
    URL=f"https://currencies.apps.grandtrunk.net/getrate/{DATE}/{FROM}/{TO}"
    headers = {
        'User-agent': 'curl/7.81.0' ,
        'Accept-Language': 'en-US,en;q=0.9',    # 2024-10-25 added for LTE2122GR_h
        }
    try:
        r=requests.get( URL , headers = headers, timeout=4  )
    except Exception as e:
        print(e)
        return None
    RATE=r.text
    if not re.search(r'^[\d\.\-e]+$', RATE):
        raise Exception (f"err getting rate from {URL}")
    return float(RATE)

@MYcache.memoize( expire=3600*24  )
def ccc(AMOUNT, FROM, TO, DATE=''):
    FROM=FROM.lower()
    TO=  TO.  lower()
    if not DATE:
        DATE=date.today().strftime('%F')
    if FROM==TO:
        RATE=1
    elif FROM == 'byn' or TO == 'byn':
        RATE = Myfin_conv( FROM, TO, DATE)
    else:
        RATE = grandtrunk_get( FROM, TO, DATE)
    if RATE==None:
        raise Exception("bad return value")
    return RATE * AMOUNT

def usage():
    print(f"""
    {sys.argv[0]} Amount From-currency To-currency [DATE]
    e.g.
    {sys.argv[0]} 100 usd czk 2025-01-01
    {sys.argv[0]} 100 usd czk  <--- for todays
""")

if __name__ == "__main__":
    try:
        AMOUNT= float(sys.argv[1])
        FROM=sys.argv[2]
        TO  =sys.argv[3]
    except:
        usage()
        sys.exit(1)
    try:
        DATE=sys.argv[4]
    except:
        DATE=""

    print( f"{ccc( AMOUNT, FROM, TO, DATE):.2f}" )


