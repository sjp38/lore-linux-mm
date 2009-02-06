Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8BA6D6B003D
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 10:10:44 -0500 (EST)
Received: by ewy13 with SMTP id 13so338775ewy.14
        for <linux-mm@kvack.org>; Fri, 06 Feb 2009 07:10:42 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 6 Feb 2009 18:10:40 +0300
Message-ID: <a4423d670902060710m4919f6d6p1ffae13859c891be@mail.gmail.com>
Subject: next-20090206: kernel BUG at mm/slub.c:1132
From: Alexander Beregalov <a.beregalov@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

I run dbench on btrfs, which is on file on xfs

btrfs: disabling barriers on dev /dev/loop/0
------------[ cut here ]------------
kernel BUG at mm/slub.c:1132!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/kernel/uevent_seqnum
CPU 1
Modules linked in:
Pid: 2078, comm: loop0 Not tainted 2.6.29-rc3-next-20090206 #1
RIP: 0010:[<ffffffff802c25ae>]  [<ffffffff802c25ae>] __slab_alloc+0x41e/0x610
RSP: 0018:ffff88007b17d620  EFLAGS: 00010202
RAX: 0000000000000000 RBX: 0000000000120012 RCX: 0000000000000010
RDX: 0000000000000000 RSI: ffffffff802c2301 RDI: ffffffff8026c12d
RBP: ffff88007b17d670 R08: 0000000000000001 R09: 0000000000000000
R10: ffff88007dbbce40 R11: 0000000000000000 R12: 0000000000000000
R13: ffff88007db82ed8 R14: ffff88007d2554a8 R15: ffff88007d255488
FS:  0000000000000000(0000) GS:ffff880004dd6000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007ff50c1bb000 CR3: 000000006c19d000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process loop0 (pid: 2078, threadinfo ffff88007b17c000, task ffff88007dbbce40)
Stack:
 ffffffff802c27d9 ffffffff804379f7 ffffffff7d255488 0000001000120012
 ffff88007b17d660 0000000000000000 0000000000000202 0000000000120012
 ffff88007d255488 ffffffff804379f7 ffff88007b17d6b0 ffffffff802c2896
Call Trace:
 [<ffffffff802c27d9>] ? kmem_cache_alloc+0x39/0x100
 [<ffffffff804379f7>] ? alloc_extent_state+0x17/0xa0
 [<ffffffff804379f7>] ? alloc_extent_state+0x17/0xa0
 [<ffffffff802c2896>] kmem_cache_alloc+0xf6/0x100
 [<ffffffff804379f7>] alloc_extent_state+0x17/0xa0
 [<ffffffff80439246>] clear_extent_bit+0x1a6/0x2e0
 [<ffffffff80439cee>] try_release_extent_state+0x7e/0xa0
 [<ffffffff80439e62>] try_release_extent_mapping+0x152/0x180
 [<ffffffff802a0520>] ? __remove_mapping+0xd0/0x100
 [<ffffffff804212f6>] __btrfs_releasepage+0x36/0x70
 [<ffffffff80421355>] btrfs_releasepage+0x25/0x30
 [<ffffffff8029391e>] try_to_release_page+0x2e/0x60
 [<ffffffff802a1542>] shrink_page_list+0x572/0x860
 [<ffffffff8062db3b>] ? _spin_unlock_irq+0x2b/0x60
 [<ffffffff802a1ae1>] ? shrink_list+0x2b1/0x680
 [<ffffffff802a1afd>] shrink_list+0x2cd/0x680
 [<ffffffff802358a0>] ? sub_preempt_count+0xc0/0x130
 [<ffffffff8062dbb2>] ? _spin_unlock_irqrestore+0x42/0x80
 [<ffffffff80475890>] ? __up_write+0x70/0x120
 [<ffffffff802a211b>] shrink_zone+0x26b/0x380
 [<ffffffff802a2b35>] try_to_free_pages+0x255/0x3d0
 [<ffffffff8029fc00>] ? isolate_pages_global+0x0/0x270
 [<ffffffff8029a767>] __alloc_pages_internal+0x237/0x590
 [<ffffffff80295545>] grab_cache_page_write_begin+0x85/0xd0
 [<ffffffff8062b88c>] ? __mutex_lock_common+0x37c/0x4d0
 [<ffffffff804fd7b3>] ? do_lo_send_aops+0x43/0x190
 [<ffffffff802ee577>] block_write_begin+0x87/0xf0
 [<ffffffff803eeee5>] xfs_vm_write_begin+0x25/0x30
 [<ffffffff803ef270>] ? xfs_get_blocks+0x0/0x20
 [<ffffffff802938eb>] pagecache_write_begin+0x1b/0x20
 [<ffffffff804fd823>] do_lo_send_aops+0xb3/0x190
 [<ffffffff8062db3b>] ? _spin_unlock_irq+0x2b/0x60
 [<ffffffff802358a0>] ? sub_preempt_count+0xc0/0x130
 [<ffffffff804fdd45>] loop_thread+0x445/0x4e0
 [<ffffffff804fd770>] ? do_lo_send_aops+0x0/0x190
 [<ffffffff80259420>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff804fd900>] ? loop_thread+0x0/0x4e0
 [<ffffffff80258f76>] kthread+0x56/0x90
 [<ffffffff8020ce5a>] child_rip+0xa/0x20
 [<ffffffff80235759>] ? finish_task_switch+0x89/0x110
 [<ffffffff8062db46>] ? _spin_unlock_irq+0x36/0x60
 [<ffffffff8020c840>] ? restore_args+0x0/0x30
 [<ffffffff80258f20>] ? kthread+0x0/0x90
 [<ffffffff8020ce50>] ? child_rip+0x0/0x20

Code: e8 18 69 1b 00 e9 48 ff ff ff 31 c9 48 c7 c2 00 4f 81 80 89 c6
e8 93 7f fd ff 48 89 c3 48 85 c0 0f 85 73 fe ff ff e9 91 fd ff ff <0f>
0b eb fe 49 83 7f 60 00 90 0f 84 2d fd ff ff 4c 89 f7 e8 aa
RIP  [<ffffffff802c25ae>] __slab_alloc+0x41e/0x610
RSP <ffff88007b17d620>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
