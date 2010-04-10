Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id ADC776B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 17:15:34 -0400 (EDT)
Message-ID: <0d5b01cad8f2$fdbd5750$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <02c101cacbf8$d21d1650$0400a8c0@dcccs> <179901cad182$5f87f620$0400a8c0@dcccs> <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com> <1fe901cad2b0$d39d0300$0400a8c0@dcccs> <20100402230905.GW3335@dastard> <22c901cad333$7a67db60$0400a8c0@dcccs> <20100404103701.GX3335@dastard> <2bd101cad4ec$5a425f30$0400a8c0@dcccs> <20100405224522.GZ3335@dastard> <3a5f01cad6c5$8a722c00$0400a8c0@dcccs> <20100408025822.GL11036@dastard>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Sat, 10 Apr 2010 23:15:45 +0200
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

Dave,

Not the server looks stable, but only runs in 23 hour at this point.

Now i can see these and similar messages:
Apr 10 09:59:09 alfa kernel: Filesystem "sdb2": corrupt dinode 673160714, 
extent total = -1392508927, nblocks = 5.  Unmount and run xfs_repair.
Apr 10 09:59:09 alfa kernel: ffff880153797a00: 49 4e 81 a4 01 02 00 01 00 00 
00 30 00 00 00 30  IN.........0...0
Apr 10 09:59:09 alfa kernel: Filesystem "sdb2": XFS internal error 
xfs_iformat(1) at line 332 of file fs/xfs/xfs_inode.c.  Caller 
0xffffffff811d70d6
Apr 10 09:59:09 alfa kernel:
Apr 10 09:59:09 alfa kernel: Pid: 2324, comm: updatedb Not tainted 2.6.32.10 
#3
Apr 10 09:59:09 alfa kernel: Call Trace:
Apr 10 09:59:09 alfa kernel:  [<ffffffff811cf87d>] 
xfs_error_report+0x41/0x43
Apr 10 09:59:09 alfa kernel:  [<ffffffff811d70d6>] ? xfs_iread+0xb1/0x184
Apr 10 09:59:09 alfa kernel:  [<ffffffff811cf8d1>] 
xfs_corruption_error+0x52/0x5e
Apr 10 09:59:09 alfa kernel:  [<ffffffff811d6c68>] xfs_iformat+0x10d/0x4ca
Apr 10 09:59:09 alfa kernel:  [<ffffffff811d70d6>] ? xfs_iread+0xb1/0x184
Apr 10 09:59:09 alfa kernel:  [<ffffffff811d70d6>] xfs_iread+0xb1/0x184
Apr 10 09:59:09 alfa kernel:  [<ffffffff811d3ee2>] xfs_iget+0x2c3/0x455
Apr 10 09:59:09 alfa kernel:  [<ffffffff811eab8b>] xfs_lookup+0x82/0xb3
Apr 10 09:59:09 alfa kernel:  [<ffffffff811f5a8f>] xfs_vn_lookup+0x45/0x86
Apr 10 09:59:09 alfa kernel:  [<ffffffff810e3f73>] do_lookup+0xde/0x1ca
Apr 10 09:59:09 alfa kernel:  [<ffffffff810e65b6>] 
__link_path_walk+0x84e/0xcb3
Apr 10 09:59:09 alfa kernel:  [<ffffffff810e4462>] ? path_init+0xaf/0x156
Apr 10 09:59:09 alfa kernel:  [<ffffffff810e6a6e>] path_walk+0x53/0x9c
Apr 10 09:59:09 alfa kernel:  [<ffffffff810e6b9e>] do_path_lookup+0x2f/0xac
Apr 10 09:59:09 alfa kernel:  [<ffffffff810e7603>] user_path_at+0x57/0x91
Apr 10 09:59:09 alfa kernel:  [<ffffffff810ec2e5>] ? dput+0x54/0x132
Apr 10 09:59:09 alfa kernel:  [<ffffffff810df492>] ? cp_new_stat+0xfb/0x114
Apr 10 09:59:09 alfa kernel:  [<ffffffff810df670>] vfs_fstatat+0x3a/0x67
Apr 10 09:59:09 alfa kernel:  [<ffffffff810df6f4>] vfs_lstat+0x1e/0x20
Apr 10 09:59:09 alfa kernel:  [<ffffffff810df715>] sys_newlstat+0x1f/0x39
Apr 10 09:59:09 alfa kernel:  [<ffffffff8175d2d3>] ? 
trace_hardirqs_on_thunk+0x3a/0x3f
Apr 10 09:59:09 alfa kernel:  [<ffffffff811d3f36>] ? xfs_iget+0x317/0x455
Apr 10 09:59:09 alfa kernel:  [<ffffffff8100b09b>] 
system_call_fastpath+0x16/0x1b
Apr 10 09:59:09 alfa kernel: Filesystem "sdb2": corrupt inode 673160713 
((a)extents = 16777217).  Unmount and run xfs_repair.
Apr 10 09:59:09 alfa kernel: ffff880153797900: 49 4e 81 a4 01 02 00 01 00 00 
00 30 00 00 00 30  IN.........0...0
Apr 10 09:59:09 alfa kernel: Filesystem "sdb2": XFS internal error 
xfs_iformat_extents(1) at line 558 of file fs/xfs/xfs_inode.c.  Caller 
0xffffffff811d6e70
Apr 10 09:59:09 alfa kernel:

All reports sdb2 for corruption.
I will test this partition as soon as i can plan some minute planned 
pause....

Thanks for all your help again.

Best Regards:
Janos Haar



----- Original Message ----- 
From: "Dave Chinner" <david@fromorbit.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: <xiyou.wangcong@gmail.com>; <linux-kernel@vger.kernel.org>; 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
<axboe@kernel.dk>
Sent: Thursday, April 08, 2010 4:58 AM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Thu, Apr 08, 2010 at 04:45:13AM +0200, Janos Haar wrote:
>> Hello,
>>
>> Sorry, but still have the problem with 2.6.33.2.
>
> Yeah, these still a fix that needs to be back ported to .33
> to solve this problem. It's in the series for 2.6.32.x, so maybe
> pulling the 2.6.32-stable-queue tree in the meantime is your best
> bet.
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
