#!/usr/bin/bash python3

import praw
import json
import os
import datetime
from urllib.parse import urlparse
import sys

with open('credentials.txt', 'r') as f:
    ci = f.readline().strip()
    cs = f.readline().strip()

seedlist = []
with open('seeds.txt', 'r') as f:
    for x in f:
        seedlist.append(x.strip().lower())

read = set()
with open('crawled.txt', 'r') as f:
    for x in f:
        read.add(x.strip().lower())

reddit = praw.Reddit(client_id=ci,
                     client_secret=cs,
                     user_agent='MyAPI/v0.1.1')

MB_thres = int(sys.argv[1])
MB_thres = MB_thres * 1000000
File_Name = sys.argv[2]
subreddit_run = int(sys.argv[3])
subreddit_tracker = 0
post_id = []
list_of_data = []
counter = 0
dupli = False

def process_post(post):
    global post_id
    created_time_utc = datetime.datetime.utcfromtimestamp(post.created_utc)
    created_time_pdt = created_time_utc - datetime.timedelta(hours=7)
    post_comments = []
    for comment in post.comments:
        if isinstance(comment, praw.models.MoreComments):
            continue
        post_comments.append(comment.body)
        if len(post_comments) >= 10:
            break
    urls = [url for url in post_comments if url.startswith('https://www.reddit.com/r/')]
    for url in urls:
        parsed_url = urlparse(url)
        path = parsed_url.path
        path_parts = path.split('/')
        if path_parts[2].lower() not in seedlist and  path_parts[2].lower() not in read:
            with open('seeds.txt', 'a') as add:
                add.write('\n')
                add.write(path_parts[2])
            seedlist.append(path_parts[2].lower())
    data = {}
    data = { 'subreddit': post.subreddit_name_prefixed, 'title': post.title,
            'author': post.author.name if post.author is not None else '', 'selftext': post.selftext,
            'link': 'https://www.reddit.com' + post.permalink, 'up': post.ups, 'down': post.downs,'ratio': post.upvote_ratio,
            'url': post.url, 'score': post.score, 'awards': post.total_awards_received, 'comments': post_comments,
            'created_time_pdt': created_time_pdt.strftime('%Y-%m-%d %H:%M:%S') }
    post_id.append(post.id)
    urls = [url for url in post.selftext.split() if url.startswith('https://www.reddit.com/r/')]
    for url in urls:
        parsed_url = urlparse(url)
        path = parsed_url.path
        path_parts = path.split('/')
        if path_parts[2].lower() not in seedlist and path_parts[2].lower() not in read:
            with open('seeds.txt', 'a') as add:
                add.write('\n')
                add.write(path_parts[2])
            seedlist.append(path_parts[2].lower())
    return data

def process_subreddit(Subreddit):
    global post_id
    global list_of_data
    global counter
    global dupli
    if Subreddit in read:
        dupli = True
        return

    subreddit = reddit.subreddit(Subreddit)
    data = {}
    print('Started crawling r/{} subreddit'.format(subreddit))
    new_posts = subreddit.new(limit=None)
    print('Getting new post')
    for post in new_posts:
        if post.id not in post_id:
            data = process_post(post)
            list_of_data.append(data)
            counter += 1

    hot_posts = subreddit.hot(limit=None)
    print('Getting hot post')
    for post in hot_posts:
        if post.id not in post_id:
            data = process_post(post)
            list_of_data.append(data)
            counter += 1

    top_posts = subreddit.top(limit=None)
    print('Getting top post')
    for post in top_posts:
        if post.id not in post_id:
            data = process_post(post)
            list_of_data.append(data)
            counter += 1

i= 0
while i < len(seedlist):
    dupli = False
    process_subreddit(seedlist[i])
    subreddit_tracker += 1
    if not dupli:
        read.add(seedlist[i])
        with open('crawled.txt', 'w') as f:
            for y in read:
                f.write(y)
                f.write('\n')

        common_elements = set(read).intersection(seedlist)
        for y in common_elements:
            seedlist.remove(y)

        with open('seeds.txt', 'w') as f:
            for y in range(len(seedlist)):
                f.write(seedlist[y])
                f.write('\n')

        with open(f'{File_Name}.json', 'a') as outfile:
            json.dump(list_of_data, outfile)

        post_id = []
        list_of_data = []
        if os.path.getsize(f'{File_Name}.json') > MB_thres or subreddit_tracker >= subreddit_run:
            break

print('Total file size of crawled subreddits is {} bytes'.format(os.path.getsize(f'{File_Name}.json')))
print('You crawled a total of {} posts for this run'.format(counter))
