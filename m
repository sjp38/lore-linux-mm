Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 39B5B6B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 23:35:21 -0400 (EDT)
Received: by wwf26 with SMTP id 26so52154wwf.26
        for <linux-mm@kvack.org>; Wed, 28 Jul 2010 20:35:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=g0YH64vjgQjXZDvyBkOWGp-sT6Rn5MLYuywMZ@mail.gmail.com>
References: <AANLkTi=g0YH64vjgQjXZDvyBkOWGp-sT6Rn5MLYuywMZ@mail.gmail.com>
Date: Thu, 29 Jul 2010 00:35:17 -0300
Message-ID: <AANLkTikRxGgdOdCMqT2dgrHb76sypwDgrDXFDWvPx=Qe@mail.gmail.com>
Subject: [BUG] 2.6.34 - unable to handle kernel paging request
From: Felipe W Damasio <felipewd@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I sent this to lkml yesterday, but I think the bug is related to mm,
so I'm hoping you guys can help me.

I'm running a 2.6.34 on a I7 processor, using as a webcache machine.

The machine stopped responding after a while, and after a reboot I
hada few of these:

Pid: 11333, comm: free Not tainted 2.6.34 #6 MB-X58I-CH19/Thurley
RIP: 0010:[<ffffffff810a7fd5>] =A0[<ffffffff810a7fd5>] kmem_cache_alloc+0x4=
5/0x88
RSP: 0018:ffff88018804b618 =A0EFLAGS: 00010086
RAX: 0000000000000000 RBX: 0000000000008010 RCX: 0000000000000000
RDX: ffff8800018d8718 RSI: ffff8a101d6b40f0 RDI: ffff88021ffb5500
RBP: 0000000000000246 R08: 0000000000000000 R09: 0000000000000400
R10: 0000000000000000 R11: ffff8801b9441680 R12: ffff88021ffb5500
R13: ffffffff811d3c60 R14: 0000000000000010 R15: 0000000000000000
FS: =A00000000000000000(0000) GS:ffff8800018c0000(0000) knlGS:0000000000000=
000
CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff8a101d6b40f0 CR3: 00000001d5ee4000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process free (pid: 11333, threadinfo ffff88018804a000, task ffff88008ce6c1a=
0)
Stack:
0000000000000001 ffff88021ee21340 0000000000000000 0000000000000000
<0> ffff88021ee21000 ffffffff811d3c60 0000001000008010 0000000000000003
<0> ffff8800dc0870c0 01ffffff811dad49 ffff88021ee21030 0000000000000000
Call Trace:
[<ffffffff811d3c60>] ? cfq_get_queue+0x10f/0x223
[<ffffffff811d405d>] ? cfq_set_request+0x264/0x371
[<ffffffff811ca2da>] ? get_request+0x1e8/0x282
[<ffffffff811ca394>] ? get_request_wait+0x20/0x140
[<ffffffff810ce3fb>] ? bio_alloc_bioset+0x45/0xb7
[<ffffffff811ca744>] ? __make_request+0x290/0x3b6
[<ffffffff811c911a>] ? generic_make_request+0x169/0x1ca
[<ffffffff8118cbd2>] ? xfs_get_blocks+0x0/0xe
[<ffffffff811c9231>] ? submit_bio+0xb6/0xbd
[<ffffffff810d0f77>] ? mpage_bio_submit+0x22/0x26
[<ffffffff810d1ae8>] ? mpage_readpages+0xfb/0x10f
[<ffffffff8118cbd2>] ? xfs_get_blocks+0x0/0xe
[<ffffffff81085255>] ? get_page_from_freelist+0x3d2/0x48b
[<ffffffff81086f31>] ? __do_page_cache_readahead+0x129/0x1c1
[<ffffffff81086fe5>] ? ra_submit+0x1c/0x20
[<ffffffff81080fb2>] ? filemap_fault+0x17d/0x2f5
[<ffffffff81091a6f>] ? __do_fault+0x53/0x3ab
[<ffffffff81093be4>] ? handle_mm_fault+0x3ea/0x7c5
[<ffffffff8108e5c2>] ? vma_prio_tree_insert+0x20/0xb1
[<ffffffff8101ebea>] ? do_page_fault+0x233/0x24b
[<ffffffff814359df>] ? page_fault+0x1f/0x30
[<ffffffff811de976>] ? __clear_user+0x2e/0x50
[<ffffffff811de95a>] ? __clear_user+0x12/0x50
[<ffffffff810e29ac>] ? load_elf_binary+0x935/0x18c9
[<ffffffff810b0a94>] ? search_binary_handler+0xb7/0x246
[<ffffffff810b1f68>] ? do_execve+0x1a4/0x283
[<ffffffff81009d88>] ? sys_execve+0x35/0x4c
[<ffffffff81002d4a>] ? stub_execve+0x6a/0xc0
Code: f6 c3 10 74 05 e8 e0 c3 38 00 9c 5d fa 65 48 8b 14 25 40 d1 00
00 49 8b 04 24 48 8d 14 10 48 8b 32 48 85 f6 74 0e 49 63 44 24 18 <48>
8b 04 06 48 89 02 eb 16 49 89 d0 89 de 4c 89 e9 83 ca ff 4c
RIP =A0[<ffffffff810a7fd5>] kmem_cache_alloc+0x45/0x88
RSP <ffff88018804b618>
CR2: ffff8a101d6b40f0
---[ end trace efb68e2c3ad8be03 ]---


