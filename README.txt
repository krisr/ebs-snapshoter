snapshoter
    by Kris Rasmussen
    http://www.dreamthis.com

== DESCRIPTION:

Provides EBS snapshot automation that can be configured and run on an EC2 instance.

Snapshot Process:

* Read configuration
* Fetch snapshot descriptions from ec2
* For each volume in configuration
* - If it is time to run a new snapshot based on the most recent snapshot date
* -- freeze mysql (if using mysql)
* -- freeze xfs
* -- create the snapshot
* -- unfreeze xfs
* -- unfreeze mysql
* -- delete old snapshots

== FEATURES/PROBLEMS:

You can configure the following options:

* EBS volumes to backup
* Backup frequency: currently only daily or weekly
* Number of backups to keep (up to ec2 limits)
* Mysql database freezing

== SYNOPSIS:

  /etc/snapshoter.yml
    
    aws_public_key: VSdfslkfjsdf...
    aws_private_key: df23knlkvjsdf...

    vol-VVVV1113:
      mount_point: /data1
      frequency: daily
      freeze_mysql: true
      mysql_user: root
      mysql_password: XDFDSE32
      keep: 20

    vol-BBBBB1112:
      mount_point: /data2
      frequency: weekly
  
== REQUIREMENTS:

* EBS volumes using XFS as filesystem

== INSTALL:

* sudo gem install snapshoter
* Configure /etc/snapshoter.yml
* create the following cron entry: 0 1 * * * /usr/bin/snapshoter
* OR: call the snapshoter script directly after some other work processing every day

== LICENSE:

(The MIT License)

Copyright (c) 2008 Kris Rasmussen

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
