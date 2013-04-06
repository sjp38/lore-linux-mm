Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id CC2326B0139
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 03:29:53 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id e53so1652346eek.37
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 00:29:52 -0700 (PDT)
Message-ID: <515FCEEC.9070504@suse.cz>
Date: Sat, 06 Apr 2013 09:29:48 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
References: <20130402142717.GH32241@suse.de> <20130402150651.GB31577@thunk.org> <20130402151436.GC31577@thunk.org> <20130403101925.GA7341@suse.de> <515F4DA3.2000000@suse.cz> <20130405231635.GA6521@thunk.org>
In-Reply-To: <20130405231635.GA6521@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 04/06/2013 01:16 AM, Theodore Ts'o wrote:
> On Sat, Apr 06, 2013 at 12:18:11AM +0200, Jiri Slaby wrote:
>> Ok, so now I'm runnning 3.9.0-rc5-next-20130404, it's not that bad, but
>> it still sucks. Updating a kernel in a VM still results in "Your system
>> is too SLOW to play this!" by mplayer and frame dropping.
> 
> What was the first kernel where you didn't have the problem?  Were you
> using the 3.8 kernel earlier, and did you see the interactivity
> problems there?

I'm not sure, as I am using -next like for ever. But sure, there was a
kernel which didn't ahve this problem.

> What else was running in on your desktop at the same time?

Nothing, just VM (kernel update from console) and mplayer2 on the host.
This is more-or-less reproducible with these two.

> How was
> the file system mounted,

Both are actually a single device /dev/sda5:
/dev/sda5 on /win type ext4 (rw,noatime,data=ordered)

Should I try writeback?

> and can you send me the output of dumpe2fs -h
> /dev/XXX?

dumpe2fs 1.42.7 (21-Jan-2013)
Filesystem volume name:   <none>
Last mounted on:          /win
Filesystem UUID:          cd4bf4d2-bc32-4777-a437-ee24c4ee5f1b
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal ext_attr resize_inode dir_index
filetype needs_recovery extent flex_bg sparse_super large_file huge_file
uninit_bg dir_nlink extra_isize
Filesystem flags:         signed_directory_hash
Default mount options:    user_xattr acl
Filesystem state:         clean
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              30507008
Block count:              122012416
Reserved block count:     0
Free blocks:              72021328
Free inodes:              30474619
First block:              0
Block size:               4096
Fragment size:            4096
Reserved GDT blocks:      994
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         8192
Inode blocks per group:   512
RAID stride:              32747
Flex block group size:    16
Filesystem created:       Fri Sep  7 20:44:21 2012
Last mount time:          Thu Apr  4 12:22:01 2013
Last write time:          Thu Apr  4 12:22:01 2013
Mount count:              256
Maximum mount count:      -1
Last checked:             Sat Sep  8 21:13:28 2012
Check interval:           0 (<none>)
Lifetime writes:          1011 GB
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:               256
Required extra isize:     28
Desired extra isize:      28
Journal inode:            8
Default directory hash:   half_md4
Directory Hash Seed:      b6ad3f8b-72ce-49d6-92cb-abccd7dbe98e
Journal backup:           inode blocks
Journal features:         journal_incompat_revoke
Journal size:             128M
Journal length:           32768
Journal sequence:         0x00054dc7
Journal start:            8193

> Oh, and what options were you using to when you kicked off
> the VM?

qemu-kvm -k en-us -smp 2 -m 1200 -soundhw hda -usb -usbdevice tablet
-net user -net nic,model=e1000 -serial pty -balloon virtio -hda x.img

> The other thing that would be useful was to enable the jbd2_run_stats
> tracepoint and to send the output of the trace log when you notice the
> interactivity problems.

Ok, I will try.

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
