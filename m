Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C242D6B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 12:49:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p12-v6so8370290iog.8
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 09:49:02 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 22-v6sor8011416iob.307.2018.07.11.09.49.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 09:49:01 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 11 Jul 2018 09:49:01 -0700
Message-ID: <00000000000010c9390570bc0643@google.com>
Subject: general protection fault in _vm_normal_page
From: syzbot <syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jglisse@redhat.com, kirill.shutemov@linux.intel.com, ldufour@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, ross.zwisler@linux.intel.com, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

Hello,

syzbot found the following crash on:

HEAD commit:    98be45067040 Add linux-next specific files for 20180711
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=12496ac2400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=3f3b3673fec35d01
dashboard link: https://syzkaller.appspot.com/bug?extid=120abb1c3f7bfdc523f7
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=12a46568400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com

R10: 0000000004000812 R11: 0000000000000246 R12: 0000000000000005
R13: 00000000004c0565 R14: 00000000004cffb0 R15: 0000000000000005
ion_mmap: failure mapping buffer to userspace
kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
CPU: 0 PID: 4785 Comm: syz-executor0 Not tainted 4.18.0-rc4-next-20180711+  
#4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:_vm_normal_page+0x1e5/0x330 mm/memory.c:828
Code: 00 0f 85 3a 01 00 00 48 8b 85 70 ff ff ff 48 ba 00 00 00 00 00 fc ff  
df 48 8b 80 90 00 00 00 48 8d 78 70 48 89 f9 48 c1 e9 03 <80> 3c 11 00 0f  
85 17 01 00 00 48 8b 40 70 48 85 c0 48 89 85 60 ff
RSP: 0018:ffff8801d2d2f050 EFLAGS: 00010202
RAX: 0000000000000000 RBX: 0000000000198700 RCX: 000000000000000e
RDX: dffffc0000000000 RSI: ffffffff81abf579 RDI: 0000000000000070
RBP: ffff8801d2d2f0f0 R08: ffff8801aab72040 R09: ffffed003a591216
R10: ffffed003a591216 R11: ffff8801d2c890b3 R12: 1ffff1003a5a5e0d
R13: ffff8801d2d2f0c8 R14: 0000000198700320 R15: 0000000000000200
FS:  000000000118c940(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004e8664 CR3: 00000001cb276000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  zap_pte_range mm/memory.c:1312 [inline]
  zap_pmd_range mm/memory.c:1443 [inline]
  zap_pud_range mm/memory.c:1472 [inline]
  zap_p4d_range mm/memory.c:1493 [inline]
  unmap_page_range+0xa6f/0x2220 mm/memory.c:1514
  unmap_single_vma+0x1a0/0x310 mm/memory.c:1559
  unmap_vmas+0x120/0x1f0 mm/memory.c:1589
  unmap_region+0x353/0x570 mm/mmap.c:2583
  mmap_region+0x18cc/0x1da0 mm/mmap.c:1840
  do_mmap+0xa10/0x1220 mm/mmap.c:1540
  do_mmap_pgoff include/linux/mm.h:2290 [inline]
  vm_mmap_pgoff+0x213/0x2c0 mm/util.c:357
  ksys_mmap_pgoff+0x4da/0x660 mm/mmap.c:1590
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455e29
Code: 1d ba fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b9 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007ffdd494a4b8 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 000000000118c914 RCX: 0000000000455e29
RDX: 0000000000000000 RSI: 0000000000003060 RDI: 0000000020ffd000
RBP: 000000000072bea0 R08: 0000000000000004 R09: 0000000000000000
R10: 0000000004000812 R11: 0000000000000246 R12: 0000000000000005
R13: 00000000004c0565 R14: 00000000004cffb0 R15: 0000000000000005
Modules linked in:
Dumping ftrace buffer:
    (ftrace buffer empty)
---[ end trace 161bdc8eda63d641 ]---
RIP: 0010:_vm_normal_page+0x1e5/0x330 mm/memory.c:828
Code: 00 0f 85 3a 01 00 00 48 8b 85 70 ff ff ff 48 ba 00 00 00 00 00 fc ff  
df 48 8b 80 90 00 00 00 48 8d 78 70 48 89 f9 48 c1 e9 03 <80> 3c 11 00 0f  
85 17 01 00 00 48 8b 40 70 48 85 c0 48 89 85 60 ff
RSP: 0018:ffff8801d2d2f050 EFLAGS: 00010202
RAX: 0000000000000000 RBX: 0000000000198700 RCX: 000000000000000e
RDX: dffffc0000000000 RSI: ffffffff81abf579 RDI: 0000000000000070
RBP: ffff8801d2d2f0f0 R08: ffff8801aab72040 R09: ffffed003a591216
R10: ffffed003a591216 R11: ffff8801d2c890b3 R12: 1ffff1003a5a5e0d
R13: ffff8801d2d2f0c8 R14: 0000000198700320 R15: 0000000000000200
FS:  000000000118c940(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004e8664 CR3: 00000001cb276000 CR4: 00000000001406f0
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
