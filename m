Message-ID: <3F716177.6060607@aitel.hist.no>
Date: Wed, 24 Sep 2003 11:18:47 +0200
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.6.0-test5-mm4 boot crash
References: <20030922013548.6e5a5dcf.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

test5-mm4 crashed during RAID-1 autodetection and setup.
It got as far as:
md: created md0
md: bind<hda1>
md: bind<hdb1>
md: running: <hdb1><hda1>

After this, I usually get this (from test5-mm3 dmesg):
raid1: raid set md0 active with 2 out of 2 mirrors
md: ... autorun DONE.
VFS: Mounted root (ext2 filesystem) readonly.

Instead, I got the dump at the end of this message.
I'm using devfs and Viro's compile fix for devfs in mm4.
The root fs is on raid-1, the raid-1 gets autodetected.

The kernel has no module support, and no initrd.

Here's the dump:

Unable to handle null pointer deref at virtual address 00000000
eip c02b7d1e  eip at md_probe
PREEMPT process swapper pid:1
Trace:
invalidate_inode_pages
do_md_run
printk
autorun_array
autorun_devices
mddev_put
autostart_arrays
igrab
md_ioctl
devfs_open
dentry_open
filp_open
blkdev_ioctl
sys_ioctl
md_run_setup
prepare_namespace
init
init
kernel_thread_helper

Attempted to kill init!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
