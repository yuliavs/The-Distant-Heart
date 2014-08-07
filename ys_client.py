import json, time, os, itertools, re
import requests, yaml
from datetime import datetime
from twittcher import UserWatcher


def readConfig():
    with open(os.path.join(os.path.dirname(__file__),'config.yaml')) as f:
        return yaml.safe_load(f)


def time_stamp():
    res = datetime.now().isoformat()
    return res


def write_data(data):
    if data is not None:
        fn = os.path.join(os.path.dirname(__file__),"data.log")
        s = str(time_stamp())+" "+str(data)+"\n"
        with open(fn, "a") as f:
            f.write(s)


def call_imp(url_):
    try:
        r = requests.get(url_)
        if r.status_code==200:
            res = r.content
        else:
            res = '{"status_code":'+r.status_code+',"reason":"'+r.reason+'"}'
        return res
    except Exception, e:
        on_error(e)



def extract_bmp(text, cfg):
    res = False
    for s in text.split():
        if s.isdigit():
            i = int(s)
            if (i>=cfg['bmp_min']) & (i<=cfg['bmp_max']):
                res = i
    m = re.search(r"\s([1-9][0-9][0-9]?)bpm", text)
    if m: 
        s = m.group(1) 
        i = int(s)
        if (i>=cfg['bmp_min']) & (i<=cfg['bmp_max']):
            res = i
    return res


def save_tweet(tweet):
    d = {}
    d['date'] = tweet.date
    d['link'] = tweet.link
    d['text'] = tweet.text
    d['username'] = tweet.username
    s = json.dumps(d)
    write_data(s)


def on_tweet(tweet):
    save_tweet(tweet)
    cfg = readConfig()
    bmp = extract_bmp(tweet.text, cfg)
    if bmp is not False:
        http_ = cfg["twitter_to_impurl"][tweet.username]
        url_ = http_+"?bmp=%i"%bmp
        data = call_imp(url_)
        write_data(data)


def on_error(e):
    data = '{"Error": "%s"}' % e.message
    write_data(data)


def main():
    
    try:
        
        cfg = readConfig()
        bots = []
        users = cfg["twitter_to_impurl"].keys()
        
        for user in users:
            db = user+"_tweets.log"
            _ = UserWatcher(user, database=db).get_new_tweets()
            bots.append(UserWatcher(user, action=on_tweet, database=db))

        for bot in itertools.cycle(bots):
            
            try:
                bot.watch()
                time.sleep(cfg["watch_every"])
            
            except Exception, e:
                on_error(e)

    except Exception, e:
        on_error(e)


if __name__ == "__main__":
    main()
