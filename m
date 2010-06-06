Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1CA4D6B01B8
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 12:15:45 -0400 (EDT)
Date: Sun, 6 Jun 2010 18:15:41 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: 2.6.35-rc2 : OOPS with LTP memcg regression test run.
Message-ID: <20100606161541.GA1808@arch.tripp.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100606154048.GJ31073@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Sachin Sant <sachinp@in.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux/PPC Development <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>


>> And few more of these. Previous snapshot release 2.6.35-rc1-git5(6c5de280b6...)
>> was good.
>
>That's very odd, since
>; git diff --stat 6c5de280b6..v2.6.35-rc2         
> Makefile                             |    2 +-
> drivers/gpu/drm/i915/intel_display.c |    9 +++++++
> fs/ext4/inode.c                      |   40 +++++++++++++++++++--------------
> fs/ext4/move_extent.c                |    3 ++
> 4 files changed, 36 insertions(+), 18 deletions(-)
>
>and nothing of that looks like good candidates...

I may have the same problem on my machine.
(See also the thread: ext4 2.6.35-rc2 regression (ext4: Make sure the MOVE_EXT ioctl...))

general protection fault: 0000 [#1] SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:11.0/host2/target2:0:0/2:0:0:0/block/sdb/size
CPU 2
Pid: 1683, comm: iptables-restor Not tainted 2.6.35-rc2-00033-gcc1f375 #46 M4A78T-E/System Product Name
RIP: 0010:[<ffffffff810cc6e6>]  [<ffffffff810cc6e6>] kmem_cache_alloc+0x59/0xda
RSP: 0018:ffff88011c993d78  EFLAGS: 00010002
RAX: 0000000000000000 RBX: 0720072007200720 RCX: ffffffff810bd4c9
RDX: 00007f076cee3000 RSI: 00000000000000d0 RDI: ffff88011fc01800
RBP: ffff88011c993db8 R08: ffff880001b13f48 R09: 0000000000000000
R10: ffff88011d387c00 R11: ffff88011c983930 R12: ffff88011fc01800
R13: 0000000000000202 R14: 00000000000000d0 R15: 00000000000000d0
FS:  00007f076dc43700(0000) GS:ffff880001b00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f8595d364f8 CR3: 000000011b8b0000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process iptables-restor (pid: 1683, threadinfo ffff88011c992000, task ffff88011ec09610)
Stack:
ffff88011d387c10 ffff88011c983930 ffff88011c993d98 000000000000fffa
<0> ffff88011d387bd0 00007f076cee3000 ffff88011f77ea40 0000000000000000
<0> ffff88011c993e08 ffffffff810bd4c9 ffff88011b8f5cc0 ffffffff810bd639
Call Trace:
[<ffffffff810bd4c9>] __split_vma+0x33/0x18d
[<ffffffff810bd639>] ? vma_merge+0x16/0x1fc
[<ffffffff810bdc01>] split_vma+0x23/0x28
[<ffffffff810bf572>] mprotect_fixup+0x146/0x54c
[<ffffffff810befff>] ? do_mmap_pgoff+0x2a4/0x2fe
[<ffffffff810bfaf0>] sys_mprotect+0x178/0x1f4
[<ffffffff8102b93b>] system_call_fastpath+0x16/0x1b
Code: 65 4c 8b 04 25 88 d4 00 00 48 8b 07 49 01 c0 49 8b 18 48 85 db 75 10 83 ca ff 44 89 f6 e8 58 fa ff ff 48 89 c3 eb 0b 48 63 47 18 <48> 8b 04 03 49 89 00 41 55 9d 48 85 db 74 15 41 81 e6 00 80 00
RIP  [<ffffffff810cc6e6>] kmem_cache_alloc+0x59/0xda
RSP <ffff88011c993d78>
---[ end trace e2fb1ccd3cb9dd77 ]---
-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
