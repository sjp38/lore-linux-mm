Date: Sun, 1 Jun 2003 14:06:10 +0200
Subject: Re: 2.5.66-mm3 and raid still oopses, but later than mm1/mm2
Message-ID: <20030601120610.GA6249@hh.idb.hist.no>
References: <20030403005817.69a29d7b.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030403005817.69a29d7b.akpm@digeo.com>
From: Helge Hafting <helgehaf@aitel.hist.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, neilb@cse.unsw.edu.au
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2.5.70-mm3 with raid1 has improved to some extent,
the RAID crash now happens somewhat later.

I got a lot of kernel errors during RAID initialization,
with normal boot messages inbetween.  Nothing made it to
the logs.  I eventually got this:

Kernel BUG at mm/slab.c:1682
invalid operand 0000 [#1]
PREEMPTSMP
CPU:0
EIP at free_block+0x276/0x350
process fsck

Call trace:
drain_array
reap_timer_fnc
reap_timer_fnc
run_timer_softirq
do_softirq
smp_apic_timer
apic_timer_interrupt

<0> KErnel panic exception in interrupt
in interrupt - not syncing
reboot in 300 seconds

This is 2.5.70-mm3, with a patch that makes
matroxfb work so I could see the entire oops.

This is a dual celeron, with 2 scsi disks.
Root & /home is on raid-1, there is also a raid-0,
all disk-based filesystems are ext2.

Helge Hafting
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
