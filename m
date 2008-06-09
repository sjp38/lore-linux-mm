Received: by gv-out-0910.google.com with SMTP id l14so556505gvf.19
        for <linux-mm@kvack.org>; Mon, 09 Jun 2008 13:50:06 -0700 (PDT)
Date: Tue, 10 Jun 2008 00:45:59 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: 2.6.26-rc5-mm1: kernel BUG at mm/filemap.c:575!
Message-ID: <20080609204559.GA4863@martell.zuzino.mipt.ru>
References: <20080609053908.8021a635.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080609053908.8021a635.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This happened after LTP run finished.

------------[ cut here ]------------
kernel BUG at mm/filemap.c:575!
invalid opcode: 0000 [1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/kernel/uevent_seqnum
CPU 1 
Modules linked in: ext2 nf_conntrack_irc xt_state iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack ip_tables x_tables usblp uhci_hcd ehci_hcd usbcore sr_mod cdrom
Pid: 19327, comm: pdflush Not tainted 2.6.26-rc5-mm1 #4
RIP: 0010:[<ffffffff80266a37>]  [<ffffffff80266a37>] unlock_page+0x17/0x40
RSP: 0018:ffff81015c697540  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffe20000e38c08 RCX: 0000000000000034
RDX: 0000000000000000 RSI: ffffe20000e38c08 RDI: ffffe20000e38c08
RBP: ffff81015c697550 R08: 0000000000000002 R09: 000000000007794e
R10: ffffffff8028b6f1 R11: 0000000000000001 R12: ffffe20000e38c08
R13: 0000000000000000 R14: ffff81015c6977a0 R15: ffff81015c6978c0
FS:  0000000000000000(0000) GS:ffff81017f845320(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007fb64f84f020 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process pdflush (pid: 19327, threadinfo ffff81015c696000, task ffff81015c795690)
Stack:  ffff81015c697550 0000000000000000 ffff81015c697680 ffffffff802722ce
 ffffe20005367df8 ffff81015c697640 0000000000000000 0000000000000001
 0000000000000001 0000000000000001 ffffe20000b02d38 ffffe20001274970
Call Trace:
 [<ffffffff802722ce>] shrink_page_list+0x2ce/0x6d0
 [<ffffffff80254f37>] ? mark_held_locks+0x47/0x90
 [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff802550e9>] ? trace_hardirqs_on_caller+0xc9/0x150
 [<ffffffff802728f4>] shrink_list+0x224/0x590
 [<ffffffff80272eab>] shrink_zone+0x24b/0x330
 [<ffffffff80273407>] try_to_free_pages+0x267/0x3e0
 [<ffffffff80271510>] ? isolate_pages_global+0x0/0x270
 [<ffffffff8026cf86>] __alloc_pages_internal+0x1b6/0x470
 [<ffffffff8028d061>] __slab_alloc+0x181/0x660
 [<ffffffff80254f37>] ? mark_held_locks+0x47/0x90
 [<ffffffff802f65a8>] ? journal_add_journal_head+0x88/0x230
 [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8028d973>] kmem_cache_alloc+0xb3/0xd0
 [<ffffffff802f65a8>] ? journal_add_journal_head+0x88/0x230
 [<ffffffff802f65a8>] journal_add_journal_head+0x88/0x230
 [<ffffffff802f23a9>] journal_dirty_data+0x59/0x2d0
 [<ffffffff802e355f>] ext3_journal_dirty_data+0x1f/0x50
 [<ffffffff802e35a5>] journal_dirty_data_fn+0x15/0x20
 [<ffffffff802e279a>] walk_page_buffers+0x8a/0xb0
 [<ffffffff802e3590>] ? journal_dirty_data_fn+0x0/0x20
 [<ffffffff802e5ddf>] ext3_ordered_writepage+0xef/0x180
 [<ffffffff8026da45>] __writepage+0x15/0x50
 [<ffffffff8026e0eb>] write_cache_pages+0x26b/0x3c0
 [<ffffffff8026da30>] ? __writepage+0x0/0x50
 [<ffffffff8026e262>] generic_writepages+0x22/0x30
 [<ffffffff8026e2ab>] do_writepages+0x3b/0x40
 [<ffffffff802b3bd4>] __writeback_single_inode+0xa4/0x330
 [<ffffffff802b432f>] generic_sync_sb_inodes+0x1ff/0x2f0
 [<ffffffff802b4445>] sync_sb_inodes+0x25/0x30
 [<ffffffff802b46a6>] writeback_inodes+0x96/0xe0
 [<ffffffff8026ed2a>] background_writeout+0xaa/0xe0
 [<ffffffff8026f330>] ? pdflush+0x0/0x1e0
 [<ffffffff8026f43e>] pdflush+0x10e/0x1e0
 [<ffffffff8026ec80>] ? background_writeout+0x0/0xe0
 [<ffffffff8026f330>] ? pdflush+0x0/0x1e0
 [<ffffffff802476bd>] kthread+0x4d/0x80
 [<ffffffff8020c628>] child_rip+0xa/0x12
 [<ffffffff8020bd13>] ? restore_args+0x0/0x30
 [<ffffffff80247816>] ? kthreadd+0x126/0x1b0
 [<ffffffff80247670>] ? kthread+0x0/0x80
 [<ffffffff8020c61e>] ? child_rip+0x0/0x12


Code: fe 0f 1f 00 48 c7 c2 80 5d 57 80 eb c9 0f 1f 80 00 00 00 00 55 48 89 e5 53 48 89 fb 48 83 ec 08 f0 0f ba 37 00 19 c0 85 c0 75 04 <0f> 0b eb fe e8 90 f1 ff ff 48 89 de 48 89 c7 31 d2 e8 13 10 fe 
RIP  [<ffffffff80266a37>] unlock_page+0x17/0x40
 RSP <ffff81015c697540>
---[ end trace d983269ed03ec2d7 ]---
------------[ cut here ]------------
kernel BUG at mm/filemap.c:575!
invalid opcode: 0000 [2] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/kernel/uevent_seqnum
CPU 0 
Modules linked in: ext2 nf_conntrack_irc xt_state iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack ip_tables x_tables usblp uhci_hcd ehci_hcd usbcore sr_mod cdrom
Pid: 19356, comm: growfiles Tainted: G      D   2.6.26-rc5-mm1 #4
RIP: 0010:[<ffffffff80266a37>]  [<ffffffff80266a37>] unlock_page+0x17/0x40
RSP: 0018:ffff81017e9c3658  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffe20000b1ec58 RCX: 0000000000000034
RDX: 0000000000000000 RSI: ffffe20000b1ec58 RDI: ffffe20000b1ec58
RBP: ffff81017e9c3668 R08: 0000000000000002 R09: 0000000000000001
R10: ffffffff8028b6f1 R11: 0000000000000000 R12: ffffe20000b1ec58
R13: 0000000000000001 R14: ffff81017e9c38b8 R15: ffff81017e9c39d8
FS:  00007fc4c7e1f6f0(0000) GS:ffffffff805ddc80(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000001cd8028 CR3: 000000017af6d000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process growfiles (pid: 19356, threadinfo ffff81017e9c2000, task ffff81015c790000)
Stack:  ffff81017e9c3668 0000000000000000 ffff81017e9c3798 ffffffff802722ce
 ffffe200053ab820 ffff81017e9c3758 0000000000000000 0000000000000000
 0000000000000000 0000000000000001 ffff81017e9c36d8 0000000000000246
Call Trace:
 [<ffffffff802722ce>] shrink_page_list+0x2ce/0x6d0
 [<ffffffff80271602>] ? isolate_pages_global+0xf2/0x270
 [<ffffffff802728f4>] shrink_list+0x224/0x590
 [<ffffffff8026e445>] ? determine_dirtyable_memory+0x15/0x30
 [<ffffffff8026e482>] ? get_dirty_limits+0x22/0x2a0
 [<ffffffff80272eab>] shrink_zone+0x24b/0x330
 [<ffffffff80273407>] try_to_free_pages+0x267/0x3e0
 [<ffffffff80271510>] ? isolate_pages_global+0x0/0x270
 [<ffffffff8026cf86>] __alloc_pages_internal+0x1b6/0x470
 [<ffffffff80266e9a>] __grab_cache_page+0x6a/0xa0
 [<ffffffff802e5ba5>] ext3_write_begin+0x65/0x1b0
 [<ffffffff802677dd>] generic_file_buffered_write+0x14d/0x740
 [<ffffffff80467d40>] ? _spin_unlock+0x30/0x60
 [<ffffffff802ac0de>] ? mnt_drop_write+0x7e/0x160
 [<ffffffff80268260>] __generic_file_aio_write_nolock+0x2a0/0x460
 [<ffffffff80268486>] generic_file_aio_write+0x66/0xd0
 [<ffffffff802e1496>] ext3_file_write+0x26/0xc0
 [<ffffffff80291fb1>] do_sync_write+0xf1/0x130
 [<ffffffff80247ae0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802a26be>] ? locks_free_lock+0x3e/0x60
 [<ffffffff802a3c18>] ? fcntl_setlk+0x58/0x2c0
 [<ffffffff8029276a>] vfs_write+0xaa/0xe0
 [<ffffffff80292d10>] sys_write+0x50/0x90
 [<ffffffff8020b6bb>] system_call_after_swapgs+0x7b/0x80


Code: fe 0f 1f 00 48 c7 c2 80 5d 57 80 eb c9 0f 1f 80 00 00 00 00 55 48 89 e5 53 48 89 fb 48 83 ec 08 f0 0f ba 37 00 19 c0 85 c0 75 04 <0f> 0b eb fe e8 90 f1 ff ff 48 89 de 48 89 c7 31 d2 e8 13 10 fe 
RIP  [<ffffffff80266a37>] unlock_page+0x17/0x40
 RSP <ffff81017e9c3658>
------------[ cut here ]------------
kernel BUG at mm/filemap.c:575!
invalid opcode: 0000 [3] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/kernel/uevent_seqnum
CPU 0 
Modules linked in: ext2 nf_conntrack_irc xt_state iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack ip_tables x_tables usblp uhci_hcd ehci_hcd usbcore sr_mod cdrom
Pid: 3749, comm: syslog-ng Tainted: G      D   2.6.26-rc5-mm1 #4
RIP: 0010:[<ffffffff80266a37>]  [<ffffffff80266a37>] unlock_page+0x17/0x40
RSP: 0018:ffff81017efbd1e8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffe20000d5a798 RCX: 0000000000000034
RDX: 0000000000000000 RSI: ffffe20000d5a798 RDI: ffffe20000d5a798
RBP: ffff81017efbd1f8 R08: 0000000000000002 R09: 0000000000000001
R10: ffffffff8028b6f1 R11: 0000000000000000 R12: ffffe20000d5a798
R13: 0000000000000000 R14: ffff81017efbd448 R15: ffff81017efbd568
FS:  00007f39ccbef6f0(0000) GS:ffffffff805ddc80(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000001cd8028 CR3: 000000017efb7000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process syslog-ng (pid: 3749, threadinfo ffff81017efbc000, task ffff81017d97b3f0)
Stack:  ffff81017efbd1f8 0000000000000000 ffff81017efbd328 ffffffff802722ce
 ffffe2000538c6b0 ffff81017efbd2e8 0000000000000000 0000000000000000
 0000000000000000 0000000000000001 ffff81017efbd268 0000000000000246
Call Trace:
 [<ffffffff802722ce>] shrink_page_list+0x2ce/0x6d0
 [<ffffffff80271602>] ? isolate_pages_global+0xf2/0x270
 [<ffffffff802728f4>] shrink_list+0x224/0x590
 [<ffffffff8026e445>] ? determine_dirtyable_memory+0x15/0x30
 [<ffffffff8026e482>] ? get_dirty_limits+0x22/0x2a0
 [<ffffffff80272eab>] shrink_zone+0x24b/0x330
 [<ffffffff80273407>] try_to_free_pages+0x267/0x3e0
 [<ffffffff80271510>] ? isolate_pages_global+0x0/0x270
 [<ffffffff8026cf86>] __alloc_pages_internal+0x1b6/0x470
 [<ffffffff8026906d>] find_or_create_page+0x4d/0xa0
 [<ffffffff802b8c30>] __getblk+0xf0/0x280
 [<ffffffff802df4b8>] read_block_bitmap+0x48/0x170
 [<ffffffff802e03a6>] ext3_new_blocks+0x1f6/0x620
 [<ffffffff802e38c2>] ext3_get_blocks_handle+0x312/0xb60
 [<ffffffff8028bcaf>] ? init_object+0x4f/0x90
 [<ffffffff8028cf86>] ? __slab_alloc+0xa6/0x660
 [<ffffffff8025517d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff802b7ee7>] ? alloc_buffer_head+0x17/0x90
 [<ffffffff802e43a7>] ext3_get_block+0xb7/0x110
 [<ffffffff80467d40>] ? _spin_unlock+0x30/0x60
 [<ffffffff802b9ed8>] __block_prepare_write+0x268/0x470
 [<ffffffff802e42f0>] ? ext3_get_block+0x0/0x110
 [<ffffffff802ba176>] block_write_begin+0x56/0xe0
 [<ffffffff802e5c02>] ext3_write_begin+0xc2/0x1b0
 [<ffffffff802e42f0>] ? ext3_get_block+0x0/0x110
 [<ffffffff802677dd>] generic_file_buffered_write+0x14d/0x740
 [<ffffffff80467d40>] ? _spin_unlock+0x30/0x60
 [<ffffffff802ac0de>] ? mnt_drop_write+0x7e/0x160
 [<ffffffff80268260>] __generic_file_aio_write_nolock+0x2a0/0x460
 [<ffffffff80268486>] generic_file_aio_write+0x66/0xd0
 [<ffffffff802e1496>] ext3_file_write+0x26/0xc0
 [<ffffffff80291fb1>] do_sync_write+0xf1/0x130
 [<ffffffff80247ae0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8029276a>] vfs_write+0xaa/0xe0
 [<ffffffff80292d10>] sys_write+0x50/0x90
 [<ffffffff8020b6bb>] system_call_after_swapgs+0x7b/0x80


Code: fe 0f 1f 00 48 c7 c2 80 5d 57 80 eb c9 0f 1f 80 00 00 00 00 55 48 89 e5 53 48 89 fb 48 83 ec 08 f0 0f ba 37 00 19 c0 85 c0 75 04 <0f> 0b eb fe e8 90 f1 ff ff 48 89 de 48 89 c7 31 d2 e8 13 10 fe 
RIP  [<ffffffff80266a37>] unlock_page+0x17/0x40
 RSP <ffff81017efbd1e8>
---[ end trace d983269ed03ec2d7 ]---
---[ end trace d983269ed03ec2d7 ]---
------------[ cut here ]------------
kernel BUG at mm/filemap.c:575!
invalid opcode: 0000 [4] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/kernel/uevent_seqnum
CPU 0 
Modules linked in: ext2 nf_conntrack_irc xt_state iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack ip_tables x_tables usblp uhci_hcd ehci_hcd usbcore sr_mod cdrom
Pid: 19369, comm: growfiles Tainted: G      D   2.6.26-rc5-mm1 #4
RIP: 0010:[<ffffffff80266a37>]  [<ffffffff80266a37>] unlock_page+0x17/0x40
RSP: 0018:ffff81017e9c3658  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffe200011a9c10 RCX: 0000000000000034
RDX: 0000000000000000 RSI: ffffe200011a9c10 RDI: ffffe200011a9c10
RBP: ffff81017e9c3668 R08: 0000000000000002 R09: 0000000000000001
R10: ffffffff8028b6f1 R11: 0000000000000000 R12: ffffe200011a9c10
R13: 0000000000000001 R14: ffff81017e9c38b8 R15: ffff81017e9c39d8
FS:  00007fcc5d7af6f0(0000) GS:ffffffff805ddc80(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fcc5d31ebf0 CR3: 000000017aea2000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process growfiles (pid: 19369, threadinfo ffff81017e9c2000, task ffff81015c790000)
Stack:  ffff81017e9c3668 0000000000000000 ffff81017e9c3798 ffffffff802722ce
 ffffe20005370c60 ffff81017e9c3758 0000000000000000 0000000000000000
 0000000000000000 0000000000000001 ffff81017e9c36d8 0000000000000246
Call Trace:
 [<ffffffff802722ce>] shrink_page_list+0x2ce/0x6d0
 [<ffffffff80271602>] ? isolate_pages_global+0xf2/0x270
 [<ffffffff802728f4>] shrink_list+0x224/0x590
 [<ffffffff8026e445>] ? determine_dirtyable_memory+0x15/0x30
 [<ffffffff8026e482>] ? get_dirty_limits+0x22/0x2a0
 [<ffffffff80272eab>] shrink_zone+0x24b/0x330
 [<ffffffff80273407>] try_to_free_pages+0x267/0x3e0
 [<ffffffff80271510>] ? isolate_pages_global+0x0/0x270
 [<ffffffff8026cf86>] __alloc_pages_internal+0x1b6/0x470
 [<ffffffff80266e9a>] __grab_cache_page+0x6a/0xa0
 [<ffffffff802e5ba5>] ext3_write_begin+0x65/0x1b0
 [<ffffffff802677dd>] generic_file_buffered_write+0x14d/0x740
 [<ffffffff80467d40>] ? _spin_unlock+0x30/0x60
 [<ffffffff802ac0de>] ? mnt_drop_write+0x7e/0x160
 [<ffffffff80268260>] __generic_file_aio_write_nolock+0x2a0/0x460
 [<ffffffff80268486>] generic_file_aio_write+0x66/0xd0
 [<ffffffff802e1496>] ext3_file_write+0x26/0xc0
 [<ffffffff80291fb1>] do_sync_write+0xf1/0x130
 [<ffffffff80247ae0>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff802a26be>] ? locks_free_lock+0x3e/0x60
 [<ffffffff802a3c18>] ? fcntl_setlk+0x58/0x2c0
 [<ffffffff8029276a>] vfs_write+0xaa/0xe0
 [<ffffffff80292d10>] sys_write+0x50/0x90
 [<ffffffff8020b6bb>] system_call_after_swapgs+0x7b/0x80


Code: fe 0f 1f 00 48 c7 c2 80 5d 57 80 eb c9 0f 1f 80 00 00 00 00 55 48 89 e5 53 48 89 fb 48 83 ec 08 f0 0f ba 37 00 19 c0 85 c0 75 04 <0f> 0b eb fe e8 90 f1 ff ff 48 89 de 48 89 c7 31 d2 e8 13 10 fe 
RIP  [<ffffffff80266a37>] unlock_page+0x17/0x40
 RSP <ffff81017e9c3658>
---[ end trace d983269ed03ec2d7 ]---
------------[ cut here ]------------
kernel BUG at mm/filemap.c:575!
invalid opcode: 0000 [5] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/kernel/uevent_seqnum
CPU 0 
Modules linked in: ext2 nf_conntrack_irc xt_state iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack ip_tables x_tables usblp uhci_hcd ehci_hcd usbcore sr_mod cdrom
Pid: 15946, comm: pan Tainted: G      D   2.6.26-rc5-mm1 #4
RIP: 0010:[<ffffffff80266a37>]  [<ffffffff80266a37>] unlock_page+0x17/0x40
RSP: 0018:ffff81015c799958  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffe20000b020f8 RCX: 0000000000000034
RDX: 0000000000000000 RSI: ffffe20000b020f8 RDI: ffffe20000b020f8
RBP: ffff81015c799968 R08: 0000000000000002 R09: 0000000000000001
R10: ffffffff8028b6f1 R11: 0000000000000000 R12: ffffe20000b020f8
R13: 0000000000000001 R14: ffff81015c799bb8 R15: ffff81015c799cd8
FS:  00007fb10b0e76f0(0000) GS:ffffffff805ddc80(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fb10b0ee0c0 CR3: 000000017cd77000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process pan (pid: 15946, threadinfo ffff81015c798000, task ffff81017e2c5690)
Stack:  ffff81015c799968 0000000000000000 ffff81015c799a98 ffffffff802722ce
 ffffe200053868d8 ffff81015c799a58 0000000000000000 0000000000000000
 0000000000000000 0000000000000001 ffff81015c7999d8 0000000000000246
Call Trace:
 [<ffffffff802722ce>] shrink_page_list+0x2ce/0x6d0
 [<ffffffff802716a6>] ? isolate_pages_global+0x196/0x270
 [<ffffffff802728f4>] shrink_list+0x224/0x590
 [<ffffffff8026e445>] ? determine_dirtyable_memory+0x15/0x30
 [<ffffffff8026e482>] ? get_dirty_limits+0x22/0x2a0
 [<ffffffff80272eab>] shrink_zone+0x24b/0x330
 [<ffffffff80273407>] try_to_free_pages+0x267/0x3e0
 [<ffffffff80271510>] ? isolate_pages_global+0x0/0x270
 [<ffffffff8026cf86>] __alloc_pages_internal+0x1b6/0x470
 [<ffffffff8026d257>] __get_free_pages+0x17/0x60
 [<ffffffff80230616>] copy_process+0xb6/0x1270
 [<ffffffff80231902>] do_fork+0x82/0x280
 [<ffffffff802900fb>] ? fd_install+0x5b/0x70
 [<ffffffff804674bd>] ? lockdep_sys_exit_thunk+0x35/0x67
 [<ffffffff8020b6bb>] ? system_call_after_swapgs+0x7b/0x80
 [<ffffffff80209913>] sys_clone+0x23/0x30
 [<ffffffff8020ba57>] ptregscall_common+0x67/0xb0


Code: fe 0f 1f 00 48 c7 c2 80 5d 57 80 eb c9 0f 1f 80 00 00 00 00 55 48 89 e5 53 48 89 fb 48 83 ec 08 f0 0f ba 37 00 19 c0 85 c0 75 04 <0f> 0b eb fe e8 90 f1 ff ff 48 89 de 48 89 c7 31 d2 e8 13 10 fe 
RIP  [<ffffffff80266a37>] unlock_page+0x17/0x40
 RSP <ffff81015c799958>
---[ end trace d983269ed03ec2d7 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
