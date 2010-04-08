Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A37C06B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:45:05 -0400 (EDT)
Message-ID: <3a5f01cad6c5$8a722c00$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <2375c9f91003242029p1efbbea1v8e313e460b118f14@mail.gmail.com> <20100325153110.6be9a3df.kamezawa.hiroyu@jp.fujitsu.com> <02c101cacbf8$d21d1650$0400a8c0@dcccs> <179901cad182$5f87f620$0400a8c0@dcccs> <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com> <1fe901cad2b0$d39d0300$0400a8c0@dcccs> <20100402230905.GW3335@dastard> <22c901cad333$7a67db60$0400a8c0@dcccs> <20100404103701.GX3335@dastard> <2bd101cad4ec$5a425f30$0400a8c0@dcccs> <20100405224522.GZ3335@dastard>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Thu, 8 Apr 2010 04:45:13 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

Hello,

Sorry, but still have the problem with 2.6.33.2.

Apr  8 03:04:51 alfa kernel: BUG: unable to handle kernel paging request at 
000000610000008c
Apr  8 03:04:51 alfa kernel: IP: [<ffffffff811f17c4>] 
xfs_iflush_cluster+0x148/0x35a
Apr  8 03:04:51 alfa kernel: PGD 22258a067 PUD 0
Apr  8 03:04:51 alfa kernel: Oops: 0000 [#1] SMP
Apr  8 03:04:51 alfa kernel: last sysfs file: /sys/class/misc/rfkill/dev
Apr  8 03:04:51 alfa kernel: CPU 2
Apr  8 03:04:51 alfa kernel: Pid: 3049, comm: xfssyncd Not tainted 2.6.33.2 
#1 DP35DP/
Apr  8 03:04:51 alfa kernel: RIP: 0010:[<ffffffff811f17c4>] 
[<ffffffff811f17c4>] xfs_iflush_cluster+0x148/0x35a
Apr  8 03:04:51 alfa kernel: RSP: 0018:ffff880228e3bca0  EFLAGS: 00010206
Apr  8 03:04:51 alfa kernel: RAX: 0000006100000000 RBX: ffff880153795750 
RCX: 000000000000001a
Apr  8 03:04:51 alfa kernel: RDX: 0000000000000020 RSI: 00000000003dfdf4 
RDI: 0000000000000005
Apr  8 03:04:51 alfa kernel: RBP: ffff880228e3bd10 R08: ffff880228e3bc60 
R09: ffff8801c5d6e1b8
Apr  8 03:04:51 alfa kernel: R10: 00000000003dfdf4 R11: 0000000000000005 
R12: 000000000000001a
Apr  8 03:04:51 alfa kernel: R13: ffff8800b1d920d8 R14: ffff88022a7cabe0 
R15: 00000000003ddf80
Apr  8 03:04:51 alfa kernel: FS:  0000000000000000(0000) 
GS:ffff880028300000(0000) knlGS:0000000000000000
Apr  8 03:04:51 alfa kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 
000000008005003b
Apr  8 03:04:51 alfa kernel: CR2: 000000610000008c CR3: 00000002222db000 
CR4: 00000000000006e0
Apr  8 03:04:51 alfa kernel: DR0: 0000000000000000 DR1: 0000000000000000 
DR2: 0000000000000000
Apr  8 03:04:51 alfa kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 
DR7: 0000000000000400
Apr  8 03:04:51 alfa kernel: Process xfssyncd (pid: 3049, threadinfo 
ffff880228e3a000, task ffff880228e66040)
Apr  8 03:04:51 alfa kernel: Stack:
Apr  8 03:04:51 alfa kernel:  ffff8800b1d920d8 ffff8800466bc100 
ffff880228c32580 ffffffffffffffe0
Apr  8 03:04:51 alfa kernel: <0> 0000000000000020 ffff880228e24930 
0000002028e3bd10 0000000300000000
Apr  8 03:04:51 alfa kernel: <0> ffff880228e24948 ffff8800b1d920d8 
0000000000000002 ffff8800466bc100
Apr  8 03:04:51 alfa kernel: Call Trace:
Apr  8 03:04:51 alfa kernel:  [<ffffffff811f1bcd>] xfs_iflush+0x1f7/0x2aa
Apr  8 03:04:51 alfa kernel:  [<ffffffff811ecc12>] ? xfs_ilock+0x66/0xb7
Apr  8 03:04:51 alfa kernel:  [<ffffffff81214653>] 
xfs_reclaim_inode+0xba/0xee
Apr  8 03:04:51 alfa kernel:  [<ffffffff8121498d>] 
xfs_inode_ag_walk+0x91/0xd7
Apr  8 03:04:51 alfa kernel:  [<ffffffff81214599>] ? 
xfs_reclaim_inode+0x0/0xee
Apr  8 03:04:51 alfa kernel:  [<ffffffff81214a30>] 
xfs_inode_ag_iterator+0x5d/0x8f
Apr  8 03:04:51 alfa kernel:  [<ffffffff81214599>] ? 
xfs_reclaim_inode+0x0/0xee
Apr  8 03:04:51 alfa kernel:  [<ffffffff81214a81>] 
xfs_reclaim_inodes+0x1f/0x21
Apr  8 03:04:51 alfa kernel:  [<ffffffff81214ab6>] xfs_sync_worker+0x33/0x6f
Apr  8 03:04:51 alfa kernel:  [<ffffffff812144cf>] xfssyncd+0x149/0x198
Apr  8 03:04:51 alfa kernel:  [<ffffffff81214386>] ? xfssyncd+0x0/0x198
Apr  8 03:04:51 alfa kernel:  [<ffffffff81057061>] kthread+0x82/0x8a
Apr  8 03:04:51 alfa kernel:  [<ffffffff81002fd4>] 
kernel_thread_helper+0x4/0x10
Apr  8 03:04:51 alfa kernel:  [<ffffffff8179217c>] ? restore_args+0x0/0x30
Apr  8 03:04:51 alfa kernel:  [<ffffffff81056fdf>] ? kthread+0x0/0x8a
Apr  8 03:04:51 alfa kernel:  [<ffffffff81002fd0>] ? 
kernel_thread_helper+0x0/0x10
Apr  8 03:04:51 alfa kernel: Code: 8e eb 01 00 00 b8 01 00 00 00 48 d3 e0 ff 
c8 23 43 18 48 23 45 a8 4c 39 f8 0f 85 ae 00 00 00 48 8b 83 80 00 00 00 48 
85 c0
74 0b <66> f7 80 8c 00 00 00 ff 01 75 13 80 bb 0a 02 00 00 00 75 0a 8b
Apr  8 03:04:51 alfa kernel: RIP  [<ffffffff811f17c4>] 
xfs_iflush_cluster+0x148/0x35a
Apr  8 03:04:51 alfa kernel:  RSP <ffff880228e3bca0>
Apr  8 03:04:51 alfa kernel: CR2: 000000610000008c
Apr  8 03:04:51 alfa kernel: ---[ end trace d1fc6fbf3568ba3f ]---
Apr  8 04:41:11 alfa syslogd 1.4.1: restart.


----- Original Message ----- 
From: "Dave Chinner" <david@fromorbit.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: <xiyou.wangcong@gmail.com>; <linux-kernel@vger.kernel.org>; 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
<axboe@kernel.dk>
Sent: Tuesday, April 06, 2010 12:45 AM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Mon, Apr 05, 2010 at 08:17:27PM +0200, Janos Haar wrote:
>> Dave,
>>
>> Thank you for your answer.
>> Like i sad before, this is a productive server with important service.
>> Can you please send the fix for me as soon as it is done even for
>> testing it....
>> Or point me to the right direction to get it?
>
> It's in 2.6.33 if you want to upgrade the kernel, or you if don't
> want to wait for the next 2.6.32.x kernel, you can apply this series
> of 19 patches yourself:
>
> http://oss.sgi.com/archives/xfs/2010-03/msg00125.html
>
> Cheers,
>
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/ 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
