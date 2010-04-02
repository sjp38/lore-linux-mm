Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CBD446B01EE
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:13:15 -0400 (EDT)
Message-ID: <1fe901cad2b0$d39d0300$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <03ca01cacb92$195adf50$0400a8c0@dcccs> <2375c9f91003242029p1efbbea1v8e313e460b118f14@mail.gmail.com> <20100325153110.6be9a3df.kamezawa.hiroyu@jp.fujitsu.com> <02c101cacbf8$d21d1650$0400a8c0@dcccs> <179901cad182$5f87f620$0400a8c0@dcccs> <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com>
Subject: Re: Somebody take a look please! (some kind of kernel bug?)
Date: Sat, 3 Apr 2010 00:07:00 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="UTF-8";
	reply-type=original
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

Hello,

----- Original Message ----- 
From: "AmA(C)rico Wang" <xiyou.wangcong@gmail.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: <linux-kernel@vger.kernel.org>; "KAMEZAWA Hiroyuki" 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
"Jens Axboe" <axboe@kernel.dk>
Sent: Thursday, April 01, 2010 12:37 PM
Subject: Re: Somebody take a look please! (some kind of kernel bug?)


> On Thu, Apr 1, 2010 at 6:01 PM, Janos Haar <janos.haar@netcenter.hu> 
> wrote:
>> Hello,
>>
>
> Hi,
> This is a totally different bug from the previous one reported by you. :)

Today i have got this again, exactly the same. (if somebody wants the log, 
just ask)
There is a cut:

