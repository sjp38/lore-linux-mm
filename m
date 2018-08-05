Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3899B6B0007
	for <linux-mm@kvack.org>; Sun,  5 Aug 2018 04:14:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id a10-v6so9630847itc.9
        for <linux-mm@kvack.org>; Sun, 05 Aug 2018 01:14:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id k128-v6sor1421847itg.91.2018.08.05.01.14.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 Aug 2018 01:14:02 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 05 Aug 2018 01:14:02 -0700
In-Reply-To: <0000000000005e979605729c1564@google.com>
Message-ID: <00000000000059e4fd0572abbe4a@google.com>
Subject: Re: WARNING in try_charge
From: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

syzbot has found a reproducer for the following crash on:

HEAD commit:    116b181bb646 Add linux-next specific files for 20180803
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=15f87bfc400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=b4f38be7c2c519d5
dashboard link: https://syzkaller.appspot.com/bug?extid=bab151e82a4e973fa325
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=10e553e0400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com

Killed process 6527 (syz-executor2) total-vm:37704kB, anon-rss:2140kB,  
file-rss:0kB, shmem-rss:0kB
oom_reaper: reaped process 6527 (syz-executor2), now anon-rss:0kB,  
file-rss:0kB, shmem-rss:0kB
------------[ cut here ]------------
oom_reaper: reaped process 6532 (syz-executor3), now anon-rss:0kB,  
file-rss:4kB, shmem-rss:0kB
Memory cgroup charge failed because of no reclaimable memory! This looks  
like a misconfiguration or a kernel bug.
WARNING: CPU: 1 PID: 6536 at mm/memcontrol.c:1705 mem_cgroup_oom  
mm/memcontrol.c:1704 [inline]
WARNING: CPU: 1 PID: 6536 at mm/memcontrol.c:1705 try_charge+0x734/0x1680  
mm/memcontrol.c:2262
oom_reaper: reaped process 6518 (syz-executor0), now anon-rss:0kB,  
file-rss:4kB, shmem-rss:0kB
Kernel panic - not syncing: panic_on_warn set ...

CPU: 1 PID: 6536 Comm: syz-executor2 Not tainted 4.18.0-rc7-next-20180803+  
#31
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  panic+0x238/0x4e7 kernel/panic.c:184
  __warn.cold.8+0x163/0x1ba kernel/panic.c:536
  report_bug+0x252/0x2d0 lib/bug.c:186
  fixup_bug arch/x86/kernel/traps.c:178 [inline]
  do_error_trap+0x1fc/0x4d0 arch/x86/kernel/traps.c:296
  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:316
  invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:996
RIP: 0010:mem_cgroup_oom mm/memcontrol.c:1704 [inline]
RIP: 0010:try_charge+0x734/0x1680 mm/memcontrol.c:2262
Code: 85 b8 04 00 00 8b b5 c8 fd ff ff 44 89 f2 4c 89 ff e8 f0 51 ff ff 84  
c0 0f 85 31 08 00 00 48 c7 c7 60 17 13 87 e8 7c fe 85 ff <0f> 0b 48 8d 95  
f8 fd ff ff 48 8b b5 c0 fd ff ff 48 b8 00 00 00 00
RSP: 0018:ffff8801a8637620 EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff8801cbb5c980 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff816366f1 RDI: ffff8801a8637310
RBP: ffff8801a86378b0 R08: ffff8801b23001c0 R09: fffffbfff0ff11fc
R10: fffffbfff0ff11fc R11: ffffffff87f88fe3 R12: dffffc0000000000
R13: ffff8801a8637888 R14: 0000000000000000 R15: ffff8801cbb5c980
  memcg_kmem_charge_memcg+0x7c/0x120 mm/memcontrol.c:2592
  memcg_charge_slab mm/slab.h:283 [inline]
  kmem_getpages mm/slab.c:1415 [inline]
  cache_grow_begin+0x207/0x710 mm/slab.c:2677
  fallback_alloc+0x203/0x2c0 mm/slab.c:3219
  ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
  __do_cache_alloc mm/slab.c:3356 [inline]
  slab_alloc mm/slab.c:3384 [inline]
  kmem_cache_alloc+0x1e5/0x760 mm/slab.c:3552
  shmem_alloc_inode+0x1b/0x40 mm/shmem.c:3515
  alloc_inode+0x63/0x190 fs/inode.c:210
  new_inode_pseudo+0x71/0x1a0 fs/inode.c:903
  new_inode+0x1c/0x40 fs/inode.c:932
  shmem_get_inode+0xf1/0x910 mm/shmem.c:2142
  __shmem_file_setup.part.48+0x83/0x2a0 mm/shmem.c:3871
  __shmem_file_setup mm/shmem.c:3865 [inline]
  shmem_file_setup+0x65/0x90 mm/shmem.c:3912
  __do_sys_memfd_create mm/memfd.c:304 [inline]
  __se_sys_memfd_create mm/memfd.c:247 [inline]
  __x64_sys_memfd_create+0x2af/0x4f0 mm/memfd.c:247
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x456b29
Code: Bad RIP value.
RSP: 002b:00007f91f0f04a88 EFLAGS: 00000246 ORIG_RAX: 000000000000013f
RAX: ffffffffffffffda RBX: 0000000020000740 RCX: 0000000000456b29
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000004c1c8d
RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000020000740 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004d5bb8 R14: 00000000004c9491 R15: 0000000000000000
Dumping ftrace buffer:
    (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..
