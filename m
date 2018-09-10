Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A41F98E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 04:35:04 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id o4-v6so3238422iob.12
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 01:35:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id e185-v6sor12241085ith.43.2018.09.10.01.35.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 01:35:02 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 10 Sep 2018 01:35:02 -0700
Message-ID: <000000000000c691670575803b0c@google.com>
Subject: BUG: Bad page map (3)
From: syzbot <syzbot+0b10582e8ee2a6253de7@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, christian.koenig@amd.com, dan.j.williams@intel.com, dave@stgolabs.net, dwmw@amazon.co.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com

Hello,

syzbot found the following crash on:

HEAD commit:    3d0e7a9e00fd Merge tag 'md/4.19-rc2' of git://git.kernel.o..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1782d70a400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=8f59875069d721b6
dashboard link: https://syzkaller.appspot.com/bug?extid=0b10582e8ee2a6253de7
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+0b10582e8ee2a6253de7@syzkaller.appspotmail.com

BUG: Bad page map in process syz-executor3  pte:ffffffff8901f947  
pmd:18d73f067
addr:000000006b20cb06 vm_flags:180400fb anon_vma:          (null)  
mapping:000000007878cb6c index:b7
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 19022 Comm: syz-executor3 Not tainted 4.19.0-rc2+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
  print_bad_pte.cold.111+0x1e6/0x24b mm/memory.c:773
  _vm_normal_page+0x248/0x3c0 mm/memory.c:859
  zap_pte_range mm/memory.c:1311 [inline]
  zap_pmd_range mm/memory.c:1440 [inline]
  zap_pud_range mm/memory.c:1469 [inline]
  zap_p4d_range mm/memory.c:1490 [inline]
  unmap_page_range+0x9a5/0x2000 mm/memory.c:1511
  unmap_single_vma+0x19b/0x310 mm/memory.c:1556
  unmap_vmas+0x125/0x200 mm/memory.c:1586
  exit_mmap+0x2be/0x590 mm/mmap.c:3093
  __mmput kernel/fork.c:1001 [inline]
  mmput+0x247/0x610 kernel/fork.c:1022
  exit_mm kernel/exit.c:545 [inline]
  do_exit+0xe6f/0x2610 kernel/exit.c:854
  do_group_exit+0x177/0x440 kernel/exit.c:970
  get_signal+0x8b0/0x1980 kernel/signal.c:2513
  do_signal+0x9c/0x21e0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457099
Code: Bad RIP value.
RSP: 002b:00007f9decd04cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 00000000009300a8 RCX: 0000000000457099
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 00000000009300a8
RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000009300ac
R13: 00007ffe4545d67f R14: 00007f9decd059c0 R15: 0000000000000000
swap_info_get: Bad swap file entry 3ffffffffffff
BUG: Bad page map in process syz-executor3  pte:00000008 pmd:18d73f067
addr:000000005c045c2f vm_flags:180400fb anon_vma:          (null)  
mapping:000000007878cb6c index:ba
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 19022 Comm: syz-executor3 Tainted: G    B              
4.19.0-rc2+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
  print_bad_pte.cold.111+0x1e6/0x24b mm/memory.c:773
  zap_pte_range mm/memory.c:1385 [inline]
  zap_pmd_range mm/memory.c:1440 [inline]
  zap_pud_range mm/memory.c:1469 [inline]
  zap_p4d_range mm/memory.c:1490 [inline]
  unmap_page_range+0x196f/0x2000 mm/memory.c:1511
  unmap_single_vma+0x19b/0x310 mm/memory.c:1556
  unmap_vmas+0x125/0x200 mm/memory.c:1586
  exit_mmap+0x2be/0x590 mm/mmap.c:3093
  __mmput kernel/fork.c:1001 [inline]
  mmput+0x247/0x610 kernel/fork.c:1022
  exit_mm kernel/exit.c:545 [inline]
  do_exit+0xe6f/0x2610 kernel/exit.c:854
  do_group_exit+0x177/0x440 kernel/exit.c:970
  get_signal+0x8b0/0x1980 kernel/signal.c:2513
  do_signal+0x9c/0x21e0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457099
Code: Bad RIP value.
RSP: 002b:00007f9decd04cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 00000000009300a8 RCX: 0000000000457099
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 00000000009300a8
RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000009300ac
R13: 00007ffe4545d67f R14: 00007f9decd059c0 R15: 0000000000000000
BUG: Bad page map in process syz-executor3  pte:ffff8801ce138140  
pmd:18d73f067
addr:00000000df7251c2 vm_flags:180400fb anon_vma:          (null)  
mapping:000000007878cb6c index:bc
file:kcov fault:          (null) mmap:kcov_mmap readpage:          (null)
CPU: 0 PID: 19022 Comm: syz-executor3 Tainted: G    B              
4.19.0-rc2+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
  print_bad_pte.cold.111+0x1e6/0x24b mm/memory.c:773
  _vm_normal_page+0x248/0x3c0 mm/memory.c:859
  zap_pte_range mm/memory.c:1311 [inline]
  zap_pmd_range mm/memory.c:1440 [inline]
  zap_pud_range mm/memory.c:1469 [inline]
  zap_p4d_range mm/memory.c:1490 [inline]
  unmap_page_range+0x9a5/0x2000 mm/memory.c:1511
  unmap_single_vma+0x19b/0x310 mm/memory.c:1556
  unmap_vmas+0x125/0x200 mm/memory.c:1586
  exit_mmap+0x2be/0x590 mm/mmap.c:3093
  __mmput kernel/fork.c:1001 [inline]
  mmput+0x247/0x610 kernel/fork.c:1022
  exit_mm kernel/exit.c:545 [inline]
  do_exit+0xe6f/0x2610 kernel/exit.c:854
  do_group_exit+0x177/0x440 kernel/exit.c:970
  get_signal+0x8b0/0x1980 kernel/signal.c:2513
  do_signal+0x9c/0x21e0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457099