Apr  1 18:50:02 alfa kernel: possible SYN flooding on port 80. Sending 
cookies.
Apr  2 21:16:59 alfa kernel: BUG: unable to handle kernel paging request at 
000000010000008c
Apr  2 21:16:59 alfa kernel: IP: [<ffffffff811d755b>] 
xfs_iflush_cluster+0x148/0x35a
Apr  2 21:16:59 alfa kernel: PGD a7374067 PUD 0
Apr  2 21:16:59 alfa kernel: Oops: 0000 [#1] SMP
Apr  2 21:16:59 alfa kernel: last sysfs file: /sys/class/misc/rfkill/dev
Apr  2 21:16:59 alfa kernel: CPU 1
Apr  2 21:16:59 alfa kernel: Modules linked in: hidp l2cap crc16 bluetooth 
rfkill ipv6 video output sbs sbshc battery ac parport_pc lp parport 8250_pnp 
serio_
raw shpchp 8250 serial_core i2c_i801 button pcspkr i2c_core
Apr  2 21:16:59 alfa kernel: Pid: 3118, comm: flush-8:16 Not tainted 
2.6.32.10 #2
Apr  2 21:16:59 alfa kernel: RIP: 0010:[<ffffffff811d755b>] 
[<ffffffff811d755b>] xfs_iflush_cluster+0x148/0x35a
Apr  2 21:16:59 alfa kernel: RSP: 0000:ffff88022849db60  EFLAGS: 00010206
Apr  2 21:16:59 alfa kernel: RAX: 0000000100000000 RBX: ffff8801535b47d0 
RCX: 000000000000001a
Apr  2 21:16:59 alfa kernel: RDX: 0000000000000020 RSI: ffff880178e49158 
RDI: ffff88022a5c8138
Apr  2 21:16:59 alfa kernel: RBP: ffff88022849dbd0 R08: 0000000000000001 
R09: ffff880137ba67a0
Apr  2 21:16:59 alfa kernel: R10: ffff88022849db50 R11: 0000000000000020 
R12: ffff880137ba6858
Apr  2 21:16:59 alfa kernel: R13: ffff880115f4cd68 R14: ffff88022953a9e0 
R15: 000000000061d440
Apr  2 21:16:59 alfa kernel: FS:  0000000000000000(0000) 
GS:ffff880028280000(0000) knlGS:0000000000000000
Apr  2 21:16:59 alfa kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 
000000008005003b
Apr  2 21:16:59 alfa kernel: CR2: 000000010000008c CR3: 0000000028154000 
CR4: 00000000000006e0
Apr  2 21:16:59 alfa kernel: DR0: 0000000000000000 DR1: 0000000000000000 
DR2: 0000000000000000
Apr  2 21:16:59 alfa kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 
DR7: 0000000000000400
Apr  2 21:16:59 alfa kernel: Process flush-8:16 (pid: 3118, threadinfo 
ffff88022849c000, task ffff88022a4f4040)
Apr  2 21:16:59 alfa kernel: Stack:
Apr  2 21:16:59 alfa kernel:  ffff88022953a9e0 ffff8801d8ac58d0 
ffff88022960f7a8 ffffffffffffffe0
Apr  2 21:16:59 alfa kernel: <0> 0000000000000020 ffff8801d53bb5e8 
000000202849dbd0 0000000a00000001
Apr  2 21:16:59 alfa kernel: <0> ffff8801d53bb638 ffff880115f4cd68 
ffff8801d8ac58d0 0000000000000002
Apr  2 21:16:59 alfa kernel: Call Trace:
Apr  2 21:16:59 alfa kernel:  [<ffffffff811d7931>] xfs_iflush+0x1c4/0x272
Apr  2 21:16:59 alfa kernel:  [<ffffffff8103458e>] ? 
try_wait_for_completion+0x24/0x45
Apr  2 21:16:59 alfa kernel:  [<ffffffff811f819c>] 
xfs_fs_write_inode+0xe0/0x11e
Apr  2 21:16:59 alfa kernel:  [<ffffffff810f7bcf>] 
writeback_single_inode+0x109/0x215
Apr  2 21:16:59 alfa kernel:  [<ffffffff810f84bd>] 
writeback_inodes_wb+0x33a/0x3cc
Apr  2 21:16:59 alfa kernel:  [<ffffffff810f8686>] wb_writeback+0x137/0x1c7
Apr  2 21:16:59 alfa kernel:  [<ffffffff810f8830>] ? 
wb_do_writeback+0x7d/0x1ae
Apr  2 21:16:59 alfa kernel:  [<ffffffff810f892c>] 
wb_do_writeback+0x179/0x1ae
Apr  2 21:16:59 alfa kernel:  [<ffffffff810f8830>] ? 
wb_do_writeback+0x7d/0x1ae
Apr  2 21:16:59 alfa kernel:  [<ffffffff8105064c>] ? 
process_timeout+0x0/0x10
Apr  2 21:16:59 alfa kernel:  [<ffffffff810c10ed>] ? bdi_start_fn+0x0/0xd1
Apr  2 21:16:59 alfa kernel:  [<ffffffff810f898d>] 
bdi_writeback_task+0x2c/0xa2
Apr  2 21:16:59 alfa kernel:  [<ffffffff810c1163>] bdi_start_fn+0x76/0xd1
Apr  2 21:16:59 alfa kernel:  [<ffffffff810c10ed>] ? bdi_start_fn+0x0/0xd1
Apr  2 21:16:59 alfa kernel:  [<ffffffff8105dda1>] kthread+0x82/0x8d
Apr  2 21:16:59 alfa kernel:  [<ffffffff8100c15a>] child_rip+0xa/0x20
Apr  2 21:16:59 alfa kernel:  [<ffffffff8100bafc>] ? restore_args+0x0/0x30
Apr  2 21:16:59 alfa kernel:  [<ffffffff81038596>] ? 
finish_task_switch+0x0/0xbc
Apr  2 21:16:59 alfa kernel:  [<ffffffff8105dd1f>] ? kthread+0x0/0x8d
Apr  2 21:16:59 alfa kernel:  [<ffffffff8100c150>] ? child_rip+0x0/0x20
Apr  2 21:16:59 alfa kernel: Code: 8e eb 01 00 00 b8 01 00 00 00 48 d3 e0 ff 
c8 23 43 18 48 23 45 a8 4c 39 f8 0f 85 ae 00 00 00 48 8b 83 80 00 00 00 48 
85 c0
74 0b <66> f7 80 8c 00 00 00 ff 01 75 13 80 bb 0a 02 00 00 00 75 0a 8b
Apr  2 21:16:59 alfa kernel: RIP  [<ffffffff811d755b>] 
xfs_iflush_cluster+0x148/0x35a
Apr  2 21:16:59 alfa kernel:  RSP <ffff88022849db60>
Apr  2 21:16:59 alfa kernel: CR2: 000000010000008c
Apr  2 21:16:59 alfa kernel: ---[ end trace 7528355f76bf7b08 ]---
Apr  2 21:17:53 alfa kernel: BUG: soft lockup - CPU#3 stuck for 61s! 
[httpd:17617]
Apr  2 21:17:53 alfa kernel: Modules linked in: hidp l2cap crc16 bluetooth 
rfkill ipv6 video output sbs sbshc battery ac parport_pc lp parport 8250_pnp 
serio_
raw shpchp 8250 serial_core i2c_i801 button pcspkr i2c_core
Apr  2 21:17:53 alfa kernel: CPU 3:
Apr  2 21:17:53 alfa kernel: Modules linked in: hidp l2cap crc16 bluetooth 
rfkill ipv6 video output sbs sbshc battery ac parport_pc lp parport 8250_pnp 
serio_
raw shpchp 8250 serial_core i2c_i801 button pcspkr i2c_core
Apr  2 21:17:53 alfa kernel: Pid: 17617, comm: httpd Tainted: G      D 
2.6.32.10 #2
Apr  2 21:17:53 alfa kernel: RIP: 0010:[<ffffffff8171a0cf>] 
[<ffffffff8171a0cf>] __write_lock_failed+0xf/0x20
Apr  2 21:17:53 alfa kernel: RSP: 0018:ffff8800a46b1a20  EFLAGS: 00000287
Apr  2 21:17:53 alfa kernel: RAX: 0000000000000003 RBX: ffff8800a46b1a38 
RCX: 0000000000000000
Apr  2 21:17:53 alfa kernel: RDX: 0000000000000000 RSI: 0000000000000000 
RDI: ffff88022960f7a8
Apr  2 21:17:53 alfa kernel: RBP: ffffffff8100bc2e R08: 0000000000000001 
R09: 0000000000000000
Apr  2 21:17:53 alfa kernel: R10: ffffffff812f1fcf R11: 0000000000014001 
R12: ffff88002838e820
Apr  2 21:17:53 alfa kernel: R13: 0000000000005033 R14: ffff8800a46b0000 
R15: 0000000000000100
Apr  2 21:17:53 alfa kernel: FS:  00007feea89c26f0(0000) 
GS:ffff880028380000(0000) knlGS:0000000000000000
Apr  2 21:17:53 alfa kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 
0000000080050033
Apr  2 21:17:53 alfa kernel: CR2: 0000000000edba48 CR3: 000000017b034000 
CR4: 00000000000006e0
Apr  2 21:17:53 alfa kernel: DR0: 0000000000000000 DR1: 0000000000000000 
DR2: 0000000000000000
Apr  2 21:17:53 alfa kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 
DR7: 0000000000000400
Apr  2 21:17:53 alfa kernel: Call Trace:
Apr  2 21:17:53 alfa kernel:  [<ffffffff812fa0b0>] ? 
_raw_write_lock+0x6a/0x7e
Apr  2 21:17:53 alfa kernel:  [<ffffffff8175d8ce>] ? _write_lock+0x39/0x3e
Apr  2 21:17:53 alfa kernel:  [<ffffffff811d3ea1>] ? xfs_iget+0x2e3/0x422
Apr  2 21:17:53 alfa kernel:  [<ffffffff811d3ea1>] ? xfs_iget+0x2e3/0x422
Apr  2 21:17:53 alfa kernel:  [<ffffffff811e9591>] ? 
xfs_trans_iget+0x2a/0x55
Apr  2 21:17:53 alfa kernel:  [<ffffffff811d7a7a>] ? xfs_ialloc+0x9b/0x569
Apr  2 21:17:53 alfa kernel:  [<ffffffff8175d0b4>] ? 
__down_write_nested+0x1a/0xa1
Apr  2 21:17:53 alfa kernel:  [<ffffffff811e9ea3>] ? 
xfs_dir_ialloc+0x78/0x289
Apr  2 21:17:53 alfa kernel:  [<ffffffff81060dd2>] ? 
down_write_nested+0x52/0x59
Apr  2 21:17:53 alfa kernel:  [<ffffffff811ec35f>] ? xfs_create+0x317/0x526
Apr  2 21:17:53 alfa kernel:  [<ffffffff811f5642>] ? xfs_vn_mknod+0xdb/0x171
Apr  2 21:17:53 alfa kernel:  [<ffffffff811f56fd>] ? xfs_vn_create+0x10/0x12
Apr  2 21:17:53 alfa kernel:  [<ffffffff810e5844>] ? vfs_create+0xee/0x18c
Apr  2 21:17:53 alfa kernel:  [<ffffffff810e7c46>] ? 
do_filp_open+0x31a/0x99f
Apr  2 21:17:53 alfa kernel:  [<ffffffff810df47e>] ? cp_new_stat+0xfb/0x114
Apr  2 21:17:53 alfa kernel:  [<ffffffff810f0e8e>] ? alloc_fd+0x38/0x123
Apr  2 21:17:53 alfa kernel:  [<ffffffff8175d6b1>] ? _spin_unlock+0x2b/0x2f
Apr  2 21:17:53 alfa kernel:  [<ffffffff810d9f3b>] ? do_sys_open+0x62/0x109
Apr  2 21:17:53 alfa kernel:  [<ffffffff810da015>] ? sys_open+0x20/0x22
Apr  2 21:17:53 alfa kernel:  [<ffffffff8100b09b>] ? 
system_call_fastpath+0x16/0x1b
Apr  2 21:18:59 alfa kernel: BUG: soft lockup - CPU#3 stuck for 61s! 
[httpd:17617]
Apr  2 21:31:26 alfa syslogd 1.4.1: restart.


It looks like i can reproduce the but on this server on every 2-3 days.
The only problem is, my customer will kill me if i can't fix it soon. :-)

Can somebody help me or suggest another solution to avoid this problem?

Thanks a lot,

Janos Haar


>
>> Another issue with this productive server:
>> Can somebody point me to the rigth direction?
>> Or support that this is a hw problem or not?
>
>
> Probably no, it looks like an XFS bug or a write-back bug.
>
> Thanks for your report. Cc'ing related people...
>
>
>>
>> The messages file are here:
>> http://download.netcenter.hu/bughunt/20100324/marc30
>>
>> Thanks,
>> Janos Haar
>>
>> Mar 30 18:51:43 alfa kernel: BUG: unable to handle kernel paging request 
>> at
>> 000000320000008c
>> Mar 30 18:51:43 alfa kernel: IP: [<ffffffff811d755b>]
>> xfs_iflush_cluster+0x148/0x35a
>> Mar 30 18:51:43 alfa kernel: PGD 102d7a067 PUD 0
>> Mar 30 18:51:43 alfa kernel: Oops: 0000 [#1] SMP
>> Mar 30 18:51:43 alfa kernel: last sysfs file: /sys/class/misc/rfkill/dev
>> Mar 30 18:51:43 alfa kernel: CPU 0
>> Mar 30 18:51:43 alfa kernel: Modules linked in: hidp l2cap crc16 
>> bluetooth
>> rfkill ipv6 video output sbs sbshc battery ac parport_pc lp parport
>> serio_raw 8250_
>> pnp 8250 serial_core shpchp button i2c_i801 i2c_core pcspkr
>> Mar 30 18:51:43 alfa kernel: Pid: 3242, comm: flush-8:16 Not tainted
>> 2.6.32.10 #2
>> Mar 30 18:51:43 alfa kernel: RIP: 0010:[<ffffffff811d755b>]
>> [<ffffffff811d755b>] xfs_iflush_cluster+0x148/0x35a
>> Mar 30 18:51:43 alfa kernel: RSP: 0000:ffff880228ce5b60 EFLAGS: 00010206
>> Mar 30 18:51:43 alfa kernel: RAX: 0000003200000000 RBX: ffff8801537947d0
>> RCX: 000000000000001a
>> Mar 30 18:51:43 alfa kernel: RDX: 0000000000000020 RSI: 00000000000c6cc2
>> RDI: 0000000000000001
>> Mar 30 18:51:43 alfa kernel: RBP: ffff880228ce5bd0 R08: ffff880228ce5b20
>> R09: ffff8801ea436928
>> Mar 30 18:51:43 alfa kernel: R10: 00000000000c6cc2 R11: 0000000000000001
>> R12: ffff8800b630b11a
>> Mar 30 18:51:43 alfa kernel: R13: ffff8801bd54ab30 R14: ffff88022962d2b8
>> R15: 00000000000c6ca0
>> Mar 30 18:51:43 alfa kernel: FS: 0000000000000000(0000)
>> GS:ffff880028200000(0000) knlGS:0000000000000000
>> Mar 30 18:51:43 alfa kernel: CS: 0010 DS: 0018 ES: 0018 CR0:
>> 000000008005003b
>> Mar 30 18:51:43 alfa kernel: CR2: 000000320000008c CR3: 0000000168e75000
>> CR4: 00000000000006f0
>> Mar 30 18:51:43 alfa kernel: DR0: 0000000000000000 DR1: 0000000000000000
>> DR2: 0000000000000000
>> Mar 30 18:51:43 alfa kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0
>> DR7: 0000000000000400
>> Mar 30 18:51:43 alfa kernel: Process flush-8:16 (pid: 3242, threadinfo
>> ffff880228ce4000, task ffff880228ea4040)
>> Mar 30 18:51:43 alfa kernel: Stack:
>> Mar 30 18:51:43 alfa kernel: ffff8801bd54ab30 ffff8800b630b140
>> ffff88022a2d99d0 ffffffffffffffe0
>> Mar 30 18:51:43 alfa kernel: <0> 0000000000000020 ffff880218e3db60
>> 0000002028ce5bd0 0000000200000000
>> Mar 30 18:51:43 alfa kernel: <0> ffff880218e3db70 ffff8801bd54ab30
>> ffff8800b630b140 0000000000000002
>> Mar 30 18:51:43 alfa kernel: Call Trace:
>> Mar 30 18:51:43 alfa kernel: [<ffffffff811d7931>] xfs_iflush+0x1c4/0x272
>> Mar 30 18:51:43 alfa kernel: [<ffffffff8103458e>] ?
>> try_wait_for_completion+0x24/0x45
>> Mar 30 18:51:43 alfa kernel: [<ffffffff811f819c>]
>> xfs_fs_write_inode+0xe0/0x11e
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810f7bcf>]
>> writeback_single_inode+0x109/0x215
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810f84bd>]
>> writeback_inodes_wb+0x33a/0x3cc
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810f8686>] 
>> wb_writeback+0x137/0x1c7
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810f8830>] ?
>> wb_do_writeback+0x7d/0x1ae
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810f892c>]
>> wb_do_writeback+0x179/0x1ae
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810f8830>] ?
>> wb_do_writeback+0x7d/0x1ae
>> Mar 30 18:51:43 alfa kernel: [<ffffffff8105064c>] ?
>> process_timeout+0x0/0x10
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810c10ed>] ? bdi_start_fn+0x0/0xd1
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810f898d>]
>> bdi_writeback_task+0x2c/0xa2
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810c1163>] bdi_start_fn+0x76/0xd1
>> Mar 30 18:51:43 alfa kernel: [<ffffffff810c10ed>] ? bdi_start_fn+0x0/0xd1
>> Mar 30 18:51:43 alfa kernel: [<ffffffff8105dda1>] kthread+0x82/0x8d
>> Mar 30 18:51:43 alfa kernel: [<ffffffff8100c15a>] child_rip+0xa/0x20
>> Mar 30 18:51:43 alfa kernel: [<ffffffff8100bafc>] ? restore_args+0x0/0x30
>> Mar 30 18:51:43 alfa kernel: [<ffffffff81038596>] ?
>> finish_task_switch+0x0/0xbc
>> Mar 30 18:51:43 alfa kernel: [<ffffffff8105dd1f>] ? kthread+0x0/0x8d
>> Mar 30 18:51:43 alfa kernel: [<ffffffff8100c150>] ? child_rip+0x0/0x20
>> Mar 30 18:51:43 alfa kernel: Code: 8e eb 01 00 00 b8 01 00 00 00 48 d3 e0 
>> ff
>> c8 23 43 18 48 23 45 a8 4c 39 f8 0f 85 ae 00 00 00 48 8b 83 80 00 00 00 
>> 48
>> 85 c0
>> 74 0b <66> f7 80 8c 00 00 00 ff 01 75 13 80 bb 0a 02 00 00 00 75 0a 8b
>> Mar 30 18:51:43 alfa kernel: RIP [<ffffffff811d755b>]
>> xfs_iflush_cluster+0x148/0x35a
>> Mar 30 18:51:43 alfa kernel: RSP <ffff880228ce5b60>
>> Mar 30 18:51:43 alfa kernel: CR2: 000000320000008c
>> Mar 30 18:51:43 alfa kernel: ---[ end trace e6c8391ea76602f4 ]---
>> Mar 30 18:51:43 alfa kernel: flush-8:16 used greatest stack depth: 2464
>> bytes left
>> Mar 30 19:09:39 alfa syslogd 1.4.1: restart.
>>
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
