Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1022A8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 04:01:07 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id m128so35562086itd.3
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 01:01:07 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id v134sor31684110itb.19.2019.01.02.01.01.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 01:01:05 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 02 Jan 2019 01:01:05 -0800
Message-ID: <000000000000d0ce25057e75e2da@google.com>
Subject: WARNING in mem_cgroup_update_lru_size
From: syzbot <syzbot+c950a368703778078dc8@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

Hello,

syzbot found the following crash on:

HEAD commit:    8e143b90e4d4 Merge tag 'iommu-updates-v4.21' of git://git...
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1250f377400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c2ab9708c613a224
dashboard link: https://syzkaller.appspot.com/bug?extid=c950a368703778078dc8
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
userspace arch: i386
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14e063fd400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+c950a368703778078dc8@syzkaller.appspotmail.com

8021q: adding VLAN 0 to HW filter on device batadv0
------------[ cut here ]------------
kasan: CONFIG_KASAN_INLINE enabled
mem_cgroup_update_lru_size(00000000e4dac0d9, 1, 1): lru_size -2032989456
kasan: GPF could be caused by NULL-ptr deref or user memory access
WARNING: CPU: 0 PID: 9560 at mm/memcontrol.c:1160  
mem_cgroup_update_lru_size+0xb2/0xe0 mm/memcontrol.c:1160
general protection fault: 0000 [#1] PREEMPT SMP KASAN
Kernel panic - not syncing: panic_on_warn set ...
CPU: 1 PID: 3 Comm:  Not tainted 4.20.0+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__read_once_size include/linux/compiler.h:191 [inline]
RIP: 0010:get_running_cputimer include/linux/sched/cputime.h:85 [inline]
RIP: 0010:account_group_system_time include/linux/sched/cputime.h:149  
[inline]
RIP: 0010:account_system_index_time+0xe8/0x5f0 kernel/sched/cputime.c:168
Code: 04 00 00 49 8b 84 24 00 07 00 00 48 ba 00 00 00 00 00 fc ff df 48 8d  
b8 40 01 00 00 48 8d 88 28 01 00 00 48 89 fe 48 c1 ee 03 <0f> b6 14 16 48  
89 fe 83 e6 07 40 38 f2 7f 08 84 d2 0f 85 93 03 00
RSP: 0018:ffff8880ae707a80 EFLAGS: 00010006
RAX: 0000000041b58ab3 RBX: 1ffff11015ce0f54 RCX: 0000000041b58bdb
RDX: dffffc0000000000 RSI: 000000000836b17e RDI: 0000000041b58bf3
RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: fffffbfff1335af5
R10: fffffbfff1301b45 R11: ffffffff899ad7a3 R12: ffff8880a94bc440
R13: 0000000000286ccf R14: 0000000000000003 R15: ffff8880ae707b20
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000008462a98 CR3: 00000000903b3000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  <IRQ>
  irqtime_account_process_tick.isra.0+0x3a2/0x490 kernel/sched/cputime.c:380
  account_process_tick+0x27f/0x350 kernel/sched/cputime.c:483
  update_process_times+0x25/0x80 kernel/time/timer.c:1633
  tick_sched_handle+0xa2/0x190 kernel/time/tick-sched.c:161
  tick_sched_timer+0x47/0x130 kernel/time/tick-sched.c:1271
  __run_hrtimer kernel/time/hrtimer.c:1389 [inline]
  __hrtimer_run_queues+0x3a7/0x1050 kernel/time/hrtimer.c:1451
  hrtimer_interrupt+0x314/0x770 kernel/time/hrtimer.c:1509
  local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1035 [inline]
  smp_apic_timer_interrupt+0x18d/0x760 arch/x86/kernel/apic/apic.c:1060
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
Modules linked in:
---[ end trace 29e64cfc002b0004 ]---
RIP: 0010:__read_once_size include/linux/compiler.h:191 [inline]
RIP: 0010:get_running_cputimer include/linux/sched/cputime.h:85 [inline]
RIP: 0010:account_group_system_time include/linux/sched/cputime.h:149  
[inline]
RIP: 0010:account_system_index_time+0xe8/0x5f0 kernel/sched/cputime.c:168
Code: 04 00 00 49 8b 84 24 00 07 00 00 48 ba 00 00 00 00 00 fc ff df 48 8d  
b8 40 01 00 00 48 8d 88 28 01 00 00 48 89 fe 48 c1 ee 03 <0f> b6 14 16 48  
89 fe 83 e6 07 40 38 f2 7f 08 84 d2 0f 85 93 03 00
RSP: 0018:ffff8880ae707a80 EFLAGS: 00010006
RAX: 0000000041b58ab3 RBX: 1ffff11015ce0f54 RCX: 0000000041b58bdb
RDX: dffffc0000000000 RSI: 000000000836b17e RDI: 0000000041b58bf3
RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: fffffbfff1335af5
R10: fffffbfff1301b45 R11: ffffffff899ad7a3 R12: ffff8880a94bc440
R13: 0000000000286ccf R14: 0000000000000003 R15: ffff8880ae707b20
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000008462a98 CR3: 00000000903b3000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Shutting down cpus with NMI
Kernel Offset: disabled
Rebooting in 86400 seconds..


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches
