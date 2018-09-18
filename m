Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 302758E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 10:56:05 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w19-v6so2382947ioa.10
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 07:56:05 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id d11-v6sor1696805ith.73.2018.09.18.07.56.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 07:56:03 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 18 Sep 2018 07:56:03 -0700
Message-ID: <00000000000017d92b0576267d0f@google.com>
Subject: kernel BUG at include/linux/page-flags.h:LINE!
From: syzbot <syzbot+5373a556df9f9fec7e90@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak@linux.intel.com, akpm@linux-foundation.org, dhowells@redhat.com, jack@suse.cz, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com

Hello,

syzbot found the following crash on:

HEAD commit:    c0747ad363ff Merge tag 'linux-kselftest-4.19-rc5' of git:/..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1483a8c9400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=5fa12be50bca08d8
dashboard link: https://syzkaller.appspot.com/bug?extid=5373a556df9f9fec7e90
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+5373a556df9f9fec7e90@syzkaller.appspotmail.com

------------[ cut here ]------------
kernel BUG at include/linux/page-flags.h:273!
invalid opcode: 0000 [#1] PREEMPT SMP KASAN
CPU: 1 PID: 9734 Comm: kworker/u4:1 Not tainted 4.19.0-rc4+ #18
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Workqueue: writeback wb_workfn (flush-7:4)
RIP: 0010:PageWaiters include/linux/page-flags.h:273 [inline]
RIP: 0010:wake_up_page mm/filemap.c:1069 [inline]
RIP: 0010:end_page_writeback+0x769/0x950 mm/filemap.c:1233
Code: ff e8 6b 25 e2 ff 48 8b 85 30 fe ff ff 4c 8d 70 ff e9 d9 fa ff ff e8  
56 25 e2 ff 48 c7 c6 e0 24 12 88 48 89 df e8 a7 cc 13 00 <0f> 0b e8 40 25  
e2 ff 48 c7 c6 60 25 12 88 48 89 df e8 91 cc 13 00
RSP: 0018:ffff8801b91e5288 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffea00064dabc0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff81b08db9 RDI: ffffed003723ca42
RBP: ffff8801b91e5460 R08: ffff880157a40400 R09: ffffed003b5e4fe8
kobject: 'loop0' (00000000d6ad330d): kobject_uevent_env
R10: ffffed003b5e4fe8 R11: ffff8801daf27f47 R12: 0000000000000001
R13: 1ffff1003723ca53 R14: 1ffff1003723ca7f R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f6134b6cc90 CR3: 00000001cc363000 CR4: 00000000001406e0
kobject: 'loop0' (00000000d6ad330d): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  page_endio+0x67c/0xb60 mm/filemap.c:1260
  mpage_end_io+0x144/0x1e0 fs/mpage.c:54
  bio_endio+0x5d2/0xb80 block/bio.c:1774
  generic_make_request_checks+0x5f6/0x26c0 block/blk-core.c:2347
  generic_make_request+0x2bd/0x15a0 block/blk-core.c:2401
  submit_bio+0xba/0x460 block/blk-core.c:2566
  mpage_bio_submit fs/mpage.c:66 [inline]
  __mpage_writepage+0x1515/0x1d30 fs/mpage.c:627
  write_cache_pages+0xd8e/0x1e50 mm/page-writeback.c:2239
  mpage_writepages+0x14c/0x320 fs/mpage.c:730
  fat_writepages+0x24/0x30 fs/fat/inode.c:198
  do_writepages+0x9a/0x1a0 mm/page-writeback.c:2340
  __writeback_single_inode+0x20a/0x1620 fs/fs-writeback.c:1323
  writeback_sb_inodes+0x71f/0x11d0 fs/fs-writeback.c:1587
  __writeback_inodes_wb+0x1b9/0x340 fs/fs-writeback.c:1656
  wb_writeback+0xa73/0xfc0 fs/fs-writeback.c:1765
  wb_check_start_all fs/fs-writeback.c:1889 [inline]
  wb_do_writeback fs/fs-writeback.c:1915 [inline]
  wb_workfn+0xee9/0x1790 fs/fs-writeback.c:1949
  process_one_work+0xc90/0x1b90 kernel/workqueue.c:2153
  worker_thread+0x17f/0x1390 kernel/workqueue.c:2296
  kthread+0x35a/0x420 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:413
Modules linked in:
kobject: 'loop5' (0000000003a73ee3): kobject_uevent_env
kobject: 'loop5' (0000000003a73ee3): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
---[ end trace b1bf6d33e16c103c ]---
RIP: 0010:PageWaiters include/linux/page-flags.h:273 [inline]
RIP: 0010:wake_up_page mm/filemap.c:1069 [inline]
RIP: 0010:end_page_writeback+0x769/0x950 mm/filemap.c:1233
Code: ff e8 6b 25 e2 ff 48 8b 85 30 fe ff ff 4c 8d 70 ff e9 d9 fa ff ff e8  
56 25 e2 ff 48 c7 c6 e0 24 12 88 48 89 df e8 a7 cc 13 00 <0f> 0b e8 40 25  
e2 ff 48 c7 c6 60 25 12 88 48 89 df e8 91 cc 13 00
RSP: 0018:ffff8801b91e5288 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffea00064dabc0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff81b08db9 RDI: ffffed003723ca42
kobject: 'loop2' (0000000001c28b7c): kobject_uevent_env
RBP: ffff8801b91e5460 R08: ffff880157a40400 R09: ffffed003b5e4fe8
kobject: 'loop2' (0000000001c28b7c): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
R10: ffffed003b5e4fe8 R11: ffff8801daf27f47 R12: 0000000000000001
R13: 1ffff1003723ca53 R14: 1ffff1003723ca7f R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
kobject: 'loop3' (0000000091672ed1): kobject_uevent_env
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
kobject: 'loop3' (0000000091672ed1): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
CR2: 0000001b3202d000 CR3: 00000001cad9f000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
