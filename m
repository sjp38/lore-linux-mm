Message-ID: <3E736505.2000106@aitel.hist.no>
Date: Sat, 15 Mar 2003 18:38:13 +0100
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.64-mm7 - dies on smp with raid
References: <20030315011758.7098b006.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mm7 crashed where mm2 works.
The machine is a dual celeron with two scsi disks with
some raid-1 & raid-0 partitions.

deadline or anicipatory scheduler does not make a difference.
It dies anyway, attempting to kill init.

Here's what I managed to  write down before the 30 second reboot
kicked in:

EIP is at md_wakeup_thread

stack:
do_md_run
autorun_array
autorun_devices
autostart_arrays
md_ioctl
dentry_open
kmem_cache_free
blkdev_ioctl
sys_ioctl
init
init

This happened during the boot process. The kernel is compiled
with gcc 2.95.4 from debian testing. The machine uses devfs

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
