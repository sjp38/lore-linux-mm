Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1DAB86B0266
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:42:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id w132-v6so13259989ita.6
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:42:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id d68-v6sor3815131iog.91.2018.08.06.08.42.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 08:42:02 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 06 Aug 2018 08:42:02 -0700
In-Reply-To: <fc6e173e-8bda-269f-d44f-1c5f5215beac@I-love.SAKURA.ne.jp>
Message-ID: <0000000000006350880572c61e62@google.com>
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

Killed process 6410 (syz-executor5) total-vm:37708kB, anon-rss:2128kB,  
file-rss:0kB, shmem-rss:0kB
oom_reaper: reaped process 6410 (syz-executor5), now anon-rss:0kB,  
file-rss:0kB, shmem-rss:0kB
task=syz-executor5 pid=6410 invoked memcg oom killer. oom_victim=1
------------[ cut here ]------------
Memory cgroup charge failed because of no reclaimable memory! This looks  
like a misconfiguration or a kernel bug.
WARNING: CPU: 1 PID: 6410 at mm/memcontrol.c:1707 mem_cgroup_oom  
mm/memcontrol.c:1706 [inline]
WARNING: CPU: 1 PID: 6410 at mm/memcontrol.c:1707 try_charge+0x734/0x1680  
mm/memcontrol.c:2264
Kernel panic - not syncing: panic_on_warn set ...

CPU: 1 PID: 6410 Comm: syz-executor5 Not tainted 4.18.0-rc7-next-20180803+  
#1
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
RIP: 0010:mem_cgroup_oom mm/memcontrol.c:1706 [inline]
RIP: 0010:try_charge+0x734/0x1680 mm/memcontrol.c:2264
Code: 85 b8 04 00 00 8b b5 c8 fd ff ff 44 89 f2 4c 89 ff e8 00 51 ff ff 84  
c0 0f 85 31 08 00 00 48 c7 c7 c0 17 13 87 e8 8c fd 85 ff <0f> 0b 48 8d 95  
f8 fd ff ff 48 8b b5 c0 fd ff ff 48 b8 00 00 00 00
RSP: 0018:ffff8801be6ef580 EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff8801afab4c00 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff816366f1 RDI: ffff8801be6ef270
RBP: ffff8801be6ef810 R08: ffff8801bcf48140 R09: fffffbfff0ff1238
R10: fffffbfff0ff1238 R11: ffffffff87f891c3 R12: dffffc0000000000
R13: ffff8801be6ef7e8 R14: 0000000000000000 R15: ffff8801afab4c00
  mem_cgroup_try_charge+0x4ff/0xa70 mm/memcontrol.c:5916
  mem_cgroup_try_charge_delay+0x1d/0x90 mm/memcontrol.c:5931
  do_anonymous_page mm/memory.c:3166 [inline]
  handle_pte_fault mm/memory.c:3971 [inline]
  __handle_mm_fault+0x25be/0x4470 mm/memory.c:4097
  handle_mm_fault+0x53e/0xc80 mm/memory.c:4134
  __do_page_fault+0x620/0xe50 arch/x86/mm/fault.c:1395
  do_page_fault+0xf6/0x8c0 arch/x86/mm/fault.c:1470
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1164
RIP: 0033:0x40e33f
Code: Bad RIP value.
RSP: 002b:00007ffe221246e0 EFLAGS: 00010206
RAX: 00007fb83d11b000 RBX: 0000000000020000 RCX: 0000000000456b7a
RDX: 0000000000021000 RSI: 0000000000021000 RDI: 0000000000000000
RBP: 00007ffe221247c0 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffe221248b0
R13: 00007fb83d13b700 R14: 0000000000000005 R15: 0000000000000001
Dumping ftrace buffer:
    (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..


Tested on:

commit:         116b181bb646 Add linux-next specific files for 20180803
git tree:        
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
console output: https://syzkaller.appspot.com/x/log.txt?x=12447864400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=b4f38be7c2c519d5
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
patch:          https://syzkaller.appspot.com/x/patch.diff?x=14c5b68c400000