BUG: unable to handle kernel paging request at ffff8a101d6b40f0
IP: [<ffffffff810a7fd5>] kmem_cache_alloc+0x45/0x88
PGD 0
Oops: 0000 [#6] SMP
last sysfs file: /sys/devices/platform/w83627ehf.2576/in8_max
CPU 3
Modules linked in:

Pid: 12048, comm: bash Tainted: G =A0 =A0 =A0D =A0 =A02.6.34 #6 MB-X58I-CH1=
9/Thurley
RIP: 0010:[<ffffffff810a7fd5>] =A0[<ffffffff810a7fd5>] kmem_cache_alloc+0x4=
5/0x88
RSP: 0018:ffff88003b7857c8 =A0EFLAGS: 00010086
RAX: 0000000000000000 RBX: 0000000000008010 RCX: 0000000000000000
RDX: ffff8800018d8718 RSI: ffff8a101d6b40f0 RDI: ffff88021ffb5500
RBP: 0000000000000246 R08: 0000000000000001 R09: dead000000200200
R10: dead000000100100 R11: ffff880067d04b40 R12: ffff88021ffb5500
R13: ffffffff811d3c60 R14: 0000000000000010 R15: 0000000000000000
FS: =A000007fe5e96cc6f0(0000) GS:ffff8800018c0000(0000) knlGS:0000000000000=
000
CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff8a101d6b40f0 CR3: 00000000d9ff1000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process bash (pid: 12048, threadinfo ffff88003b784000, task ffff88003750276=
0)
Stack:
0000000000000001 ffff88021ee21340 0000000000000000 0000000000000000
<0> ffff88021ee21000 ffffffff811d3c60 0000001000008010 0000000000000003
<0> ffff8800802bc5c0 01ffffff811dad49 ffff88021ee21030 0000000000000000
Call Trace:
[<ffffffff811d3c60>] ? cfq_get_queue+0x10f/0x223
[<ffffffff811d405d>] ? cfq_set_request+0x264/0x371
[<ffffffff811ca2da>] ? get_request+0x1e8/0x282
[<ffffffff811ca394>] ? get_request_wait+0x20/0x140
[<ffffffff810ce3fb>] ? bio_alloc_bioset+0x45/0xb7
[<ffffffff811ca744>] ? __make_request+0x290/0x3b6
[<ffffffff811c911a>] ? generic_make_request+0x169/0x1ca
[<ffffffff8118cbd2>] ? xfs_get_blocks+0x0/0xe
[<ffffffff811c9231>] ? submit_bio+0xb6/0xbd
[<ffffffff810d0f77>] ? mpage_bio_submit+0x22/0x26
[<ffffffff810d1ae8>] ? mpage_readpages+0xfb/0x10f
[<ffffffff8118cbd2>] ? xfs_get_blocks+0x0/0xe
[<ffffffff81086f31>] ? __do_page_cache_readahead+0x129/0x1c1
[<ffffffff81086fe5>] ? ra_submit+0x1c/0x20
[<ffffffff81081a6d>] ? generic_file_aio_read+0x1f5/0x525
[<ffffffff81190944>] ? xfs_file_aio_read+0x17e/0x1d0
[<ffffffff810ac500>] ? do_sync_read+0xb0/0xf2
[<ffffffff811a71ae>] ? avc_has_perm+0x4c/0x5e
[<ffffffff811ac762>] ? selinux_bprm_set_creds+0x11f/0x207
[<ffffffff811aab15>] ? selinux_file_permission+0x4e/0xa5
[<ffffffff810acf1f>] ? vfs_read+0xa6/0xff
[<ffffffff810b1765>] ? kernel_read+0x3d/0x4c
[<ffffffff810b1ede>] ? do_execve+0x11a/0x283
[<ffffffff81009d88>] ? sys_execve+0x35/0x4c
[<ffffffff81002d4a>] ? stub_execve+0x6a/0xc0
Code: f6 c3 10 74 05 e8 e0 c3 38 00 9c 5d fa 65 48 8b 14 25 40 d1 00
00 49 8b 04 24 48 8d 14 10 48 8b 32 48 85 f6 74 0e 49 63 44 24 18 <48>
8b 04 06 48 89 02 eb 16 49 89 d0 89 de 4c 89 e9 83 ca ff 4c
RIP =A0[<ffffffff810a7fd5>] kmem_cache_alloc+0x45/0x88
RSP <ffff88003b7857c8>
CR2: ffff8a101d6b40f0
---[ end trace efb68e2c3ad8be08 ]---


=A0BUG: unable to handle kernel paging request at ffff8a101d6b40f0
=A0IP: [<ffffffff810a7fd5>] kmem_cache_alloc+0x45/0x88
=A0PGD 0
=A0Oops: 0000 [#7] SMP
=A0last sysfs file: /sys/devices/platform/w83627ehf.2576/in8_max
=A0CPU 3
=A0Modules linked in:

=A0Pid: 12046, comm: bash Tainted: G =A0 =A0 =A0D =A0 =A02.6.34 #6 MB-X58I-=
CH19/Thurley
=A0RIP: 0010:[<ffffffff810a7fd5>] =A0[<ffffffff810a7fd5>] kmem_cache_alloc+=
0x45/0x88
=A0RSP: 0000:ffff8800cabaf858 =A0EFLAGS: 00010086
=A0RAX: 0000000000000000 RBX: 0000000000008010 RCX: 0000000000000000
=A0RDX: ffff8800018d8718 RSI: ffff8a101d6b40f0 RDI: ffff88021ffb5500
=A0RBP: 0000000000000246 R08: 0e190f613f5f2918 R09: ffff8800cabafcd8
=A0R10: 0000000000000000 R11: ffff880067d04c80 R12: ffff88021ffb5500
=A0R13: ffffffff811d3c60 R14: 0000000000000010 R15: 0000000000000000
=A0FS: =A000007fe5e96cc6f0(0000) GS:ffff8800018c0000(0000) knlGS:0000000000=
000000
=A0CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
=A0CR2: ffff8a101d6b40f0 CR3: 00000000b871a000 CR4: 00000000000006e0
=A0DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
=A0DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
=A0Process bash (pid: 12046, threadinfo ffff8800cabae000, task ffff88005f07=
8690)
=A0Stack:
=A00000000000000001 ffff88021ee21340 0000000000000000 0000000000000000
=A0<0> ffff88021ee21000 ffffffff811d3c60 0000001000008010 0000000000000003
=A0<0> ffff8800802bce00 01ffffff811dad49 ffff88021ee21030 0000000000000000
=A0Call Trace:
=A0[<ffffffff811d3c60>] ? cfq_get_queue+0x10f/0x223
=A0[<ffffffff811d405d>] ? cfq_set_request+0x264/0x371
=A0[<ffffffff811ca2da>] ? get_request+0x1e8/0x282
=A0[<ffffffff811ca394>] ? get_request_wait+0x20/0x140
=A0[<ffffffff8108203a>] ? mempool_alloc+0x55/0x106
=A0[<ffffffff8108203a>] ? mempool_alloc+0x55/0x106
=A0[<ffffffff811ca744>] ? __make_request+0x290/0x3b6
=A0[<ffffffff811c911a>] ? generic_make_request+0x169/0x1ca
=A0[<ffffffff810cd3f5>] ? bvec_alloc_bs+0xc1/0xdc
=A0[<ffffffff811c9231>] ? submit_bio+0xb6/0xbd
=A0[<ffffffff810d0eff>] ? mpage_alloc+0x22/0x78
=A0[<ffffffff810d0f77>] ? mpage_bio_submit+0x22/0x26
=A0[<ffffffff810d184d>] ? do_mpage_readpage+0x2e9/0x417
=A0[<ffffffff8118cbd2>] ? xfs_get_blocks+0x0/0xe
=A0[<ffffffff811dad49>] ? radix_tree_insert+0x16a/0x1a8
=A0[<ffffffff8118cbd2>] ? xfs_get_blocks+0x0/0xe
=A0[<ffffffff81080b99>] ? add_to_page_cache_locked+0x76/0xb3
=A0[<ffffffff8118cbd2>] ? xfs_get_blocks+0x0/0xe
=A0[<ffffffff810d1ab9>] ? mpage_readpages+0xcc/0x10f
=A0[<ffffffff8118cbd2>] ? xfs_get_blocks+0x0/0xe
=A0[<ffffffff810289a7>] ? enqueue_task_fair+0x3e/0xa1
=A0[<ffffffff81025a0a>] ? enqueue_task+0x5f/0x68
=A0[<ffffffff81035ab7>] ? current_fs_time+0x1e/0x24
=A0[<ffffffff8104429d>] ? autoremove_wake_function+0x9/0x2e
=A0[<ffffffff81086f31>] ? __do_page_cache_readahead+0x129/0x1c1
=A0[<ffffffff81086fe5>] ? ra_submit+0x1c/0x20
=A0[<ffffffff81080fb2>] ? filemap_fault+0x17d/0x2f5
=A0[<ffffffff81091a6f>] ? __do_fault+0x53/0x3ab
=A0[<ffffffff81093be4>] ? handle_mm_fault+0x3ea/0x7c5
=A0[<ffffffff8101ebea>] ? do_page_fault+0x233/0x24b
=A0[<ffffffff814359df>] ? page_fault+0x1f/0x30
=A0Code: f6 c3 10 74 05 e8 e0 c3 38 00 9c 5d fa 65 48 8b 14 25 40 d1 00
00 49 8b 04 24 48 8d 14 10 48 8b 32 48 85 f6 74 0e 49 63 44 24 18 <48>
8b 04 06 48 89 02 eb 16 49 89 d0 89 de 4c 89 e9 83 ca ff 4c
=A0RIP =A0[<ffffffff810a7fd5>] kmem_cache_alloc+0x45/0x88
=A0RSP <ffff8800cabaf858>
=A0CR2: ffff8a101d6b40f0
=A0---[ end trace efb68e2c3ad8be09 ]---


And a few others like these.

If you want, I can send you all other bug reports on my logs...

Cheers,

Felipe Damasio

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
