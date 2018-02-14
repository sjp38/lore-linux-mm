Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E96C06B0010
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 16:27:55 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id h82so3166485lfi.12
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:27:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor2138524lfi.41.2018.02.14.13.27.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 13:27:53 -0800 (PST)
Message-ID: <1518643669.6070.21.camel@gmail.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Thu, 15 Feb 2018 02:27:49 +0500
In-Reply-To: <20180211225657.GA6778@dastard>
References: <1517337604.9211.13.camel@gmail.com>
	 <20180131022209.lmhespbauhqtqrxg@destitution>
	 <1517888875.7303.3.camel@gmail.com>
	 <20180206060840.kj2u6jjmkuk3vie6@destitution>
	 <CABXGCsOgcYyj8Xukn7Pi_M2qz2aJ1MJZTaxaSgYno7f_BtZH6w@mail.gmail.com>
	 <1517974845.4352.8.camel@gmail.com>
	 <20180207065520.66f6gocvxlnxmkyv@destitution>
	 <1518255240.31843.6.camel@gmail.com> <1518255352.31843.8.camel@gmail.com>
	 <20180211225657.GA6778@dastard>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 2018-02-12 at 09:56 +1100, Dave Chinner wrote:
> 
> Yes, but you still haven't provided me with all the other info that
> this link asks for. Namely:
> 
> kernel version (uname -a)
Linux localhost.localdomain 4.15.2-300.fc27.x86_64+debug #1 SMP Thu Feb 8 21:55:40 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux

> xfsprogs version (xfs_repair -V)
xfs_repair version 4.12.0

> number of CPUs
i7-4770 4 Cores 8 Threads

> contents of /proc/meminfo
MemTotal:       31759696 kB
MemFree:        17587876 kB
MemAvailable:   21904644 kB
Buffers:           55280 kB
Cached:          4674056 kB
SwapCached:            0 kB
Active:          8679336 kB
Inactive:        4286552 kB
Active(anon):    7792260 kB
Inactive(anon):   664564 kB
Active(file):     887076 kB
Inactive(file):  3621988 kB
Unevictable:        1976 kB
Mlocked:            1976 kB
SwapTotal:      62494716 kB
SwapFree:       62494716 kB
Dirty:             28284 kB
Writeback:          4148 kB
AnonPages:       8238616 kB
Mapped:          1903204 kB
Shmem:            666668 kB
Slab:             491372 kB
SReclaimable:     263420 kB
SUnreclaim:       227952 kB
KernelStack:       38032 kB
PageTables:       160156 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    78374564 kB
Committed_AS:   28033436 kB
VmallocTotal:   34359738367 kB
VmallocUsed:           0 kB
VmallocChunk:          0 kB
HardwareCorrupted:     0 kB
AnonHugePages:   2244608 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
CmaTotal:              0 kB
CmaFree:               0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:      841160 kB
DirectMap2M:    15837184 kB
DirectMap1G:    17825792 kB

