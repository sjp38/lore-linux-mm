Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3E78E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 05:43:04 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id w68so26308398ith.0
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 02:43:04 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id h3sor3145445jaa.13.2019.01.03.02.43.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 02:43:03 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 03 Jan 2019 02:43:02 -0800
Message-ID: <0000000000004d2e19057e8b6d78@google.com>
Subject: kernel BUG at mm/huge_memory.c:LINE!
From: syzbot <syzbot+8e075128f7db8555391a@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, jglisse@redhat.com, khlebnikov@yandex-team.ru, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, willy@infradead.org

Hello,

syzbot found the following crash on:

HEAD commit:    4cd1b60def51 Add linux-next specific files for 20190102
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=147760d3400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=e8ea56601353001c
dashboard link: https://syzkaller.appspot.com/bug?extid=8e075128f7db8555391a
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+8e075128f7db8555391a@syzkaller.appspotmail.com

raw: 01fffc000009000d dead000000000100 dead000000000200 ffff88809a33f5b1
raw: 0000000000020000 0000000000000000 0000020000000000 ffff888095368000
page dumped because: VM_BUG_ON_PAGE(compound_mapcount(head))
page->mem_cgroup:ffff888095368000
------------[ cut here ]------------
kernel BUG at mm/huge_memory.c:2683!
invalid opcode: 0000 [#1] PREEMPT SMP KASAN
CPU: 0 PID: 1551 Comm: kswapd0 Not tainted 4.20.0-next-20190102 #3
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:split_huge_page_to_list+0x2161/0x2ac0 mm/huge_memory.c:2683
Code: ff e8 33 35 b8 ff 48 8b 85 10 fc ff ff 4c 8d 70 ff e9 1e ea ff ff e8  
1e 35 b8 ff 48 c7 c6 a0 a3 54 88 4c 89 ef e8 0f 15 ea ff <0f> 0b 48 89 85  
10 fc ff ff e8 01 35 b8 ff 48 8b 85 10 fc ff ff 4c
RSP: 0018:ffff8880a5f36de8 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8880a5f371d8 RCX: 0000000000000000
RDX: ffffed1014be6d6e RSI: ffffffff81b3831e RDI: ffffed1014be6dae
RBP: ffff8880a5f37200 R08: 0000000000000021 R09: ffffed1015cc5021
R10: ffffed1015cc5020 R11: ffff8880ae628107 R12: ffffea0000e80080
R13: ffffea0000e80000 R14: 00000000fffffffe R15: 01fffc000009000d
FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020003030 CR3: 0000000219267000 CR4: 00000000001426f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  split_huge_page include/linux/huge_mm.h:148 [inline]
  deferred_split_scan+0xa47/0x11d0 mm/huge_memory.c:2820
  do_shrink_slab+0x4e5/0xd30 mm/vmscan.c:561
  shrink_slab mm/vmscan.c:710 [inline]
  shrink_slab+0x6bb/0x8c0 mm/vmscan.c:690
  shrink_node+0x61a/0x17e0 mm/vmscan.c:2776
  kswapd_shrink_node mm/vmscan.c:3535 [inline]
  balance_pgdat+0xb00/0x18b0 mm/vmscan.c:3693
  kswapd+0x839/0x1330 mm/vmscan.c:3948
  kthread+0x357/0x430 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
Modules linked in:
kobject: 'loop1' (000000002d2ad2ad): kobject_uevent_env
kobject: 'loop1' (000000002d2ad2ad): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (000000003c94a079): kobject_uevent_env
kobject: 'loop3' (000000003c94a079): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (0000000000e89d9d): kobject_uevent_env
kobject: 'loop5' (0000000000e89d9d): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop2' (000000001a685ee7): kobject_uevent_env
kobject: 'loop2' (000000001a685ee7): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (000000003c94a079): kobject_uevent_env
kobject: 'loop3' (000000003c94a079): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
---[ end trace a543f5c1741fca97 ]---
kobject: 'loop0' (00000000aa59ea1f): kobject_uevent_env
RIP: 0010:split_huge_page_to_list+0x2161/0x2ac0 mm/huge_memory.c:2683
Code: ff e8 33 35 b8 ff 48 8b 85 10 fc ff ff 4c 8d 70 ff e9 1e ea ff ff e8  
1e 35 b8 ff 48 c7 c6 a0 a3 54 88 4c 89 ef e8 0f 15 ea ff <0f> 0b 48 89 85  
10 fc ff ff e8 01 35 b8 ff 48 8b 85 10 fc ff ff 4c
kobject: 'loop0' (00000000aa59ea1f): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
RSP: 0018:ffff8880a5f36de8 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8880a5f371d8 RCX: 0000000000000000
RDX: ffffed1014be6d6e RSI: ffffffff81b3831e RDI: ffffed1014be6dae
RBP: ffff8880a5f37200 R08: 0000000000000021 R09: ffffed1015cc5021
netlink: 'syz-executor0': attribute type 22 has an invalid length.
R10: ffffed1015cc5020 R11: ffff8880ae628107 R12: ffffea0000e80080
R13: ffffea0000e80000 R14: 00000000fffffffe R15: 01fffc000009000d
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
kobject: 'loop1' (000000002d2ad2ad): kobject_uevent_env
kobject: 'loop1' (000000002d2ad2ad): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004efb18 CR3: 00000000702a7000 CR4: 00000000001426e0
kobject: 'loop5' (0000000000e89d9d): kobject_uevent_env
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kobject: 'loop5' (0000000000e89d9d): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
kobject: 'loop3' (000000003c94a079): kobject_uevent_env


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
