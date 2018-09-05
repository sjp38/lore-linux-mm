Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 867316B71DE
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 03:13:04 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m13-v6so6108188ioq.9
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 00:13:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id u21-v6sor380240iof.177.2018.09.05.00.13.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 00:13:02 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 05 Sep 2018 00:13:02 -0700
Message-ID: <0000000000004f6b5805751a8189@google.com>
Subject: linux-next test error
From: syzbot <syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org

Hello,

syzbot found the following crash on:

HEAD commit:    387ac6229ecf Add linux-next specific files for 20180905
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=149c67a6400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=ad5163873ecfbc32
dashboard link: https://syzkaller.appspot.com/bug?extid=87a05ae4accd500f5242
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com

INFO: task hung in do_page_mkwriteINFO: task syz-fuzzer:4876 blocked for  
more than 140 seconds.
       Not tainted 4.19.0-rc2-next-20180905+ #56
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-fuzzer      D21704  4876   4871 0x00000000
Call Trace:
  context_switch kernel/sched/core.c:2825 [inline]
  __schedule+0x87c/0x1df0 kernel/sched/core.c:3473
  schedule+0xfb/0x450 kernel/sched/core.c:3517
  io_schedule+0x1c/0x70 kernel/sched/core.c:5140
  wait_on_page_bit_common mm/filemap.c:1100 [inline]
  __lock_page+0x5b7/0x7a0 mm/filemap.c:1273
  lock_page include/linux/pagemap.h:483 [inline]
  do_page_mkwrite+0x429/0x520 mm/memory.c:2391
  do_shared_fault mm/memory.c:3717 [inline]
  do_fault mm/memory.c:3756 [inline]
  handle_pte_fault mm/memory.c:3983 [inline]
  __handle_mm_fault+0x2a0a/0x4350 mm/memory.c:4107
  handle_mm_fault+0x53e/0xc80 mm/memory.c:4144
  __do_page_fault+0x620/0xe50 arch/x86/mm/fault.c:1395
  do_page_fault+0xf6/0x7a4 arch/x86/mm/fault.c:1470
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1164
RIP: 0033:0x70b591
Code: 48 89 6c 24 10 48 8d 6c 24 10 48 8b 44 24 20 48 8b 48 08 48 8b 50 10  
48 8d 58 08 48 83 fa 08 0f 8c 1e 01 00 00 48 8b 54 24 28 <88> 11 48 8b 48  
08 48 8b 70 10 48 83 fe 01 0f 86 44 01 00 00 48 89
RSP: 002b:000000c42010f3f0 EFLAGS: 00010212
RAX: 000000c42010f508 RBX: 000000c42010f510 RCX: 00007f9d22c27000
RDX: 0000000000000537 RSI: 000000000072a470 RDI: 000000c42010f348
RBP: 000000c42010f400 R08: 0000000000000000 R09: 0000000000000000
R10: 00000000009496ca R11: 0000000000000004 R12: 0000000000000000
R13: 0000000000000020 R14: 0000000000000013 R15: 000000000000000f

Showing all locks held in the system:
4 locks held by kworker/u4:1/22:
  #0: 000000005bc28536 ((wq_completion)"writeback"){+.+.}, at:  
__write_once_size include/linux/compiler.h:215 [inline]
  #0: 000000005bc28536 ((wq_completion)"writeback"){+.+.}, at:  
arch_atomic64_set arch/x86/include/asm/atomic64_64.h:34 [inline]
  #0: 000000005bc28536 ((wq_completion)"writeback"){+.+.}, at: atomic64_set  
include/asm-generic/atomic-instrumented.h:40 [inline]
  #0: 000000005bc28536 ((wq_completion)"writeback"){+.+.}, at:  
atomic_long_set include/asm-generic/atomic-long.h:59 [inline]
  #0: 000000005bc28536 ((wq_completion)"writeback"){+.+.}, at: set_work_data  
kernel/workqueue.c:617 [inline]
  #0: 000000005bc28536 ((wq_completion)"writeback"){+.+.}, at:  
set_work_pool_and_clear_pending kernel/workqueue.c:644 [inline]
  #0: 000000005bc28536 ((wq_completion)"writeback"){+.+.}, at:  
process_one_work+0xb44/0x1aa0 kernel/workqueue.c:2124
  #1: 000000007193e1ae ((work_completion)(&(&wb->dwork)->work)){+.+.}, at:  
process_one_work+0xb9b/0x1aa0 kernel/workqueue.c:2128
  #2: 0000000079a3ee6d (&fc->fs_type->s_umount_key#29){++++}, at:  
