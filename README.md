# incremental_backup
This sh script is an incremental backup using rsync and hard links.
You can make a backup plan for each group of directory.
Example: from day 0 (today) to day 30, make one backup every day. Next, from day 31 to day 60, make one backup every 15 days...

It is plained to launch it every days with a cron job.
The backups can be stored on the local machine or on remote server by ssh.

## Usage
Copy ib.cfg.default to ib.cfg and configure it. Run ib.

## Options
-c or --config= to specify config file.