# aws-snapshots
Simple recurring snapshots on AWS EC2.

Get your AWS access key by following this guide: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html

Set your AWS access key and secret by modifying the `AWS_KEY` and `AWS_SECRET` constants.

Set the MAX_KEEP constant to the number of snapshots you want to keep around.

Then you should run the script via cron at your desired intervals. Sample crontab -e

`0 * * * * ruby /var/scripts/snapshots.rb > /var/log/scripts.snapshots.log`