trylock_super+0x22/0x110 fs/super.c:411
  #3: 00000000f58a212d (&sbi->s_journal_flag_rwsem){.+.+}, at:  
do_writepages+0x9a/0x1a0 mm/page-writeback.c:2340
1 lock held by khungtaskd/793:
  #0: 0000000020ca7c68 (rcu_read_lock){....}, at:  
debug_show_all_locks+0xd0/0x428 kernel/locking/lockdep.c:4436
1 lock held by khugepaged/799:
  #0: 00000000af3da9ce (&mm->mmap_sem){++++}, at:  
collapse_huge_page+0x2bf/0x2250 mm/khugepaged.c:1007
1 lock held by rsyslogd/4761:
  #0: 00000000a67fe71d (&f->f_pos_lock){+.+.}, at: __fdget_pos+0x1bb/0x200  
fs/file.c:766
2 locks held by getty/4851:
  #0: 00000000236449d0 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:353
  #1: 000000004a997762 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4852:
  #0: 00000000d68d1a08 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:353
  #1: 00000000f062cc2f (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4853:
  #0: 00000000507cd5fe (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:353
  #1: 00000000fa59d11e (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4854:
  #0: 00000000de7b4c24 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:353
  #1: 00000000e3caa2a6 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4855:
  #0: 00000000e5b05f9f (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:353
  #1: 0000000002e17b37 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4856:
  #0: 00000000831fbb62 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:353
  #1: 000000009838e2ef (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4857:
  #0: 000000003038a645 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:353
  #1: 00000000c1269869 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
1 lock held by syz-fuzzer/4876:
  #0: 00000000af3da9ce (&mm->mmap_sem){++++}, at:  
__do_page_fault+0x389/0xe50 arch/x86/mm/fault.c:1324

=============================================

NMI backtrace for cpu 0
CPU: 0 PID: 793 Comm: khungtaskd Not tainted 4.19.0-rc2-next-20180905+ #56
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  nmi_cpu_backtrace.cold.4+0x48/0x88 lib/nmi_backtrace.c:101
  nmi_trigger_cpumask_backtrace+0x1b6/0x1cd lib/nmi_backtrace.c:62
  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
  trigger_all_cpu_backtrace include/linux/nmi.h:144 [inline]
  check_hung_uninterruptible_tasks kernel/hung_task.c:204 [inline]
  watchdog+0xb39/0x1040 kernel/hung_task.c:265
  kthread+0x35a/0x420 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:415
Sending NMI from CPU 0 to CPUs 1:
NMI backtrace for cpu 1
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.19.0-rc2-next-20180905+ #56
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__read_once_size include/linux/compiler.h:188 [inline]
RIP: 0010:check_kcov_mode kernel/kcov.c:69 [inline]
RIP: 0010:write_comp_data+0x22/0x70 kernel/kcov.c:122
Code: e4 b9 ca ff 90 90 90 90 55 65 4c 8b 04 25 40 ee 01 00 65 8b 05 2f 44  
86 7e 48 89 e5 a9 00 01 1f 00 75 51 41 8b 80 88 12 00 00 <83> f8 03 75 45  
49 8b 80 90 12 00 00 45 8b 80 8c 12 00 00 4c 8b 08
RSP: 0018:ffff8801d9f1fb10 EFLAGS: 00000046
RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffffffff816df180
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff8801d9f1fb10 R08: ffff8801d9f0e380 R09: 0000000000000000
R10: 0000000000000003 R11: 0000000000000000 R12: ffff8801d9f1fb80
R13: 0000000000021f3e R14: 0000002b4d7800be R15: 00000000fffe3d07
FS:  0000000000000000(0000) GS:ffff8801db100000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffffff600400 CR3: 00000001b91c2000 CR4: 00000000001406e0
Call Trace:
  __sanitizer_cov_trace_const_cmp1+0x1a/0x20 kernel/kcov.c:174
  tick_nohz_next_event+0x5e0/0x8a0 kernel/time/tick-sched.c:672
  __tick_nohz_idle_stop_tick kernel/time/tick-sched.c:930 [inline]
  tick_nohz_idle_stop_tick+0x633/0xcb0 kernel/time/tick-sched.c:960
  cpuidle_idle_call kernel/sched/idle.c:150 [inline]
  do_idle+0x3a0/0x580 kernel/sched/idle.c:262
  cpu_startup_entry+0x10c/0x120 kernel/sched/idle.c:368
  start_secondary+0x433/0x5d0 arch/x86/kernel/smpboot.c:271
  secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:242


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
