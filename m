Received: by ug-out-1314.google.com with SMTP id h3so282428ugf.29
        for <linux-mm@kvack.org>; Thu, 12 Jun 2008 01:02:59 -0700 (PDT)
Date: Thu, 12 Jun 2008 11:58:58 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: 2.6.26-rc5-mm3: kernel BUG at mm/vmscan.c:510
Message-ID: <20080612075858.GA4874@martell.zuzino.mipt.ru>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

[  254.217776] ------------[ cut here ]------------
[  254.217776] kernel BUG at mm/vmscan.c:510!
[  254.217776] invalid opcode: 0000 [1] PREEMPT SMP DEBUG_PAGEALLOC
[  254.217776] last sysfs file: /sys/kernel/uevent_seqnum
[  254.217776] CPU 1 
[  254.217776] Modules linked in: ext2 nf_conntrack_irc xt_state iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack ip_tables x_tables usblp ehci_hcd uhci_hcd usbcore sr_mod cdrom
[  254.217776] Pid: 12044, comm: madvise02 Not tainted 2.6.26-rc5-mm3 #4
[  254.217776] RIP: 0010:[<ffffffff802729b2>]  [<ffffffff802729b2>] putback_lru_page+0x152/0x160
[  254.217776] RSP: 0018:ffff81012edd1cd8  EFLAGS: 00010202
[  254.217776] RAX: ffffe20003f344b8 RBX: 0000000000000000 RCX: 0000000000000001
[  254.217776] RDX: 0000000000005d5c RSI: 0000000000000000 RDI: ffffe20003f344b8
[  254.217776] RBP: ffff81012edd1cf8 R08: 0000000000000000 R09: 0000000000000000
[  254.217776] R10: ffffffff80275152 R11: 0000000000000001 R12: ffffe20003f344b8
[  254.217776] R13: 00000000ffffffff R14: ffff810124801080 R15: ffffffffffffffff
[  254.217776] FS:  00007fb3ad83c6f0(0000) GS:ffff81017f845320(0000) knlGS:0000000000000000
[  254.217776] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  254.217776] CR2: 00007fffb5846d38 CR3: 0000000117de9000 CR4: 00000000000006e0
[  254.217776] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  254.217776] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  254.217776] Process madvise02 (pid: 12044, threadinfo ffff81012edd0000, task ffff81017db6b3c0)
[  254.217776] Stack:  ffffe20003f344b8 ffffe20003f344b8 ffffffff80629300 0000000000000001
[  254.217776]  ffff81012edd1d18 ffffffff8027d268 ffffe20003f344b8 0000000000000000
[  254.217776]  ffff81012edd1d38 ffffffff80271783 0000000000000246 ffffe20003f344b8
[  254.217776] Call Trace:
[  254.217776]  [<ffffffff8027d268>] __clear_page_mlock+0xe8/0x100
[  254.217776]  [<ffffffff80271783>] truncate_complete_page+0x73/0x80
[  254.217776]  [<ffffffff80271871>] truncate_inode_pages_range+0xe1/0x3c0
[  254.217776]  [<ffffffff80271b60>] truncate_inode_pages+0x10/0x20
[  254.217776]  [<ffffffff802e9738>] ext3_delete_inode+0x18/0xf0
[  254.217776]  [<ffffffff802e9720>] ? ext3_delete_inode+0x0/0xf0
[  254.217776]  [<ffffffff802aa27b>] generic_delete_inode+0x7b/0x100
[  254.217776]  [<ffffffff802aa43c>] generic_drop_inode+0x13c/0x180
[  254.217776]  [<ffffffff802a960d>] iput+0x5d/0x70
[  254.217776]  [<ffffffff8029f43e>] do_unlinkat+0x13e/0x1e0
[  254.217776]  [<ffffffff8046de77>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  254.217776]  [<ffffffff80255c69>] ? trace_hardirqs_on_caller+0xc9/0x150
[  254.217776]  [<ffffffff8046de77>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  254.217776]  [<ffffffff8029f4f1>] sys_unlink+0x11/0x20
[  254.217776]  [<ffffffff8020b6bb>] system_call_after_swapgs+0x7b/0x80
[  254.217776] 
[  254.217776] 
[  254.217776] Code: 0f 0b eb fe 0f 1f 44 00 00 f6 47 01 40 48 89 f8 75 1d 83 78 08 01 75 13 4c 89 e7 31 db e8 97 44 ff ff e9 2b ff ff ff 0f 0b eb fe <0f> 0b eb fe 48 8b 47 10 eb dd 0f 1f 40 00 55 48 89 e5 41 57 45 
[  254.217776] RIP  [<ffffffff802729b2>] putback_lru_page+0x152/0x160
[  254.217776]  RSP <ffff81012edd1cd8>
[  254.234540] ---[ end trace a1dd07b571590cc8 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
