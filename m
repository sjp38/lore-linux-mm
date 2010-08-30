Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9DD3F6B01F1
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 10:16:20 -0400 (EDT)
Received: by eyh5 with SMTP id 5so3773626eyh.14
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 07:16:18 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 30 Aug 2010 11:16:16 -0300
Message-ID: <AANLkTimwCWmXHuu3ahnDy9uWqqLAoxtzSfxL86TE2swv@mail.gmail.com>
Subject: [BUG] Oops: unable to handle kernel paging request at ffff8a101da005a0
From: Felipe W Damasio <felipewd@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

My server frooze this morning, and on the logs this error appeared:

Aug 30 09:08:36 cache-machine kernel: BUG: unable to handle kernel
paging request at ffff8a101da005a0
Aug 30 09:08:36 cache-machine kernel: IP: [<ffffffff810b0460>]
kmem_cache_alloc+0x5a/0x86
Aug 30 09:08:36 cache-machine kernel: PGD 0
Aug 30 09:08:36 cache-machine kernel: Oops: 0000 [#19] SMP
Aug 30 09:08:36 cache-machine kernel: last sysfs file:
/sys/devices/platform/w83627ehf.2576/in8_max
Aug 30 09:08:36 cache-machine kernel: CPU 7
Aug 30 09:08:36 cache-machine kernel: Modules linked in:
Aug 30 09:08:36 cache-machine kernel:
Aug 30 09:08:36 cache-machine kernel: Pid: 24819, comm: mysqld
Tainted: G      D    2.6.34.1 #1 MB-X58I-CH19/Thurley
Aug 30 09:08:36 cache-machine kernel: RIP: 0010:[<ffffffff810b0460>]
[<ffffffff810b0460>] kmem_cache_alloc+0x5a/0x86
Aug 30 09:08:36 cache-machine kernel: RSP: 0000:ffff8800c7637728
EFLAGS: 00010086
Aug 30 09:08:36 cache-machine kernel: RAX: 0000000000000000 RBX:
0000000000008010 RCX: 0000000000000010
Aug 30 09:08:36 cache-machine kernel: RDX: ffff8a101da005a0 RSI:
0000000000008010 RDI: ffff88021ecd9400
Aug 30 09:08:36 cache-machine kernel: RBP: ffff8800c7637748 R08:
ffff880001bd8700 R09: 0000000000000002
Aug 30 09:08:36 cache-machine kernel: R10: 00000000000022c1 R11:
0000000000014466 R12: ffff88021ecd9400
Aug 30 09:08:36 cache-machine kernel: R13: 0000000000000246 R14:
ffffffff811d24d4 R15: 0000000000000000
Aug 30 09:08:36 cache-machine kernel: FS:  00007f98072de950(0000)
GS:ffff880001bc0000(0000) knlGS:0000000000000000
Aug 30 09:08:36 cache-machine kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
Aug 30 09:08:36 cache-machine kernel: CR2: ffff8a101da005a0 CR3:
000000021e79e000 CR4: 00000000000006e0
Aug 30 09:08:36 cache-machine kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Aug 30 09:08:36 cache-machine kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Aug 30 09:08:36 cache-machine kernel: Process mysqld (pid: 24819,
threadinfo ffff8800c7636000, task ffff88021e477740)
Aug 30 09:08:36 cache-machine kernel: Stack:
Aug 30 09:08:36 cache-machine kernel: ffff88021f7b1000
ffff8800d2ae1cc0 ffff88021f7b1340 0000000000000000
Aug 30 09:08:36 cache-machine kernel: <0> ffff8800c76377b8
ffffffff811d24d4 ffff8800c7637778 0000000000000010
Aug 30 09:08:36 cache-machine kernel: <0> 0000001000008010
0000000000000003 ffff88021f7b1030 01ff880000000000
Aug 30 09:08:36 cache-machine kernel: Call Trace:
Aug 30 09:08:36 cache-machine kernel: [<ffffffff811d24d4>]
cfq_get_queue+0x10c/0x227
Aug 30 09:08:36 cache-machine kernel: [<ffffffff811d28d9>]
cfq_set_request+0x26b/0x380
Aug 30 09:08:36 cache-machine kernel: [<ffffffff811c4d8e>]
elv_set_request+0x16/0x27
Aug 30 09:08:36 cache-machine kernel: [<ffffffff811c8307>]
get_request+0x24a/0x30b
Aug 30 09:08:36 cache-machine kernel: [<ffffffff811c83f5>]
get_request_wait+0x2d/0x13a
Aug 30 09:08:36 cache-machine kernel: [<ffffffff811c87bb>]
__make_request+0x2b9/0x3db
Aug 30 09:08:36 cache-machine kernel: [<ffffffff811c6e25>]
generic_make_request+0x1bd/0x224
Aug 30 09:08:36 cache-machine kernel: [<ffffffff810d838e>] ?
bio_alloc_bioset+0x73/0xbd
Aug 30 09:08:36 cache-machine kernel: [<ffffffff811c6f4a>] submit_bio+0xbe/0xc7
Aug 30 09:08:36 cache-machine kernel: [<ffffffff810db0b3>]
mpage_bio_submit+0x22/0x26
Aug 30 09:08:36 cache-machine kernel: [<ffffffff810dbb33>]
do_mpage_readpage+0x3b1/0x4fb
Aug 30 09:08:36 cache-machine kernel: [<ffffffff8108edaa>] ?
____pagevec_lru_add+0x12f/0x145
Aug 30 09:08:36 cache-machine kernel: [<ffffffff810dbdb1>]
mpage_readpages+0xd7/0x11e
Aug 30 09:08:36 cache-machine kernel: [<ffffffff8119c6e6>] ?
xfs_get_blocks+0x0/0x14
Aug 30 09:08:36 cache-machine kernel: [<ffffffff8119c6e6>] ?
xfs_get_blocks+0x0/0x14
Aug 30 09:08:36 cache-machine kernel: [<ffffffff8119d859>]
xfs_vm_readpages+0x18/0x1a
Aug 30 09:08:36 cache-machine kernel: [<ffffffff8108e296>]
__do_page_cache_readahead+0x10c/0x1a2
Aug 30 09:08:36 cache-machine kernel: [<ffffffff8108e348>] ra_submit+0x1c/0x20
Aug 30 09:08:36 cache-machine kernel: [<ffffffff81087e46>]
filemap_fault+0x1a4/0x327
Aug 30 09:08:36 cache-machine kernel: [<ffffffff81098fdf>] __do_fault+0x50/0x40b
Aug 30 09:08:36 cache-machine kernel: [<ffffffff8109a4fe>]
handle_mm_fault+0x3fa/0x7d0
Aug 30 09:08:36 cache-machine kernel: [<ffffffff810b49da>] ?
do_sync_read+0xc6/0x103
Aug 30 09:08:36 cache-machine kernel: [<ffffffff8102004c>]
do_page_fault+0x2d9/0x2fb
Aug 30 09:08:36 cache-machine kernel: [<ffffffff810b558b>] ?
vfs_read+0x137/0x16f
Aug 30 09:08:36 cache-machine kernel: [<ffffffff8143b35f>] page_fault+0x1f/0x30
Aug 30 09:08:36 cache-machine kernel: Code: 00 00 49 8b 04 24 49 01 c0
49 8b 10 48 85 d2 75 15 83 ca ff 4c 89 f1 89 de 4c 89 e7 e8 77 f9 ff
ff 48 89 c2 eb 0c 49 63 44 24 18 <48> 8b 04 02 49 89 00 41 55 9d 48 85
d2 74 11 66 85 db 79 0c 49
Aug 30 09:08:36 cache-machine kernel: RIP  [<ffffffff810b0460>]
kmem_cache_alloc+0x5a/0x86
Aug 30 09:08:36 cache-machine kernel: RSP <ffff8800c7637728>
Aug 30 09:08:36 cache-machine kernel: CR2: ffff8a101da005a0
Aug 30 09:08:36 cache-machine kernel: ---[ end trace 5bbe659d1963f172 ]---


This has happened before (I posted it here a few weeks back), but I
don't know how to fix it or even duplicate the bug...

Looking back a few days, I noticed the first one appeared 2 days ago:

Aug 28 23:49:02 cache-machine kernel: BUG: unable to handle kernel
paging request at ffff8a101da005a0
Aug 28 23:49:02 cache-machine kernel: IP: [<ffffffff810b0460>]
kmem_cache_alloc+0x5a/0x86
Aug 28 23:49:02 cache-machine kernel: PGD 0
Aug 28 23:49:02 cache-machine kernel: Oops: 0000 [#1] SMP
Aug 28 23:49:02 cache-machine kernel: last sysfs file:
/sys/devices/platform/w83627ehf.2576/in8_max
Aug 28 23:49:02 cache-machine kernel: CPU 7
Aug 28 23:49:02 cache-machine kernel: Modules linked in:
Aug 28 23:49:02 cache-machine kernel:
Aug 28 23:49:02 cache-machine kernel: Pid: 20884, comm: sh Not tainted
2.6.34.1 #1 MB-X58I-CH19/Thurley
Aug 28 23:49:02 cache-machine kernel: RIP: 0010:[<ffffffff810b0460>]
[<ffffffff810b0460>] kmem_cache_alloc+0x5a/0x86
Aug 28 23:49:02 cache-machine kernel: RSP: 0000:ffff88016a209728
EFLAGS: 00010086
Aug 28 23:49:02 cache-machine kernel: RAX: 0000000000000000 RBX:
0000000000008010 RCX: 0000000000000010
Aug 28 23:49:02 cache-machine kernel: RDX: ffff8a101da005a0 RSI:
0000000000008010 RDI: ffff88021ecd9400
Aug 28 23:49:02 cache-machine kernel: RBP: ffff88016a209748 R08:
ffff880001bd8700 R09: ffff88021f95f190
Aug 28 23:49:02 cache-machine kernel: R10: 0000000000000001 R11:
0000000000000001 R12: ffff88021ecd9400
Aug 28 23:49:02 cache-machine kernel: R13: 0000000000000246 R14:
ffffffff811d24d4 R15: 0000000000000000
Aug 28 23:49:02 cache-machine kernel: FS:  00007f806013b6f0(0000)
GS:ffff880001bc0000(0000) knlGS:0000000000000000
Aug 28 23:49:02 cache-machine kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
000000008005003b
Aug 28 23:49:02 cache-machine kernel: CR2: ffff8a101da005a0 CR3:
00000001f975c000 CR4: 00000000000006e0
Aug 28 23:49:02 cache-machine kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Aug 28 23:49:02 cache-machine kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Aug 28 23:49:02 cache-machine kernel: Process sh (pid: 20884,
threadinfo ffff88016a208000, task ffff88021da15620)
Aug 28 23:49:02 cache-machine kernel: Stack:
Aug 28 23:49:02 cache-machine kernel: ffff88021f7b1000
ffff8801fce6fe80 ffff88021f7b1340 0000000000000000
Aug 28 23:49:02 cache-machine kernel: <0> ffff88016a2097b8
ffffffff811d24d4 ffff88016a209778 ffffffff00000010
Aug 28 23:49:02 cache-machine kernel: <0> 0000001000008010
0000000000000003 ffff88021f7b1030 01ffffff00000000
Aug 28 23:49:02 cache-machine kernel: Call Trace:
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811d24d4>]
cfq_get_queue+0x10c/0x227
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811d28d9>]
cfq_set_request+0x26b/0x380
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811c4d8e>]
elv_set_request+0x16/0x27
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811c8307>]
get_request+0x24a/0x30b
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811c83f5>]
get_request_wait+0x2d/0x13a
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811d3f58>] ? cfq_merge+0x30/0x9f
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811c548c>] ?
elv_merge+0x166/0x19e
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811c87bb>]
__make_request+0x2b9/0x3db
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811c6e25>]
generic_make_request+0x1bd/0x224
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8119c627>] ?
__xfs_get_blocks+0xb1/0x159
Aug 28 23:49:02 cache-machine kernel: [<ffffffff811c6f4a>] submit_bio+0xbe/0xc7
Aug 28 23:49:02 cache-machine kernel: [<ffffffff810db0b3>]
mpage_bio_submit+0x22/0x26
Aug 28 23:49:02 cache-machine kernel: [<ffffffff810dbb33>]
do_mpage_readpage+0x3b1/0x4fb
Aug 28 23:49:02 cache-machine kernel: [<ffffffff81096a23>] ?
__inc_zone_page_state+0x1e/0x20
Aug 28 23:49:02 cache-machine kernel: [<ffffffff810879e0>] ?
add_to_page_cache_locked+0x75/0xb6
Aug 28 23:49:02 cache-machine kernel: [<ffffffff810dbdb1>]
mpage_readpages+0xd7/0x11e
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8119c6e6>] ?
xfs_get_blocks+0x0/0x14
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8119c6e6>] ?
xfs_get_blocks+0x0/0x14
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8108c493>] ?
get_page_from_freelist+0x3c1/0x483
Aug 28 23:49:02 cache-machine kernel: [<ffffffff81087807>] ?
unlock_page+0x22/0x26
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8108c493>] ?
get_page_from_freelist+0x3c1/0x483
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8119d859>]
xfs_vm_readpages+0x18/0x1a
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8108e296>]
__do_page_cache_readahead+0x10c/0x1a2
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8108e348>] ra_submit+0x1c/0x20
Aug 28 23:49:02 cache-machine kernel: [<ffffffff81087e46>]
filemap_fault+0x1a4/0x327
Aug 28 23:49:02 cache-machine kernel: [<ffffffff81098fdf>] __do_fault+0x50/0x40b
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8109a4fe>]
handle_mm_fault+0x3fa/0x7d0
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8102004c>]
do_page_fault+0x2d9/0x2fb
Aug 28 23:49:02 cache-machine kernel: [<ffffffff810a027d>] ? do_brk+0x2d9/0x338
Aug 28 23:49:02 cache-machine kernel: [<ffffffff810c86a4>] ? alloc_fd+0x76/0x11e
Aug 28 23:49:02 cache-machine kernel: [<ffffffff8143b35f>] page_fault+0x1f/0x30
Aug 28 23:49:02 cache-machine kernel: Code: 00 00 49 8b 04 24 49 01 c0
49 8b 10 48 85 d2 75 15 83 ca ff 4c 89 f1 89 de 4c 89 e7 e8 77 f9 ff
ff 48 89 c2 eb 0c 49 63 44 24 18 <48> 8b 04 02 49 89 00 41 55 9d 48 85
d2 74 11 66 85 db 79 0c 49
Aug 28 23:49:02 cache-machine kernel: RIP  [<ffffffff810b0460>]
kmem_cache_alloc+0x5a/0x86
Aug 28 23:49:02 cache-machine kernel: RSP <ffff88016a209728>
Aug 28 23:49:02 cache-machine kernel: CR2: ffff8a101da005a0
Aug 28 23:49:02 cache-machine kernel: ---[ end trace 5bbe659d1963f160 ]---

Is there any info I can provide you to help and fix it?

Cheers,

Felipe Damasio

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