> contents of /proc/mounts
sysfs /sys sysfs rw,seclabel,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
devtmpfs /dev devtmpfs rw,seclabel,nosuid,size=15863192k,nr_inodes=3965798,mode=755 0 0
securityfs /sys/kernel/security securityfs rw,nosuid,nodev,noexec,relatime 0 0
tmpfs /dev/shm tmpfs rw,seclabel,nosuid,nodev 0 0
devpts /dev/pts devpts rw,seclabel,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,seclabel,nosuid,nodev,mode=755 0 0
tmpfs /sys/fs/cgroup tmpfs ro,seclabel,nosuid,nodev,noexec,mode=755 0 0
cgroup /sys/fs/cgroup/unified cgroup2 rw,seclabel,nosuid,nodev,noexec,relatime 0 0
cgroup /sys/fs/cgroup/systemd cgroup rw,seclabel,nosuid,nodev,noexec,relatime,xattr,name=systemd 0 0
pstore /sys/fs/pstore pstore rw,seclabel,nosuid,nodev,noexec,relatime 0 0
efivarfs /sys/firmware/efi/efivars efivarfs rw,nosuid,nodev,noexec,relatime 0 0
cgroup /sys/fs/cgroup/memory cgroup rw,seclabel,nosuid,nodev,noexec,relatime,memory 0 0
cgroup /sys/fs/cgroup/cpuset cgroup rw,seclabel,nosuid,nodev,noexec,relatime,cpuset 0 0
cgroup /sys/fs/cgroup/net_cls,net_prio cgroup rw,seclabel,nosuid,nodev,noexec,relatime,net_cls,net_prio 0 0
cgroup /sys/fs/cgroup/hugetlb cgroup rw,seclabel,nosuid,nodev,noexec,relatime,hugetlb 0 0
cgroup /sys/fs/cgroup/perf_event cgroup rw,seclabel,nosuid,nodev,noexec,relatime,perf_event 0 0
cgroup /sys/fs/cgroup/cpu,cpuacct cgroup rw,seclabel,nosuid,nodev,noexec,relatime,cpu,cpuacct 0 0
cgroup /sys/fs/cgroup/pids cgroup rw,seclabel,nosuid,nodev,noexec,relatime,pids 0 0
cgroup /sys/fs/cgroup/freezer cgroup rw,seclabel,nosuid,nodev,noexec,relatime,freezer 0 0
cgroup /sys/fs/cgroup/devices cgroup rw,seclabel,nosuid,nodev,noexec,relatime,devices 0 0
cgroup /sys/fs/cgroup/blkio cgroup rw,seclabel,nosuid,nodev,noexec,relatime,blkio 0 0
configfs /sys/kernel/config configfs rw,relatime 0 0
/dev/sda1 / ext4 rw,seclabel,relatime,data=ordered 0 0
selinuxfs /sys/fs/selinux selinuxfs rw,relatime 0 0
systemd-1 /proc/sys/fs/binfmt_misc autofs rw,relatime,fd=24,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=16272 0 0
hugetlbfs /dev/hugepages hugetlbfs rw,seclabel,relatime,pagesize=2M 0 0
mqueue /dev/mqueue mqueue rw,seclabel,relatime 0 0
debugfs /sys/kernel/debug debugfs rw,seclabel,relatime 0 0
binfmt_misc /proc/sys/fs/binfmt_misc binfmt_misc rw,relatime 0 0
tmpfs /tmp tmpfs rw,seclabel,nosuid,nodev 0 0
/dev/sda3 /boot/efi vfat rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=ascii,shortname=winnt,errors=remount-ro 0 0
/dev/sdb /home xfs rw,seclabel,relatime,attr2,inode64,noquota 0 0
sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw,relatime 0 0
tmpfs /run/user/42 tmpfs rw,seclabel,nosuid,nodev,relatime,size=3175968k,mode=700,uid=42,gid=42 0 0
tmpfs /run/user/1000 tmpfs rw,seclabel,nosuid,nodev,relatime,size=3175968k,mode=700,uid=1000,gid=1000 0 0
gvfsd-fuse /run/user/1000/gvfs fuse.gvfsd-fuse rw,nosuid,nodev,relatime,user_id=1000,group_id=1000 0 0
fusectl /sys/fs/fuse/connections fusectl rw,relatime 0 0
/dev/sr0 /run/media/mikhail/MegaFon iso9660 ro,nosuid,nodev,relatime,nojoliet,check=s,map=n,blocksize=2048,uid=1000,gid=1000,dmode=500,fmode=400 0 0
nodev /sys/kernel/tracing tracefs rw,seclabel,relatime 0 0

> contents of /proc/partitions
major minor  #blocks  name

   8        0  234431064 sda
   8        1  171421696 sda1
   8        2   62494720 sda2
   8        3     510976 sda3
   8       16 3907018584 sdb
   8       32 3907018584 sdc
   8       33 3907017543 sdc1
  11        0      72692 sr0

> RAID layout (hardware and/or software)
no RAID

> LVM configuration
no LVM

> type of disks you are using
Seagate Constellation ES.3 [ST4000NM0033]

> write cache status of drives
> size of BBWC and mode it is running in
no BBWC module

> xfs_info output on the filesystem in question
meta-data=/dev/sdb               isize=512    agcount=4, agsize=244188662 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1 spinodes=0 rmapbt=0
         =                       reflink=0
data     =                       bsize=4096   blocks=976754646, imaxpct=5
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=476930, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

> 
> And:
> 
> "Then you need to describe your workload that is causing the
> problem, ..."
After start computer I launch follow applicaions:
- "gnome-terminal"
- "Opera" web browser
- "Firefox" web browser
- "GitKraken" git GUI client
- "Evolution" email client
- "Steam" game store client
- "virt-manager" and one virtual machine with Windows 10
- "Reminna" RDP client
- "Telegram" messenger
This enought for interface freezes and kernel error messages. All there application consume 10-13Gb RAM after ended launch.
Total RAM on machine 32Gb
Also with "atop" I see what all disk throughput in
idle state consumed by tracker-store process.

> 
> Without any idea of what you are actually doing and what storage you
> are doing that work on, I have no idea what the expected behaviour
> should be. All I can tell is you have something with disk caches and
> io pools on your desktop machine and it's slow....

My expectations:
- lack of interface freezes. (No freezes mouse movements, no freezes while switching between applications)
- lack of error messages in kernel output


> Ok, once and for all: this is not an XFS problem.
> 
> The trace from task 8665, which is the one that triggered above
> waiting for IO. task -395 is an IO completion worker in XFS that
> is triggered by the lower layer IO completion callbacks, and it's
> running regularly and doing lots of IO completion work every few
> milliseconds.
> 
> <...>-8665  [007]   627.332389: xfs_buf_submit_wait:  dev 8:16 bno 0xe96a4040 nblks 0x20 hold 1 pincount 0 lock 0 flags READ|PAGES caller _xfs_buf_read
> <...>-8665  [007]   627.332390: xfs_buf_hold:         dev 8:16 bno 0xe96a4040 nblks 0x20 hold 1 pincount 0 lock 0 flags READ|PAGES caller xfs_buf_submit_wait
> <...>-8665  [007]   627.332416: xfs_buf_iowait:       dev 8:16 bno 0xe96a4040 nblks 0x20 hold 2 pincount 0 lock 0 flags READ|PAGES caller _xfs_buf_read
> <...>-395   [000]   875.682080: xfs_buf_iodone:       dev 8:16 bno 0xe96a4040 nblks 0x20 hold 2 pincount 0 lock 0 flags READ|PAGES caller xfs_buf_ioend_work
> <...>-8665  [007]   875.682105: xfs_buf_iowait_done:  dev 8:16 bno 0xe96a4040 nblks 0x20 hold 2 pincount 0 lock 0 flags DONE|PAGES caller _xfs_buf_read
> <...>-8665  [007]   875.682107: xfs_buf_rele:         dev 8:16 bno 0xe96a4040 nblks 0x20 hold 2 pincount 0 lock 0 flags DONE|PAGES caller xfs_buf_submit_wait
> 
> IOWs, that IO completion took close on 250s for it to be signalled
> to XFS, and so these delays have nothing to do with XFS.
> 
> What is clear from the trace is that you are overloading your IO
> subsystem. I see average synchronous read times of 40-50ms which
> implies a constant and heavy load on the underlying storage. In
> the ~1400s trace I see:
> 
> $ grep "submit:\|submit_wait:" trace_report.txt |wc -l
> 133427
> $
> 
> ~130k metadata IO submissions.
> 
> $ grep "writepage:" trace_report.txt |wc -l
> 1662764
> $
> 
> There was also over 6GB of data written, and:
> 
> $ grep "readpages:" trace_report.txt |wc -l
> 85866
> $
> 
> About 85000 data read IOs were issued.
> 
> A typical SATA drive can sustain ~150 IOPS. I count from the trace
> at least 220,000 IOs in ~1400s, which is pretty much spot on an
> average of 150 IOPS. IOWs, your system is running at the speed of
> you disk and it's clear that it's completely overloaded at times
> leading to large submission backlog queues and excessively long IO
> times.
> 
> IOWs, this is not an XFS problem. It's exactly what I'd expect to
> see when you try to run a very IO intensive workload on a cheap SATA
> drive that can't keep up with what is being asked of it....
> 

I am understand that XFS is not culprit here. But I am worried about of interface freezing and various kernel messages with traces which leads to XFS. This is my only clue, and I do not know where to
dig yet. It may be IO sheduller or block device layer. I need help to get to the truth.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
