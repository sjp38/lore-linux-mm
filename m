Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C23A6B000C
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 14:23:04 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e8-v6so10365597ioq.11
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 11:23:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 18-v6sor2803606ite.32.2018.08.06.11.23.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 11:23:02 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 06 Aug 2018 11:23:02 -0700
In-Reply-To: <20180806181339.GD10003@dhcp22.suse.cz>
Message-ID: <0000000000002ec4580572c85e46@google.com>
Subject: Re: WARNING in try_charge
From: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

Hello,

syzbot has tested the proposed patch but the reproducer still triggered  
crash:
WARNING in try_charge

task=syz-executor4 pid=6578 invoked memcg oom killer. oom_victim=1
task=syz-executor6 pid=6576 charge for nr_pages=1
------------[ cut here ]------------
task=syz-executor6 pid=6576 charge bypass
Memory cgroup charge failed because of no reclaimable memory! This looks  
like a misconfiguration or a kernel bug.
WARNING: CPU: 1 PID: 6578 at mm/memcontrol.c:1707 mem_cgroup_oom  
mm/memcontrol.c:1706 [inline]
WARNING: CPU: 1 PID: 6578 at mm/memcontrol.c:1707 try_charge+0xafa/0x1710  
mm/memcontrol.c:2270
task=syz-executor6 pid=6576 charge for nr_pages=1
Kernel panic - not syncing: panic_on_warn set ...

CPU: 1 PID: 6578 Comm: syz-executor4 Not tainted 4.18.0-rc7-next-20180803+  
#1
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
task=syz-executor6 pid=6576 charge bypass
  panic+0x238/0x4e7 kernel/panic.c:184
task=syz-executor6 pid=6576 charge for nr_pages=1
  __warn.cold.8+0x163/0x1ba kernel/panic.c:536
task=syz-executor6 pid=6576 charge bypass
  report_bug+0x252/0x2d0 lib/bug.c:186
  fixup_bug arch/x86/kernel/traps.c:178 [inline]
  do_error_trap+0x1fc/0x4d0 arch/x86/kernel/traps.c:296
task=syz-executor6 pid=6576 charge for nr_pages=1
task=syz-executor6 pid=6576 charge bypass
  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:316
  invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:996
RIP: 0010:mem_cgroup_oom mm/memcontrol.c:1706 [inline]
RIP: 0010:try_charge+0xafa/0x1710 mm/memcontrol.c:2270
task=syz-executor6 pid=6576 charge for nr_pages=1
Code: 85 4a 01 00 00 8b b5 bc fd ff ff 44 89 f2 4c 89 ff e8 3a 4d ff ff 84  
c0 0f 85 9b 04 00 00 48 c7 c7 a0 18 13 87 e8 86 f9 85 ff <0f> 0b 48 8b 95  
d0 fd ff ff 48 8b b5 c0 fd ff ff 48 b8 00 00 00 00
RSP: 0018:ffff8801af5bf458 EFLAGS: 00010282
RAX: 0000000000000000 RBX: dffffc0000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff816366f1 RDI: ffff8801af5bf148
task=syz-executor6 pid=6576 charge bypass
RBP: ffff8801af5bf6f0 R08: ffff8801aeae2540 R09: fffffbfff0ff11fc
R10: fffffbfff0ff11fc R11: ffffffff87f88fe3 R12: ffff8801b6bd4800
R13: ffff8801af5bf6c8 R14: 0000000000000000 R15: ffff8801b6bd4800
task=syz-executor5 pid=6579 invoked memcg oom killer. oom_victim=1
------------[ cut here ]------------
Memory cgroup charge failed because of no reclaimable memory! This looks  
like a misconfiguration or a kernel bug.
  memcg_kmem_charge_memcg+0x7c/0x120 mm/memcontrol.c:2600
WARNING: CPU: 0 PID: 6579 at mm/memcontrol.c:1707 mem_cgroup_oom  
mm/memcontrol.c:1706 [inline]
WARNING: CPU: 0 PID: 6579 at mm/memcontrol.c:1707 try_charge+0xafa/0x1710  
mm/memcontrol.c:2270
  memcg_charge_slab mm/slab.h:283 [inline]
  kmem_getpages mm/slab.c:1415 [inline]
  cache_grow_begin+0x207/0x710 mm/slab.c:2677
Modules linked in:
  fallback_alloc+0x203/0x2c0 mm/slab.c:3219
CPU: 0 PID: 6579 Comm: syz-executor5 Not tainted 4.18.0-rc7-next-20180803+  
#1
  ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
  __do_cache_alloc mm/slab.c:3356 [inline]
  slab_alloc mm/slab.c:3384 [inline]
  kmem_cache_alloc+0x1e5/0x760 mm/slab.c:3552
RIP: 0010:mem_cgroup_oom mm/memcontrol.c:1706 [inline]
RIP: 0010:try_charge+0xafa/0x1710 mm/memcontrol.c:2270
  anon_vma_chain_alloc mm/rmap.c:129 [inline]
  __anon_vma_prepare+0xc4/0x720 mm/rmap.c:183
