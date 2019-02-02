# miniflux setup



# backups

### requirements

- restic
- aws account

1. setup aws bucket and user as described here:

https://medium.com/@denniswebb/fast-and-secure-backups-to-s3-with-restic-49fd07944304

(basically, set up a user with this policy)
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

2.
 
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


