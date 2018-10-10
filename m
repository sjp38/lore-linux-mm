Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B61E76B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:08:05 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id f5-v6so2986085ioq.17
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:08:05 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 185-v6sor9811266ito.34.2018.10.09.17.08.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 17:08:03 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 09 Oct 2018 17:08:02 -0700
Message-ID: <000000000000dc48d40577d4a587@google.com>
Subject: INFO: rcu detected stall in shmem_fault
From: syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, guro@fb.com, hannes@cmpxchg.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, penguin-kernel@i-love.sakura.ne.jp, rientjes@google.com, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com

Hello,

syzbot found the following crash on:

HEAD commit:    570b7bdeaf18 Add linux-next specific files for 20181009
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=13eeb685400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=9b5a60e1381390c4
dashboard link: https://syzkaller.appspot.com/bug?extid=77e6b28a7a7106ad0def
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com

RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
rcu: INFO: rcu_preempt self-detected stall on CPU
rcu: 	0-....: (1 GPs behind) idle=cb6/1/0x4000000000000002  
softirq=64368/64369 fqs=750
rcu: 	 (t=10505 jiffies g=81341 q=1698)
NMI backtrace for cpu 0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  nmi_cpu_backtrace.cold.2+0x5c/0xa1 lib/nmi_backtrace.c:101
  nmi_trigger_cpumask_backtrace+0x1e8/0x22a lib/nmi_backtrace.c:62
  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
  trigger_single_cpu_backtrace include/linux/nmi.h:162 [inline]
  rcu_dump_cpu_stacks+0x16f/0x1bc kernel/rcu/tree.c:1195
  print_cpu_stall.cold.67+0x1f3/0x3c7 kernel/rcu/tree.c:1334
  check_cpu_stall kernel/rcu/tree.c:1408 [inline]
  rcu_pending kernel/rcu/tree.c:2961 [inline]
  rcu_check_callbacks+0xf38/0x13f0 kernel/rcu/tree.c:2506
  update_process_times+0x2d/0x70 kernel/time/timer.c:1636
  tick_sched_handle+0x9f/0x180 kernel/time/tick-sched.c:164
  tick_sched_timer+0x45/0x130 kernel/time/tick-sched.c:1274
  __run_hrtimer kernel/time/hrtimer.c:1398 [inline]
  __hrtimer_run_queues+0x412/0x10c0 kernel/time/hrtimer.c:1460
  hrtimer_interrupt+0x313/0x780 kernel/time/hrtimer.c:1518
  local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1034 [inline]
  smp_apic_timer_interrupt+0x1a1/0x750 arch/x86/kernel/apic/apic.c:1059
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:804
  </IRQ>
RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:761  
[inline]
RIP: 0010:dump_stack+0x358/0x3ab lib/dump_stack.c:118
Code: 74 0c 48 c7 c7 f0 f5 31 89 e8 9f 0e 0e fa 48 83 3d 07 15 7d 01 00 0f  
84 63 fe ff ff e8 1c 89 c9 f9 48 8b bd 70 ff ff ff 57 9d <0f> 1f 44 00 00  
e8 09 89 c9 f9 48 8b 8d 68 ff ff ff b8 ff ff 37 00
RSP: 0018:ffff88017d3a5c70 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
RAX: 0000000000040000 RBX: 1ffffffff1263ebe RCX: ffffc90001e5a000
RDX: 0000000000040000 RSI: ffffffff87b4e0f4 RDI: 0000000000000246
RBP: ffff88017d3a5d18 R08: ffff8801d7e02480 R09: fffffbfff13da030
R10: fffffbfff13da030 R11: 0000000000000003 R12: 1ffff1002fa74b96
R13: 00000000ffffffff R14: 0000000000000200 R15: 0000000000000000
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
  shmem_fault+0x25f/0x960 mm/shmem.c:1982
  __do_fault+0x100/0x6b0 mm/memory.c:2996
  do_read_fault mm/memory.c:3408 [inline]
  do_fault mm/memory.c:3531 [inline]
  handle_pte_fault mm/memory.c:3762 [inline]
  __handle_mm_fault+0x3d40/0x5a40 mm/memory.c:3886
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3923
  faultin_page mm/gup.c:518 [inline]
  __get_user_pages+0x806/0x1b30 mm/gup.c:718
  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
  __mm_populate+0x286/0x4d0 mm/gup.c:1270
  mm_populate include/linux/mm.h:2311 [inline]
  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
  ksys_mmap_pgoff+0xf1/0x660 mm/mmap.c:1606
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f9315bfbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
Memory limit reached of cgroup /syz0
memory: usage 205164kB, limit 204800kB, failcnt 6901
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB  
shmem:740KB mapped_file:660KB dirty:0KB writeback:0KB swap:0KB  
inactive_anon:708KB active_anon:176448KB inactive_file:4KB active_file:0KB  
unevictable:0KB
Out of memory and no killable processes...
syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
  shmem_fault+0x25f/0x960 mm/shmem.c:1982
  __do_fault+0x100/0x6b0 mm/memory.c:2996
  do_read_fault mm/memory.c:3408 [inline]
  do_fault mm/memory.c:3531 [inline]
  handle_pte_fault mm/memory.c:3762 [inline]
  __handle_mm_fault+0x3d40/0x5a40 mm/memory.c:3886
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3923
  faultin_page mm/gup.c:518 [inline]
  __get_user_pages+0x806/0x1b30 mm/gup.c:718
  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
  __mm_populate+0x286/0x4d0 mm/gup.c:1270
  mm_populate include/linux/mm.h:2311 [inline]
  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
  ksys_mmap_pgoff+0xf1/0x660 mm/mmap.c:1606
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f9315bfbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
Memory limit reached of cgroup /syz0
memory: usage 205168kB, limit 204800kB, failcnt 6909
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB  
shmem:740KB mapped_file:660KB dirty:0KB writeback:0KB swap:0KB  
inactive_anon:712KB active_anon:176448KB inactive_file:0KB active_file:4KB  
unevictable:0KB
Out of memory and no killable processes...
syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
  shmem_fault+0x25f/0x960 mm/shmem.c:1982
  __do_fault+0x100/0x6b0 mm/memory.c:2996
  do_read_fault mm/memory.c:3408 [inline]
  do_fault mm/memory.c:3531 [inline]
  handle_pte_fault mm/memory.c:3762 [inline]
  __handle_mm_fault+0x3d40/0x5a40 mm/memory.c:3886
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3923
  faultin_page mm/gup.c:518 [inline]
  __get_user_pages+0x806/0x1b30 mm/gup.c:718
  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
  __mm_populate+0x286/0x4d0 mm/gup.c:1270
  mm_populate include/linux/mm.h:2311 [inline]
  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
  ksys_mmap_pgoff+0xf1/0x660 mm/mmap.c:1606
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f9315bfbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
Memory limit reached of cgroup /syz0
memory: usage 205172kB, limit 204800kB, failcnt 6917
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB  
shmem:740KB mapped_file:792KB dirty:0KB writeback:0KB swap:0KB  
inactive_anon:716KB active_anon:176448KB inactive_file:4KB active_file:0KB  
unevictable:0KB
Out of memory and no killable processes...
syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
  shmem_fault+0x25f/0x960 mm/shmem.c:1982
  __do_fault+0x100/0x6b0 mm/memory.c:2996
  do_read_fault mm/memory.c:3408 [inline]
  do_fault mm/memory.c:3531 [inline]
  handle_pte_fault mm/memory.c:3762 [inline]
  __handle_mm_fault+0x3d40/0x5a40 mm/memory.c:3886
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3923
  faultin_page mm/gup.c:518 [inline]
  __get_user_pages+0x806/0x1b30 mm/gup.c:718
  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
  __mm_populate+0x286/0x4d0 mm/gup.c:1270
  mm_populate include/linux/mm.h:2311 [inline]
  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
  ksys_mmap_pgoff+0xf1/0x660 mm/mmap.c:1606
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f9315bfbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
Memory limit reached of cgroup /syz0
memory: usage 205176kB, limit 204800kB, failcnt 6925
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB  
shmem:740KB mapped_file:792KB dirty:0KB writeback:0KB swap:0KB  
inactive_anon:720KB active_anon:176448KB inactive_file:0KB active_file:4KB  
unevictable:0KB
Out of memory and no killable processes...
syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
  shmem_fault+0x25f/0x960 mm/shmem.c:1982
  __do_fault+0x100/0x6b0 mm/memory.c:2996
  do_read_fault mm/memory.c:3408 [inline]
  do_fault mm/memory.c:3531 [inline]
  handle_pte_fault mm/memory.c:3762 [inline]
  __handle_mm_fault+0x3d40/0x5a40 mm/memory.c:3886
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3923
  faultin_page mm/gup.c:518 [inline]
  __get_user_pages+0x806/0x1b30 mm/gup.c:718
  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
  __mm_populate+0x286/0x4d0 mm/gup.c:1270
  mm_populate include/linux/mm.h:2311 [inline]
  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
  ksys_mmap_pgoff+0xf1/0x660 mm/mmap.c:1606
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f9315bfbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
Memory limit reached of cgroup /syz0
memory: usage 205180kB, limit 204800kB, failcnt 6933
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB  
shmem:740KB mapped_file:792KB dirty:0KB writeback:0KB swap:0KB  
inactive_anon:724KB active_anon:176448KB inactive_file:4KB active_file:0KB  
unevictable:0KB
Out of memory and no killable processes...
syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
  shmem_fault+0x25f/0x960 mm/shmem.c:1982
  __do_fault+0x100/0x6b0 mm/memory.c:2996
  do_read_fault mm/memory.c:3408 [inline]
  do_fault mm/memory.c:3531 [inline]
  handle_pte_fault mm/memory.c:3762 [inline]
  __handle_mm_fault+0x3d40/0x5a40 mm/memory.c:3886
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3923
  faultin_page mm/gup.c:518 [inline]
  __get_user_pages+0x806/0x1b30 mm/gup.c:718
  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
  __mm_populate+0x286/0x4d0 mm/gup.c:1270
  mm_populate include/linux/mm.h:2311 [inline]
  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
  ksys_mmap_pgoff+0xf1/0x660 mm/mmap.c:1606
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f9315bfbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
Memory limit reached of cgroup /syz0
memory: usage 205184kB, limit 204800kB, failcnt 6941
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB  
shmem:740KB mapped_file:792KB dirty:0KB writeback:0KB swap:0KB  
inactive_anon:728KB active_anon:176448KB inactive_file:0KB active_file:4KB  
unevictable:0KB
Out of memory and no killable processes...
syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
  shmem_fault+0x25f/0x960 mm/shmem.c:1982
  __do_fault+0x100/0x6b0 mm/memory.c:2996
  do_read_fault mm/memory.c:3408 [inline]
  do_fault mm/memory.c:3531 [inline]
  handle_pte_fault mm/memory.c:3762 [inline]
  __handle_mm_fault+0x3d40/0x5a40 mm/memory.c:3886
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3923
  faultin_page mm/gup.c:518 [inline]
  __get_user_pages+0x806/0x1b30 mm/gup.c:718
  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
  __mm_populate+0x286/0x4d0 mm/gup.c:1270
  mm_populate include/linux/mm.h:2311 [inline]
  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
  ksys_mmap_pgoff+0xf1/0x660 mm/mmap.c:1606
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f9315bfbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
Memory limit reached of cgroup /syz0
memory: usage 205188kB, limit 204800kB, failcnt 6949
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB  
shmem:740KB mapped_file:792KB dirty:0KB writeback:0KB swap:0KB  
inactive_anon:732KB active_anon:176448KB inactive_file:4KB active_file:0KB  
unevictable:0KB
Out of memory and no killable processes...
syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
  shmem_fault+0x25f/0x960 mm/shmem.c:1982
  __do_fault+0x100/0x6b0 mm/memory.c:2996
  do_read_fault mm/memory.c:3408 [inline]
  do_fault mm/memory.c:3531 [inline]
  handle_pte_fault mm/memory.c:3762 [inline]
  __handle_mm_fault+0x3d40/0x5a40 mm/memory.c:3886
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3923
  faultin_page mm/gup.c:518 [inline]
  __get_user_pages+0x806/0x1b30 mm/gup.c:718
  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
  __mm_populate+0x286/0x4d0 mm/gup.c:1270
  mm_populate include/linux/mm.h:2311 [inline]
  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
  ksys_mmap_pgoff+0xf1/0x660 mm/mmap.c:1606
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f9315bfbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
Memory limit reached of cgroup /syz0
memory: usage 205192kB, limit 204800kB, failcnt 6957
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB  
shmem:740KB mapped_file:792KB dirty:0KB writeback:0KB swap:0KB  
inactive_anon:736KB active_anon:176448KB inactive_file:0KB active_file:4KB  
unevictable:0KB
Out of memory and no killable processes...
syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784
  shmem_fault+0x25f/0x960 mm/shmem.c:1982
  __do_fault+0x100/0x6b0 mm/memory.c:2996
  do_read_fault mm/memory.c:3408 [inline]
  do_fault mm/memory.c:3531 [inline]
  handle_pte_fault mm/memory.c:3762 [inline]
  __handle_mm_fault+0x3d40/0x5a40 mm/memory.c:3886
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3923
  faultin_page mm/gup.c:518 [inline]
  __get_user_pages+0x806/0x1b30 mm/gup.c:718
  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
  __mm_populate+0x286/0x4d0 mm/gup.c:1270
  mm_populate include/linux/mm.h:2311 [inline]
  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
  ksys_mmap_pgoff+0xf1/0x660 mm/mmap.c:1606
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 1d b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f9315bfbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000457579
RDX: 0000000000000002 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 000000000072bf00 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000246 R12: 00007f9315bfc6d4
R13: 00000000004c284a R14: 00000000004d3bd0 R15: 00000000ffffffff
Memory limit reached of cgroup /syz0
memory: usage 205196kB, limit 204800kB, failcnt 6965
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB  
shmem:740KB mapped_file:792KB dirty:0KB writeback:0KB swap:0KB  
inactive_anon:740KB active_anon:176448KB inactive_file:4KB active_file:0KB  
unevictable:0KB
Out of memory and no killable processes...
syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+  
#90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x3ab lib/dump_stack.c:113
  dump_header+0x27b/0xf72 mm/oom_kill.c:441
  out_of_memory.cold.30+0xf/0x184 mm/oom_kill.c:1109
  mem_cgroup_out_of_memory+0x15e/0x210 mm/memcontrol.c:1386
  mem_cgroup_oom mm/memcontrol.c:1701 [inline]
  try_charge+0xb7c/0x1710 mm/memcontrol.c:2260
  mem_cgroup_try_charge+0x627/0xe20 mm/memcontrol.c:5892
  mem_cgroup_try_charge_delay+0x1d/0xa0 mm/memcontrol.c:5907
  shmem_getpage_gfp+0x186b/0x4840 mm/shmem.c:1784


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
