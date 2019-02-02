# miniflux setup

my miniflux setup. 
runs in docker compose, exposes port 8081, i use (non-docker) nginx as proxy.



## starting the service

basically, just run `docker-compose up -d`


## setup nginx

```
server {
        listen 80;
        listen [::]:80;

        error_log    /var/log/nginx/DOMAIN.error.log;
        rewrite_log on;

        server_name DOMAIN;

        include /etc/nginx/snippets/letsencrypt.conf;
        return 301 https://DOMAIN$request_uri;
}

server {

        rewrite_log on;

        listen 443 ssl;
        listen [::]:443 ssl;
        server_name DOMAIN;

        ssl_certificate /etc/letsencrypt/live/DOMAIN/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/DOMAIN/privkey.pem;


        include /etc/nginx/snippets/letsencrypt.conf;

        location / {
                proxy_pass http://localhost:8081;
        }
}
```


## get a certificate

todo.
(get the command in certbot_setup.sh.template and customize to whatever you need)


## set up automatic backups

requirements:
- restic
- aws account

steps:
 
1. setup aws bucket and user as described here:

https://medium.com/@denniswebb/fast-and-secure-backups-to-s3-with-restic-49fd07944304

tl;dr: 
- set up a private bucket
- set up a user with this policy (add you bucket_name!)

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::BUCKET_NAME"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::BUCKET_NAME/*"
        }
    ]
}
```

2. restic setup
 
- copy .restic.env.template to .restic.env and make your changes
- `source .restic.env`
- `restic init` # only first time, this sets up the restic repo on the bucket


3. set up a cronjob

get your users path with echo $PATH and to set it in the crontab.
edit the crontab with `crontab -e`:

```
SHELL=/bin/bash
PATH=

0 1 * * * /path/to/miniflux/backup_and_upgrade.sh >> /path/to/miniflux/upgrade.log
```