Code: 85 4a 01 00 00 8b b5 bc fd ff ff 44 89 f2 4c 89 ff e8 3a 4d ff ff 84  
c0 0f 85 9b 04 00 00 48 c7 c7 a0 18 13 87 e8 86 f9 85 ff <0f> 0b 48 8b 95  
d0 fd ff ff 48 8b b5 c0 fd ff ff 48 b8 00 00 00 00
RSP: 0018:ffff8801c82f7458 EFLAGS: 00010282
RAX: 0000000000000000 RBX: dffffc0000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff816366f1 RDI: ffff8801c82f7148
RBP: ffff8801c82f76f0 R08: ffff8801ae6905c0 R09: fffffbfff0ff11fc
R10: fffffbfff0ff11fc R11: ffffffff87f88fe3 R12: ffff8801b6bd4800
  anon_vma_prepare include/linux/rmap.h:153 [inline]
  do_anonymous_page mm/memory.c:3160 [inline]
  handle_pte_fault mm/memory.c:3971 [inline]
  __handle_mm_fault+0x3556/0x4470 mm/memory.c:4097
R13: ffff8801c82f76c8 R14: 0000000000000000 R15: ffff8801b6bd4800
FS:  0000000000b19940(0000) GS:ffff8801db000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000001dc8978 CR3: 00000001c83bc000 CR4: 00000000001406f0
Call Trace:
  memcg_kmem_charge_memcg+0x7c/0x120 mm/memcontrol.c:2600
  memcg_charge_slab mm/slab.h:283 [inline]
  kmem_getpages mm/slab.c:1415 [inline]
  cache_grow_begin+0x207/0x710 mm/slab.c:2677
  handle_mm_fault+0x53e/0xc80 mm/memory.c:4134
  fallback_alloc+0x203/0x2c0 mm/slab.c:3219
  ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
  __do_page_fault+0x620/0xe50 arch/x86/mm/fault.c:1395
  __do_cache_alloc mm/slab.c:3356 [inline]
  slab_alloc mm/slab.c:3384 [inline]
  kmem_cache_alloc+0x1e5/0x760 mm/slab.c:3552
  anon_vma_chain_alloc mm/rmap.c:129 [inline]
  __anon_vma_prepare+0xc4/0x720 mm/rmap.c:183
  do_page_fault+0xf6/0x8c0 arch/x86/mm/fault.c:1470
  anon_vma_prepare include/linux/rmap.h:153 [inline]
  do_anonymous_page mm/memory.c:3160 [inline]
  handle_pte_fault mm/memory.c:3971 [inline]
  __handle_mm_fault+0x3556/0x4470 mm/memory.c:4097
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1164
RIP: 0033:0x40e33f
Code: Bad RIP value.
RSP: 002b:00007ffc7e6c6590 EFLAGS: 00010206
RAX: 00007ff400550000 RBX: 0000000000020000 RCX: 0000000000456b7a
RDX: 0000000000021000 RSI: 0000000000021000 RDI: 0000000000000000
  handle_mm_fault+0x53e/0xc80 mm/memory.c:4134
RBP: 00007ffc7e6c6670 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffc7e6c6760
R13: 00007ff400570700 R14: 0000000000000005 R15: 0000000000000001
  __do_page_fault+0x620/0xe50 arch/x86/mm/fault.c:1395
  do_page_fault+0xf6/0x8c0 arch/x86/mm/fault.c:1470
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1164
RIP: 0033:0x40e33f
Code: Bad RIP value.
RSP: 002b:00007ffc29506db0 EFLAGS: 00010206
RAX: 00007f755194e000 RBX: 0000000000020000 RCX: 0000000000456b7a
RDX: 0000000000021000 RSI: 0000000000021000 RDI: 0000000000000000
RBP: 00007ffc29506e90 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffc29506f80
R13: 00007f755196e700 R14: 0000000000000005 R15: 0000000000000001
irq event stamp: 0
hardirqs last  enabled at (0): [<0000000000000000>]           (null)
hardirqs last disabled at (0): [<ffffffff8146af61>]  
copy_process.part.37+0x1911/0x7240 kernel/fork.c:1781
softirqs last  enabled at (0): [<ffffffff8146b002>]  
copy_process.part.37+0x19b2/0x7240 kernel/fork.c:1784
softirqs last disabled at (0): [<0000000000000000>]           (null)
---[ end trace 0466ae1ce671f8c4 ]---
Dumping ftrace buffer:
    (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..


Tested on:

commit:         116b181bb646 Add linux-next specific files for 20180803
git tree:        
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
console output: https://syzkaller.appspot.com/x/log.txt?x=14dfe2ac400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=b4f38be7c2c519d5
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
patch:          https://syzkaller.appspot.com/x/patch.diff?x=10fccee8400000
