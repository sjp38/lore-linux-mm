Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A93E86B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:00:20 -0400 (EDT)
Message-ID: <18b101cadadf$5edbb660$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com> <1fe901cad2b0$d39d0300$0400a8c0@dcccs> <20100402230905.GW3335@dastard> <22c901cad333$7a67db60$0400a8c0@dcccs> <20100404103701.GX3335@dastard> <2bd101cad4ec$5a425f30$0400a8c0@dcccs> <20100405224522.GZ3335@dastard> <3a5f01cad6c5$8a722c00$0400a8c0@dcccs> <20100408025822.GL11036@dastard> <11b701cad9c8$93212530$0400a8c0@dcccs> <20100412001158.GA2493@dastard>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Tue, 13 Apr 2010 10:00:17 +0200
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


----- Original Message ----- 
From: "Dave Chinner" <david@fromorbit.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: <xiyou.wangcong@gmail.com>; <linux-kernel@vger.kernel.org>; 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
<axboe@kernel.dk>
Sent: Monday, April 12, 2010 2:11 AM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Mon, Apr 12, 2010 at 12:44:37AM +0200, Janos Haar wrote:
>> Hi,
>>
>> Ok, here comes the funny part:
>> I have got several messages from the kernel about one of my XFS
>> (sdb2) have corrupted inodes, but my xfs_repair (v. 2.8.11) says the
>> FS is clean and shine.
>> Should i upgrade my xfs_repair, or this is another bug? :-)
>
> v2.8.11 is positively ancient. :/
>
> I'd upgrade (current is 3.1.1) and re-run repair again.

OK, i will get the new repair today.

btw
Since i tested the FS with the 2.8.11, today morning i found this in the 
log:

...
Apr 12 00:41:10 alfa kernel: XFS mounting filesystem sdb2   # This was the 
point of check with xfs_repair v2.8.11
Apr 13 03:08:33 alfa kernel: xfs_da_do_buf: bno 32768
Apr 13 03:08:33 alfa kernel: dir: inode 474253931
Apr 13 03:08:33 alfa kernel: Filesystem "sdb2": XFS internal error 
xfs_da_do_buf(1) at line 2020 of file fs/xfs/xfs_da_btree.c.  Caller 
0xffffffff811c4fa6
Apr 13 03:08:33 alfa kernel:
Apr 13 03:08:33 alfa kernel: Pid: 27304, comm: 01vegzet_runner Not tainted 
2.6.32.10 #3
Apr 13 03:08:33 alfa kernel: Call Trace:
Apr 13 03:08:33 alfa kernel:  [<ffffffff811cf87d>] 
xfs_error_report+0x41/0x43
Apr 13 03:08:33 alfa kernel:  [<ffffffff811c4fa6>] ? 
xfs_da_read_buf+0x2a/0x2c
Apr 13 03:08:33 alfa kernel:  [<ffffffff811c4c30>] xfs_da_do_buf+0x2a6/0x5aa
Apr 13 03:08:33 alfa kernel:  [<ffffffff811c4fa6>] xfs_da_read_buf+0x2a/0x2c
Apr 13 03:08:33 alfa kernel:  [<ffffffff811ca0f1>] ? 
xfs_dir2_leaf_lookup_int+0x104/0x259
Apr 13 03:08:33 alfa kernel:  [<ffffffff811ca0f1>] 
xfs_dir2_leaf_lookup_int+0x104/0x259
Apr 13 03:08:33 alfa kernel:  [<ffffffff811ca56e>] 
xfs_dir2_leaf_lookup+0x26/0xb5
Apr 13 03:08:33 alfa kernel:  [<ffffffff811c6d60>] ? 
xfs_dir2_isleaf+0x21/0x52
Apr 13 03:08:33 alfa kernel:  [<ffffffff811c74ea>] 
xfs_dir_lookup+0x104/0x157
Apr 13 03:08:33 alfa kernel:  [<ffffffff811eab59>] xfs_lookup+0x50/0xb3
Apr 13 03:08:33 alfa kernel:  [<ffffffff811f5a8f>] xfs_vn_lookup+0x45/0x86
Apr 13 03:08:33 alfa kernel:  [<ffffffff810e4164>] __lookup_hash+0x105/0x12a
Apr 13 03:08:33 alfa kernel:  [<ffffffff810e41c4>] lookup_hash+0x3b/0x40
Apr 13 03:08:33 alfa kernel:  [<ffffffff810e7021>] do_unlinkat+0x71/0x17d
Apr 13 03:08:33 alfa kernel:  [<ffffffff8175d2d3>] ? 
trace_hardirqs_on_thunk+0x3a/0x3f
Apr 13 03:08:33 alfa kernel:  [<ffffffff810e5a1d>] ? putname+0x3c/0x3e
Apr 13 03:08:33 alfa kernel:  [<ffffffff810e7143>] sys_unlink+0x16/0x18
Apr 13 03:08:33 alfa kernel:  [<ffffffff8100b09b>] 
system_call_fastpath+0x16/0x1b
....

The entire log is here:
http://download.netcenter.hu/bughunt/20100413/messages

What is the best next step?
Check with the new repair?

Thanks,
Janos


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
