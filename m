Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 058A06B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 06:08:02 -0400 (EDT)
Message-ID: <179901cad182$5f87f620$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <03ca01cacb92$195adf50$0400a8c0@dcccs><2375c9f91003242029p1efbbea1v8e313e460b118f14@mail.gmail.com> <20100325153110.6be9a3df.kamezawa.hiroyu@jp.fujitsu.com> <02c101cacbf8$d21d1650$0400a8c0@dcccs>
Subject: Re: Somebody take a look please! (some kind of kernel bug?)
Date: Thu, 1 Apr 2010 12:01:57 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="UTF-8";
	reply-type=response
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, xiyou.wangcong@gmail.com
List-ID: <linux-mm.kvack.org>

Hello,

Another issue with this productive server:
Can somebody point me to the rigth direction?
Or support that this is a hw problem or not?

The messages file are here: 
http://download.netcenter.hu/bughunt/20100324/marc30

Thanks,
Janos Haar

Mar 30 18:51:43 alfa kernel: BUG: unable to handle kernel paging request at 
000000320000008c
Mar 30 18:51:43 alfa kernel: IP: [<ffffffff811d755b>] 
xfs_iflush_cluster+0x148/0x35a
Mar 30 18:51:43 alfa kernel: PGD 102d7a067 PUD 0
Mar 30 18:51:43 alfa kernel: Oops: 0000 [#1] SMP
Mar 30 18:51:43 alfa kernel: last sysfs file: /sys/class/misc/rfkill/dev
Mar 30 18:51:43 alfa kernel: CPU 0
Mar 30 18:51:43 alfa kernel: Modules linked in: hidp l2cap crc16 bluetooth 
rfkill ipv6 video output sbs sbshc battery ac parport_pc lp parport 
serio_raw 8250_
pnp 8250 serial_core shpchp button i2c_i801 i2c_core pcspkr
Mar 30 18:51:43 alfa kernel: Pid: 3242, comm: flush-8:16 Not tainted 
2.6.32.10 #2
Mar 30 18:51:43 alfa kernel: RIP: 0010:[<ffffffff811d755b>] 
[<ffffffff811d755b>] xfs_iflush_cluster+0x148/0x35a
Mar 30 18:51:43 alfa kernel: RSP: 0000:ffff880228ce5b60  EFLAGS: 00010206
Mar 30 18:51:43 alfa kernel: RAX: 0000003200000000 RBX: ffff8801537947d0 
RCX: 000000000000001a
Mar 30 18:51:43 alfa kernel: RDX: 0000000000000020 RSI: 00000000000c6cc2 
RDI: 0000000000000001
Mar 30 18:51:43 alfa kernel: RBP: ffff880228ce5bd0 R08: ffff880228ce5b20 
R09: ffff8801ea436928
Mar 30 18:51:43 alfa kernel: R10: 00000000000c6cc2 R11: 0000000000000001 
R12: ffff8800b630b11a
Mar 30 18:51:43 alfa kernel: R13: ffff8801bd54ab30 R14: ffff88022962d2b8 
R15: 00000000000c6ca0
Mar 30 18:51:43 alfa kernel: FS:  0000000000000000(0000) 
GS:ffff880028200000(0000) knlGS:0000000000000000
Mar 30 18:51:43 alfa kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 
000000008005003b
Mar 30 18:51:43 alfa kernel: CR2: 000000320000008c CR3: 0000000168e75000 
CR4: 00000000000006f0
Mar 30 18:51:43 alfa kernel: DR0: 0000000000000000 DR1: 0000000000000000 
DR2: 0000000000000000
Mar 30 18:51:43 alfa kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 
DR7: 0000000000000400
Mar 30 18:51:43 alfa kernel: Process flush-8:16 (pid: 3242, threadinfo 
ffff880228ce4000, task ffff880228ea4040)
Mar 30 18:51:43 alfa kernel: Stack:
Mar 30 18:51:43 alfa kernel:  ffff8801bd54ab30 ffff8800b630b140 
ffff88022a2d99d0 ffffffffffffffe0
Mar 30 18:51:43 alfa kernel: <0> 0000000000000020 ffff880218e3db60 
0000002028ce5bd0 0000000200000000
Mar 30 18:51:43 alfa kernel: <0> ffff880218e3db70 ffff8801bd54ab30 
ffff8800b630b140 0000000000000002
Mar 30 18:51:43 alfa kernel: Call Trace:
Mar 30 18:51:43 alfa kernel:  [<ffffffff811d7931>] xfs_iflush+0x1c4/0x272
Mar 30 18:51:43 alfa kernel:  [<ffffffff8103458e>] ? 
try_wait_for_completion+0x24/0x45
Mar 30 18:51:43 alfa kernel:  [<ffffffff811f819c>] 
xfs_fs_write_inode+0xe0/0x11e
Mar 30 18:51:43 alfa kernel:  [<ffffffff810f7bcf>] 
writeback_single_inode+0x109/0x215
Mar 30 18:51:43 alfa kernel:  [<ffffffff810f84bd>] 
writeback_inodes_wb+0x33a/0x3cc
Mar 30 18:51:43 alfa kernel:  [<ffffffff810f8686>] wb_writeback+0x137/0x1c7
Mar 30 18:51:43 alfa kernel:  [<ffffffff810f8830>] ? 
wb_do_writeback+0x7d/0x1ae
Mar 30 18:51:43 alfa kernel:  [<ffffffff810f892c>] 
wb_do_writeback+0x179/0x1ae
Mar 30 18:51:43 alfa kernel:  [<ffffffff810f8830>] ? 
wb_do_writeback+0x7d/0x1ae
Mar 30 18:51:43 alfa kernel:  [<ffffffff8105064c>] ? 
process_timeout+0x0/0x10
Mar 30 18:51:43 alfa kernel:  [<ffffffff810c10ed>] ? bdi_start_fn+0x0/0xd1
Mar 30 18:51:43 alfa kernel:  [<ffffffff810f898d>] 
bdi_writeback_task+0x2c/0xa2
Mar 30 18:51:43 alfa kernel:  [<ffffffff810c1163>] bdi_start_fn+0x76/0xd1
Mar 30 18:51:43 alfa kernel:  [<ffffffff810c10ed>] ? bdi_start_fn+0x0/0xd1
Mar 30 18:51:43 alfa kernel:  [<ffffffff8105dda1>] kthread+0x82/0x8d
Mar 30 18:51:43 alfa kernel:  [<ffffffff8100c15a>] child_rip+0xa/0x20
Mar 30 18:51:43 alfa kernel:  [<ffffffff8100bafc>] ? restore_args+0x0/0x30
Mar 30 18:51:43 alfa kernel:  [<ffffffff81038596>] ? 
finish_task_switch+0x0/0xbc
Mar 30 18:51:43 alfa kernel:  [<ffffffff8105dd1f>] ? kthread+0x0/0x8d
Mar 30 18:51:43 alfa kernel:  [<ffffffff8100c150>] ? child_rip+0x0/0x20
Mar 30 18:51:43 alfa kernel: Code: 8e eb 01 00 00 b8 01 00 00 00 48 d3 e0 ff 
c8 23 43 18 48 23 45 a8 4c 39 f8 0f 85 ae 00 00 00 48 8b 83 80 00 00 00 48 
85 c0
74 0b <66> f7 80 8c 00 00 00 ff 01 75 13 80 bb 0a 02 00 00 00 75 0a 8b
Mar 30 18:51:43 alfa kernel: RIP  [<ffffffff811d755b>] 
xfs_iflush_cluster+0x148/0x35a
Mar 30 18:51:43 alfa kernel:  RSP <ffff880228ce5b60>
Mar 30 18:51:43 alfa kernel: CR2: 000000320000008c
Mar 30 18:51:43 alfa kernel: ---[ end trace e6c8391ea76602f4 ]---
Mar 30 18:51:43 alfa kernel: flush-8:16 used greatest stack depth: 2464 
bytes left
Mar 30 19:09:39 alfa syslogd 1.4.1: restart.

----- Original Message ----- 
From: "Janos Haar" <janos.haar@netcenter.hu>
To: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
Cc: <xiyou.wangcong@gmail.com>; <linux-kernel@vger.kernel.org>; 
<linux-mm@kvack.org>
Sent: Thursday, March 25, 2010 10:54 AM
Subject: Re: Somebody take a look please! (some kind of kernel bug?)


>
> ----- Original Message ----- 
> From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
> To: "AmA(C)rico Wang" <xiyou.wangcong@gmail.com>
> Cc: "Janos Haar" <janos.haar@netcenter.hu>; 
> <linux-kernel@vger.kernel.org>; <linux-mm@kvack.org>
> Sent: Thursday, March 25, 2010 7:31 AM
> Subject: Re: Somebody take a look please! (some kind of kernel bug?)
>
>
>> On Thu, 25 Mar 2010 11:29:25 +0800
>> AmA(C)rico Wang <xiyou.wangcong@gmail.com> wrote:
>>
>>> (Cc'ing linux-mm)
>>>
>> Hmm..here is summary of corruption (from log), but no idea.
>>
>> ==
>> process's address pte       pnf->pte->page
>>
>> 00000037b4008000   2bf1e025 -> PG_reserved
>> 00000037b400a000 d900000000 -> bad swap
>> 00000037b400c000   2bfe8025 -> PG_reserved
>> 00000037b400d000  12bfe9025 -> belongs to some other files' page cache
>> 00000037b400e000 ff00000000 -> bad swap
>> 00000037b400f000 5400000000 -> bad swap
>> ...
>> 00000037b4019000 ff00000000 -> bad swap
>> ==
>> All ptes are on the same pmd 1535b5067.
>> .
>> I doubt some kind of buffer overflow bug overwrites page table...
>> Because ptes for adddress of 00000037b4008000...00000037b400f000 are on 
>> head of
>
> This is only one bit, right? :-)
>
>> a page (used for pmd), some data on page [0x1535b4000..0x1535b5000) 
>> caused buffer
>> overflow and broke page table in [0x1535b5000...0x1535b6000)
>>
>> Is this bug found from 2.6.28.10 ?
>
> No, the bug, what i have sent was from 2.6.32.10. (you can check it from 
> the messages file in the link)
> The story begins about marc 9-10 but unfortunately the system not all the 
> time was able to write down the messages file.
> (At Mar 13 11:20:09 i have triggered the sysreq's process and memory 
> information, you can see it in the link below.)
> We have more crashes with the 2.6.28.10 in the next some day and the 
> server is removed for testing (7 days hole in the log), but looks stable
>
> Here is more serious crashes from the 2.6.28.10:
>
> http://download.netcenter.hu/bughunt/20100324/marc11-14
>
> For me looks like all memory, swap and xfs related.
> I have tested/repaired all the filesystems offline, corrected the errors 
> wich was left by the previous crashes, than disabled the swap, but nothing 
> helps. :(
>
> Finally in marc 21, i have replaced the kernel to the 32.10, and the 
> crashes looks gone but only for 4 days. (you can see the first dump in my 
> first mail)
>
> Thanks for all the help,
>
> Janos Haar
>
>
>>
>> If I investigate this issue, I'll check the owner of page 0x1535b4000 by
>> crash dump.
>>
>> Thanks,
>> -Kame
>>
>>
>>
>>> 2010/3/25 Janos Haar <janos.haar@netcenter.hu>:
>>> > Dear developers,
>>> >
>>> > This is one of my productive servers, wich suddenly starts to freeze 
>>> > (crash)
>>> > some weeks before.
>>> > I have done all what i can, (i think) please somebody give to me some
>>> > suggestion:
>>> >
>>> > Mar 24 19:22:28 alfa kernel: BUG: Bad page map in process httpd 
>>> > pte:2bf1e025
>>> > pmd:1535b5067
>>> > Mar 24 19:22:28 alfa kernel: page:ffffea0000f1b250 
>>> > flags:4000000000000404
>>> > count:1 mapcount:-1 mapping:(null) index:0
>>> > Mar 24 19:22:28 alfa kernel: addr:00000037b4008000 vm_flags:08000875
>>> > anon_vma:(null) mapping:ffff88022b5d25a8 index:8
>>> > Mar 24 19:22:28 alfa kernel: vma->vm_ops->fault: 
>>> > filemap_fault+0x0/0x34d
>>> > Mar 24 19:22:28 alfa kernel: vma->vm_file->f_op->mmap:
>>> > xfs_file_mmap+0x0/0x33
>>> > Mar 24 19:22:28 alfa kernel: Pid: 7512, comm: httpd Not tainted 
>>> > 2.6.32.10 #2
>>> > Mar 24 19:22:28 alfa kernel: Call Trace:
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c2ea3>] 
>>> > print_bad_pte+0x210/0x229
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c3c98>] 
>>> > unmap_vmas+0x44b/0x787
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c81d5>] exit_mmap+0xb0/0x133
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81041f83>] mmput+0x48/0xb9
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810463b0>] exit_mm+0x105/0x110
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81371287>] ?
>>> > tty_audit_exit+0x28/0x85
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810477a0>] do_exit+0x1e9/0x6d2
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81053c37>] ?
>>> > __dequeue_signal+0xf1/0x127
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81047d00>] 
>>> > do_group_exit+0x77/0xa1
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810560f7>]
>>> > get_signal_to_deliver+0x32c/0x37f
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8100a484>]
>>> > do_notify_resume+0x90/0x740
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8102724b>] ?
>>> > __bad_area_nosemaphore+0x178/0x1a2
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810272b9>] ? 
>>> > __bad_area+0x44/0x4d
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8100bba2>] 
>>> > retint_signal+0x46/0x84
>>> > Mar 24 19:22:28 alfa kernel: Disabling lock debugging due to kernel 
>>> > taint
>>> > Mar 24 19:22:28 alfa kernel: swap_free: Bad swap file entry 6c800000
>>> > Mar 24 19:22:28 alfa kernel: BUG: Bad page map in process httpd
>>> > pte:d900000000 pmd:1535b5067
>>> > Mar 24 19:22:28 alfa kernel: addr:00000037b400a000 vm_flags:08000875
>>> > anon_vma:(null) mapping:ffff88022b5d25a8 index:a
>>> > Mar 24 19:22:28 alfa kernel: vma->vm_ops->fault: 
>>> > filemap_fault+0x0/0x34d
>>> > Mar 24 19:22:28 alfa kernel: vma->vm_file->f_op->mmap:
>>> > xfs_file_mmap+0x0/0x33
>>> > Mar 24 19:22:28 alfa kernel: Pid: 7512, comm: httpd Tainted: G B
>>> > 2.6.32.10 #2
>>> > Mar 24 19:22:28 alfa kernel: Call Trace:
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81044551>] ? 
>>> > add_taint+0x32/0x3e
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c2ea3>] 
>>> > print_bad_pte+0x210/0x229
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c3d47>] 
>>> > unmap_vmas+0x4fa/0x787
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c81d5>] exit_mmap+0xb0/0x133
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81041f83>] mmput+0x48/0xb9
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810463b0>] exit_mm+0x105/0x110
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81371287>] ?
>>> > tty_audit_exit+0x28/0x85
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810477a0>] do_exit+0x1e9/0x6d2
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81053c37>] ?
>>> > __dequeue_signal+0xf1/0x127
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81047d00>] 
>>> > do_group_exit+0x77/0xa1
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810560f7>]
>>> > get_signal_to_deliver+0x32c/0x37f
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8100a484>]
>>> > do_notify_resume+0x90/0x740
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8102724b>] ?
>>> > __bad_area_nosemaphore+0x178/0x1a2
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810272b9>] ? 
>>> > __bad_area+0x44/0x4d
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff8100bba2>] 
>>> > retint_signal+0x46/0x84
>>> > Mar 24 19:22:28 alfa kernel: BUG: Bad page map in process httpd 
>>> > pte:2bfe8025
>>> > pmd:1535b5067
>>> > Mar 24 19:22:28 alfa kernel: page:ffffea0000f1f7c0 
>>> > flags:4000000000000404
>>> > count:1 mapcount:-1 mapping:(null) index:0
>>> > Mar 24 19:22:28 alfa kernel: addr:00000037b400c000 vm_flags:08000875
>>> > anon_vma:(null) mapping:ffff88022b5d25a8 index:c
>>> > Mar 24 19:22:28 alfa kernel: vma->vm_ops->fault: 
>>> > filemap_fault+0x0/0x34d
>>> > Mar 24 19:22:28 alfa kernel: vma->vm_file->f_op->mmap:
>>> > xfs_file_mmap+0x0/0x33
>>> > Mar 24 19:22:28 alfa kernel: Pid: 7512, comm: httpd Tainted: G B
>>> > 2.6.32.10 #2
>>> > Mar 24 19:22:28 alfa kernel: Call Trace:
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81044551>] ? 
>>> > add_taint+0x32/0x3e
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c2ea3>] 
>>> > print_bad_pte+0x210/0x229
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c3c98>] 
>>> > unmap_vmas+0x44b/0x787
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810c81d5>] exit_mmap+0xb0/0x133
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff81041f83>] mmput+0x48/0xb9
>>> > Mar 24 19:22:28 alfa kernel: [<ffffffff810463b0>] exit_mm+0x105/0x110
>>> > .....
>>> >
>>> > The entire log is here:
>>> > http://download.netcenter.hu/bughunt/20100324/messages
>>> >
>>> > The actual kernel is 2.6.32.10, but the crash-series started @ 
>>> > 2.6.28.10.
>>> >
>>> > I have forwarded the tasks to another server, removed this from the 
>>> > room,
>>> > and the hw survived memtest86 in >7 days continously + i have tested 
>>> > the
>>> > HDDs one by one with badblocks -vvw, all is good.
>>> > For me looks like this is not a hw problem.
>>> >
>>> > Somebody have any idea?
>>> >
>>> > Thanks a lot,
>>> > Janos Haar
>>> > --
>>> > To unsubscribe from this list: send the line "unsubscribe 
>>> > linux-kernel" in
>>> > the body of a message to majordomo@vger.kernel.org
>>> > More majordomo info at http://vger.kernel.org/majordomo-info.html
>>> > Please read the FAQ at http://www.tux.org/lkml/
>>> >
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" 
>>> in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" 
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>
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