Code: Bad RIP value.
RSP: 002b:00007f9decd04cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 00000000009300a8 RCX: 0000000000457099
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 00000000009300a8
RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000009300ac
R13: 00007ffe4545d67f R14: 00007f9decd059c0 R15: 0000000000000000
------------[ cut here ]------------
kernel BUG at include/linux/swapops.h:215!
invalid opcode: 0000 [#1] PREEMPT SMP KASAN
CPU: 0 PID: 19022 Comm: syz-executor3 Tainted: G    B              
4.19.0-rc2+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:migration_entry_to_page+0x444/0x550 include/linux/swapops.h:215
Code: 2b e8 70 6a cd ff 48 c7 c6 60 af 13 88 4c 89 e7 e8 c1 0b ff ff 0f 0b  
e8 5a 6a cd ff 4d 8d 67 ff e9 a3 fe ff ff e8 4c 6a cd ff <0f> 0b e8 45 6a  
cd ff 4c 8d 63 ff eb ca e8 da cf 10 00 e9 63 fc ff
RSP: 0018:ffff880081026b20 EFLAGS: 00010293
RAX: ffff8801cc706340 RBX: fffff8ffce518000 RCX: ffffffff81b163c4
RDX: 0000000000000000 RSI: ffffffff81b164f4 RDI: 0000000000000007
RBP: ffff880081026c78 R08: ffff8801cc706340 R09: fffffbfff1326cb0
R10: fffffbfff1326cb0 R11: 0000000000000003 R12: 0000000000000000
R13: 1ffff10010204d66 R14: 0000000000000000 R15: 0000000000000000
FS:  00007f9decd05700(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000045706f CR3: 0000000136186000 CR4: 00000000001426f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  zap_pte_range mm/memory.c:1381 [inline]
  zap_pmd_range mm/memory.c:1440 [inline]
  zap_pud_range mm/memory.c:1469 [inline]
  zap_p4d_range mm/memory.c:1490 [inline]
  unmap_page_range+0x108f/0x2000 mm/memory.c:1511
  unmap_single_vma+0x19b/0x310 mm/memory.c:1556
  unmap_vmas+0x125/0x200 mm/memory.c:1586
  exit_mmap+0x2be/0x590 mm/mmap.c:3093
  __mmput kernel/fork.c:1001 [inline]
  mmput+0x247/0x610 kernel/fork.c:1022
  exit_mm kernel/exit.c:545 [inline]
  do_exit+0xe6f/0x2610 kernel/exit.c:854
  do_group_exit+0x177/0x440 kernel/exit.c:970
  get_signal+0x8b0/0x1980 kernel/signal.c:2513
  do_signal+0x9c/0x21e0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457099
Code: Bad RIP value.
RSP: 002b:00007f9decd04cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 00000000009300a8 RCX: 0000000000457099
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 00000000009300a8
RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000009300ac
R13: 00007ffe4545d67f R14: 00007f9decd059c0 R15: 0000000000000000
Modules linked in:
Dumping ftrace buffer:
    (ftrace buffer empty)
---[ end trace 434b92653afbda82 ]---
RIP: 0010:migration_entry_to_page+0x444/0x550 include/linux/swapops.h:215
Code: 2b e8 70 6a cd ff 48 c7 c6 60 af 13 88 4c 89 e7 e8 c1 0b ff ff 0f 0b  
e8 5a 6a cd ff 4d 8d 67 ff e9 a3 fe ff ff e8 4c 6a cd ff <0f> 0b e8 45 6a  
cd ff 4c 8d 63 ff eb ca e8 da cf 10 00 e9 63 fc ff
RSP: 0018:ffff880081026b20 EFLAGS: 00010293
RAX: ffff8801cc706340 RBX: fffff8ffce518000 RCX: ffffffff81b163c4
RDX: 0000000000000000 RSI: ffffffff81b164f4 RDI: 0000000000000007
RBP: ffff880081026c78 R08: ffff8801cc706340 R09: fffffbfff1326cb0
R10: fffffbfff1326cb0 R11: 0000000000000003 R12: 0000000000000000
R13: 1ffff10010204d66 R14: 0000000000000000 R15: 0000000000000000
FS:  00007f9decd05700(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000045706f CR3: 0000000136186000 CR4: 00000000001426f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
