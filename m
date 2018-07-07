Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id F188E6B0006
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 21:19:03 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id i18-v6so10909638iog.12
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 18:19:03 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id l24-v6sor3685884ioj.240.2018.07.06.18.19.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 18:19:02 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 06 Jul 2018 18:19:02 -0700
Message-ID: <000000000000d624c605705e9010@google.com>
Subject: kernel BUG at mm/shmem.c:LINE!
From: syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

Hello,

syzbot found the following crash on:

HEAD commit:    526674536360 Add linux-next specific files for 20180706
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=116d16fc400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c8d1cfc0cb798e48
dashboard link: https://syzkaller.appspot.com/bug?extid=b8e0dfee3fd8c9012771
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=170e462c400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=15f1ba2c400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com

raw: 02fffc0000001028 ffffea0007011dc8 ffffea0007058b48 ffff8801a7576ab8
raw: 000000000000016e ffff8801a7588930 00000003ffffffff ffff8801d9a44c80
page dumped because: VM_BUG_ON_PAGE(page_to_pgoff(page) != index)
page->mem_cgroup:ffff8801d9a44c80
------------[ cut here ]------------
kernel BUG at mm/shmem.c:815!
invalid opcode: 0000 [#1] SMP KASAN
CPU: 0 PID: 4429 Comm: syz-executor697 Not tainted  
4.18.0-rc3-next-20180706+ #1
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:shmem_undo_range+0xdaa/0x29a0 mm/shmem.c:815
Code: 00 0f 85 bd 19 00 00 48 8d 65 d8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8  
a5 f0 d6 ff 48 c7 c6 e0 32 f1 87 4c 89 e7 e8 16 10 05 00 <0f> 0b e8 8f f0  
d6 ff 49 8d 7c 24 20 48 89 f8 48 c1 e8 03 80 3c 18
RSP: 0018:ffff8801ab88e158 EFLAGS: 00010246
RAX: 0000000000000000 RBX: dffffc0000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff81aaab95 RDI: ffffed0035711c18
RBP: ffff8801ab88e8d0 R08: ffff8801a7af04c0 R09: ffffed003b5c4fc0
R10: ffffed003b5c4fc0 R11: ffff8801dae27e07 R12: ffffea0007058b00
R13: ffff8801ab88e8a8 R14: 0000000000000001 R15: 000000000000016e
FS:  0000000000000000(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004b625c CR3: 0000000008e6a000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  shmem_truncate_range+0x27/0xa0 mm/shmem.c:971
  shmem_evict_inode+0x3b2/0xcb0 mm/shmem.c:1071
  evict+0x4ae/0x990 fs/inode.c:558
  iput_final fs/inode.c:1508 [inline]
  iput+0x635/0xaa0 fs/inode.c:1534
  dentry_unlink_inode+0x4ae/0x640 fs/dcache.c:377
  __dentry_kill+0x44c/0x7a0 fs/dcache.c:569
  dentry_kill+0xc9/0x5a0 fs/dcache.c:688
  dput.part.26+0x66b/0x7a0 fs/dcache.c:849
  dput+0x15/0x20 fs/dcache.c:831
  __fput+0x558/0x930 fs/file_table.c:235
  ____fput+0x15/0x20 fs/file_table.c:251
  task_work_run+0x1ec/0x2a0 kernel/task_work.c:113
  exit_task_work include/linux/task_work.h:22 [inline]
  do_exit+0x1b08/0x2750 kernel/exit.c:869
  do_group_exit+0x177/0x440 kernel/exit.c:972
  get_signal+0x88e/0x1970 kernel/signal.c:2467
  do_signal+0x9c/0x21c0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e0/0x370 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x441c29
Code: Bad RIP value.
RSP: 002b:00007fff6e973338 EFLAGS: 00000246 ORIG_RAX: 0000000000000028
RAX: ffffffffffffffe0 RBX: 0000000000000000 RCX: 0000000000441c29
RDX: 0000000020000180 RSI: 0000000000000004 RDI: 0000000000000003
RBP: 00007fff6e973350 R08: 0000000000000001 R09: 0000000000000000
R10: 0a00004000000002 R11: 0000000000000246 R12: ffffffffffffffff
R13: 0000000000000005 R14: 0000000000000000 R15: 0000000000000000
Modules linked in:
Dumping ftrace buffer:
    (ftrace buffer empty)
---[ end trace 68c2f261fd3bbf54 ]---
RIP: 0010:shmem_undo_range+0xdaa/0x29a0 mm/shmem.c:815
Code: 00 0f 85 bd 19 00 00 48 8d 65 d8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8  
a5 f0 d6 ff 48 c7 c6 e0 32 f1 87 4c 89 e7 e8 16 10 05 00 <0f> 0b e8 8f f0  
d6 ff 49 8d 7c 24 20 48 89 f8 48 c1 e8 03 80 3c 18
RSP: 0018:ffff8801ab88e158 EFLAGS: 00010246
RAX: 0000000000000000 RBX: dffffc0000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff81aaab95 RDI: ffffed0035711c18
RBP: ffff8801ab88e8d0 R08: ffff8801a7af04c0 R09: ffffed003b5c4fc0
R10: ffffed003b5c4fc0 R11: ffff8801dae27e07 R12: ffffea0007058b00
R13: ffff8801ab88e8a8 R14: 0000000000000001 R15: 000000000000016e
FS:  0000000000000000(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000441bff CR3: 0000000008e6a000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches
