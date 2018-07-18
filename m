Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18C316B0266
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 04:58:05 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id i18-v6so2866779iog.12
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 01:58:05 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id f191-v6sor1220404jaf.100.2018.07.18.01.58.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 01:58:03 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 18 Jul 2018 01:58:02 -0700
Message-ID: <0000000000009ce88d05714242a8@google.com>
Subject: INFO: task hung in generic_file_write_iter
From: syzbot <syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com

Hello,

syzbot found the following crash on:

HEAD commit:    30b06abfb92b Merge tag 'pinctrl-v4.18-3' of git://git.kern..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1240ed62400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=6d0ccc9273f0e539
dashboard link: https://syzkaller.appspot.com/bug?extid=9933e4476f365f5d5a1b
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+9933e4476f365f5d5a1b@syzkaller.appspotmail.com

IPVS: ftp: loaded support on port[0] = 21
mmap: syz-executor7 (10902) uses deprecated remap_file_pages() syscall. See  
Documentation/vm/remap_file_pages.rst.
Process accounting resumed
INFO: task syz-executor0:4538 blocked for more than 140 seconds.
       Not tainted 4.18.0-rc5+ #151
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-executor0   D18664  4538      1 0x80000004
Call Trace:
  context_switch kernel/sched/core.c:2853 [inline]
  __schedule+0x87c/0x1ed0 kernel/sched/core.c:3501
  schedule+0xfb/0x450 kernel/sched/core.c:3545
  __rwsem_down_write_failed_common+0x95d/0x1630  
kernel/locking/rwsem-xadd.c:566
  rwsem_down_write_failed+0xe/0x10 kernel/locking/rwsem-xadd.c:595
  call_rwsem_down_write_failed+0x17/0x30 arch/x86/lib/rwsem.S:117
  __down_write arch/x86/include/asm/rwsem.h:142 [inline]
  down_write+0xaa/0x130 kernel/locking/rwsem.c:72
  inode_lock include/linux/fs.h:715 [inline]
  generic_file_write_iter+0xed/0x870 mm/filemap.c:3289
  call_write_iter include/linux/fs.h:1793 [inline]
  new_sync_write fs/read_write.c:474 [inline]
  __vfs_write+0x6c6/0x9f0 fs/read_write.c:487
  __kernel_write+0x10c/0x380 fs/read_write.c:506
  do_acct_process+0x1148/0x1660 kernel/acct.c:520
  slow_acct_process kernel/acct.c:579 [inline]
  acct_process+0x5f7/0x770 kernel/acct.c:605
  do_exit+0x1ae0/0x2750 kernel/exit.c:855
  do_group_exit+0x177/0x440 kernel/exit.c:968
  get_signal+0x88e/0x1970 kernel/signal.c:2468
  do_signal+0x9c/0x21c0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e0/0x370 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x40fdba
Code: f0 e8 ce d0 04 00 48 8b 6d 00 31 c9 48 8d 54 24 68 48 8b 5c 24 38 48  
be 00 20 00 20 84 00 00 00 eb 22 48 8b bc 24 90 00 00 00 <48> 8d 57 08 48  
8b 7c 24 60 48 8d 4f 01 48 89 c3 48 8b 74 24 30 48
RSP: 002b:00007fff0597c4f8 EFLAGS: 00000246 ORIG_RAX: 000000000000003d
RAX: fffffffffffffe00 RBX: 0000000000032da8 RCX: 000000000040fdba
RDX: 0000000040000000 RSI: 00007fff0597c514 RDI: ffffffffffffffff
RBP: 0000000000000000 R08: 0000000000000001 R09: 000000000184c940
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000005
R13: 000000000000022a R14: 00007fff0597cba0 R15: 0000000000032cf4
INFO: task syz-executor4:10872 blocked for more than 140 seconds.
       Not tainted 4.18.0-rc5+ #151
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-executor4   D22192 10872   4545 0x00000004
Call Trace:
  context_switch kernel/sched/core.c:2853 [inline]
  __schedule+0x87c/0x1ed0 kernel/sched/core.c:3501
  schedule+0xfb/0x450 kernel/sched/core.c:3545
  schedule_preempt_disabled+0x10/0x20 kernel/sched/core.c:3603
  __mutex_lock_common kernel/locking/mutex.c:834 [inline]
  __mutex_lock+0xede/0x1820 kernel/locking/mutex.c:894
  mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:909
  __do_sys_acct kernel/acct.c:285 [inline]
  __se_sys_acct kernel/acct.c:273 [inline]
  __x64_sys_acct+0xba/0x1f0 kernel/acct.c:273
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455ab9
Code: e0 1f 48 89 04 24 e8 b6 6f fd ff e8 81 6a fd ff e8 5c 68 fd ff 48 8d  
05 23 cd 48 00 48 89 04 24 48 c7 44 24 08 1d 00 00 00 e8 <13> 5e fd ff 0f  
0b e8 8c 44 00 00 e9 07 f0 ff ff cc cc cc cc cc cc
RSP: 002b:00007f315a9dbc68 EFLAGS: 00000246 ORIG_RAX: 00000000000000a3
RAX: ffffffffffffffda RBX: 00007f315a9dc6d4 RCX: 0000000000455ab9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000020000280
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004bb522 R14: 00000000004c8788 R15: 0000000000000000
INFO: task syz-executor4:10927 blocked for more than 140 seconds.
       Not tainted 4.18.0-rc5+ #151
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-executor4   D23416 10927   4545 0x00000004
Call Trace:
  context_switch kernel/sched/core.c:2853 [inline]
  __schedule+0x87c/0x1ed0 kernel/sched/core.c:3501
  schedule+0xfb/0x450 kernel/sched/core.c:3545
  schedule_preempt_disabled+0x10/0x20 kernel/sched/core.c:3603
  __mutex_lock_common kernel/locking/mutex.c:834 [inline]
  __mutex_lock+0xede/0x1820 kernel/locking/mutex.c:894
  mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:909
  __do_sys_acct kernel/acct.c:285 [inline]
  __se_sys_acct kernel/acct.c:273 [inline]
  __x64_sys_acct+0xba/0x1f0 kernel/acct.c:273
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455ab9
Code: Bad RIP value.
RSP: 002b:00007f315a9bac68 EFLAGS: 00000246 ORIG_RAX: 00000000000000a3
RAX: ffffffffffffffda RBX: 00007f315a9bb6d4 RCX: 0000000000455ab9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000020000280
RBP: 000000000072bf48 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004bb522 R14: 00000000004c8788 R15: 0000000000000001
INFO: task syz-executor1:10874 blocked for more than 140 seconds.
       Not tainted 4.18.0-rc5+ #151
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-executor1   D22192 10874   4540 0x00000004
Call Trace:
  context_switch kernel/sched/core.c:2853 [inline]
  __schedule+0x87c/0x1ed0 kernel/sched/core.c:3501
  schedule+0xfb/0x450 kernel/sched/core.c:3545
  schedule_preempt_disabled+0x10/0x20 kernel/sched/core.c:3603
  __mutex_lock_common kernel/locking/mutex.c:834 [inline]
  __mutex_lock+0xede/0x1820 kernel/locking/mutex.c:894
  mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:909
  __do_sys_acct kernel/acct.c:285 [inline]
  __se_sys_acct kernel/acct.c:273 [inline]
  __x64_sys_acct+0xba/0x1f0 kernel/acct.c:273
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455ab9
Code: Bad RIP value.
RSP: 002b:00007feb44d73c68 EFLAGS: 00000246 ORIG_RAX: 00000000000000a3
RAX: ffffffffffffffda RBX: 00007feb44d746d4 RCX: 0000000000455ab9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000020000280
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004bb522 R14: 00000000004c8788 R15: 0000000000000000
INFO: task syz-executor1:10928 blocked for more than 140 seconds.
       Not tainted 4.18.0-rc5+ #151
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-executor1   D23416 10928   4540 0x00000004
Call Trace:
  context_switch kernel/sched/core.c:2853 [inline]
  __schedule+0x87c/0x1ed0 kernel/sched/core.c:3501
  schedule+0xfb/0x450 kernel/sched/core.c:3545
  schedule_preempt_disabled+0x10/0x20 kernel/sched/core.c:3603
  __mutex_lock_common kernel/locking/mutex.c:834 [inline]
  __mutex_lock+0xede/0x1820 kernel/locking/mutex.c:894
  mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:909
  __do_sys_acct kernel/acct.c:285 [inline]
  __se_sys_acct kernel/acct.c:273 [inline]
  __x64_sys_acct+0xba/0x1f0 kernel/acct.c:273
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455ab9
Code: Bad RIP value.
RSP: 002b:00007feb44d52c68 EFLAGS: 00000246 ORIG_RAX: 00000000000000a3
RAX: ffffffffffffffda RBX: 00007feb44d536d4 RCX: 0000000000455ab9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000020000280
RBP: 000000000072bf48 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004bb522 R14: 00000000004c8788 R15: 0000000000000001
INFO: task syz-executor2:10880 blocked for more than 140 seconds.
       Not tainted 4.18.0-rc5+ #151
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-executor2   D22192 10880   4541 0x00000004
Call Trace:
  context_switch kernel/sched/core.c:2853 [inline]
  __schedule+0x87c/0x1ed0 kernel/sched/core.c:3501
  schedule+0xfb/0x450 kernel/sched/core.c:3545
  schedule_preempt_disabled+0x10/0x20 kernel/sched/core.c:3603
  __mutex_lock_common kernel/locking/mutex.c:834 [inline]
  __mutex_lock+0xede/0x1820 kernel/locking/mutex.c:894
  mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:909
  __do_sys_acct kernel/acct.c:285 [inline]
  __se_sys_acct kernel/acct.c:273 [inline]
  __x64_sys_acct+0xba/0x1f0 kernel/acct.c:273
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455ab9
Code: Bad RIP value.
RSP: 002b:00007fcc59e8ac68 EFLAGS: 00000246 ORIG_RAX: 00000000000000a3
RAX: ffffffffffffffda RBX: 00007fcc59e8b6d4 RCX: 0000000000455ab9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000020000280
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004bb522 R14: 00000000004c8788 R15: 0000000000000000
INFO: task syz-executor2:10939 blocked for more than 140 seconds.
       Not tainted 4.18.0-rc5+ #151
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-executor2   D25408 10939   4541 0x00000004
Call Trace:
  context_switch kernel/sched/core.c:2853 [inline]
  __schedule+0x87c/0x1ed0 kernel/sched/core.c:3501
  schedule+0xfb/0x450 kernel/sched/core.c:3545
  schedule_preempt_disabled+0x10/0x20 kernel/sched/core.c:3603
  __mutex_lock_common kernel/locking/mutex.c:834 [inline]
  __mutex_lock+0xede/0x1820 kernel/locking/mutex.c:894
  mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:909
  __do_sys_acct kernel/acct.c:285 [inline]
  __se_sys_acct kernel/acct.c:273 [inline]
  __x64_sys_acct+0xba/0x1f0 kernel/acct.c:273
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455ab9
Code: Bad RIP value.
RSP: 002b:00007fcc59e48c68 EFLAGS: 00000246 ORIG_RAX: 00000000000000a3
RAX: ffffffffffffffda RBX: 00007fcc59e496d4 RCX: 0000000000455ab9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000020000280
RBP: 000000000072bff0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004bb522 R14: 00000000004c8788 R15: 0000000000000002

Showing all locks held in the system:
1 lock held by khungtaskd/902:
  #0: 00000000c440fc08 (rcu_read_lock){....}, at:  
debug_show_all_locks+0xd0/0x428 kernel/locking/lockdep.c:4461
2 locks held by rs:main Q:Reg/4400:
  #0: 000000007117f10a (&f->f_pos_lock){+.+.}, at: __fdget_pos+0x1bb/0x200  
fs/file.c:766
  #1: 00000000a5ecbe98 (sb_writers#6){.+.+}, at: file_start_write  
include/linux/fs.h:2737 [inline]
  #1: 00000000a5ecbe98 (sb_writers#6){.+.+}, at: vfs_write+0x452/0x560  
fs/read_write.c:548
1 lock held by rsyslogd/4402:
  #0: 00000000eb1d59fa (&f->f_pos_lock){+.+.}, at: __fdget_pos+0x1bb/0x200  
fs/file.c:766
2 locks held by getty/4492:
  #0: 00000000469be283 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000b87f84ff (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4493:
  #0: 0000000038dacc5f (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000c5ccdb2a (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4494:
  #0: 00000000e4f8deb7 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000662526e8 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4495:
  #0: 000000004075d763 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000d2e8b65d (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4496:
  #0: 000000009840c6a9 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 0000000026d8298c (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4497:
  #0: 0000000048ba6bbd (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 000000000cb89ffd (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
2 locks held by getty/4498:
  #0: 000000001cf7a97e (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000ab83fb73 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x335/0x1ce0 drivers/tty/n_tty.c:2140
3 locks held by syz-executor0/4538:
  #0: 00000000eedbf98e (&acct->lock#2){+.+.}, at: acct_get kernel/acct.c:161  
[inline]
  #0: 00000000eedbf98e (&acct->lock#2){+.+.}, at: slow_acct_process  
kernel/acct.c:577 [inline]
  #0: 00000000eedbf98e (&acct->lock#2){+.+.}, at: acct_process+0x3c2/0x770  
kernel/acct.c:605
  #1: 000000001265a882 (sb_writers#13){.+.+}, at: file_start_write_trylock  
include/linux/fs.h:2744 [inline]
  #1: 000000001265a882 (sb_writers#13){.+.+}, at:  
do_acct_process+0x133c/0x1660 kernel/acct.c:517
  #2: 00000000824eb913 (&sb->s_type->i_mutex_key#18){++++}, at: inode_lock  
include/linux/fs.h:715 [inline]
  #2: 00000000824eb913 (&sb->s_type->i_mutex_key#18){++++}, at:  
generic_file_write_iter+0xed/0x870 mm/filemap.c:3289
6 locks held by syz-executor0/10863:
1 lock held by syz-executor4/10872:
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __do_sys_acct  
kernel/acct.c:285 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __se_sys_acct  
kernel/acct.c:273 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __x64_sys_acct+0xba/0x1f0  
kernel/acct.c:273
1 lock held by syz-executor4/10927:
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __do_sys_acct  
kernel/acct.c:285 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __se_sys_acct  
kernel/acct.c:273 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __x64_sys_acct+0xba/0x1f0  
kernel/acct.c:273
1 lock held by syz-executor1/10874:
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __do_sys_acct  
kernel/acct.c:285 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __se_sys_acct  
kernel/acct.c:273 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __x64_sys_acct+0xba/0x1f0  
kernel/acct.c:273
1 lock held by syz-executor1/10928:
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __do_sys_acct  
kernel/acct.c:285 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __se_sys_acct  
kernel/acct.c:273 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __x64_sys_acct+0xba/0x1f0  
kernel/acct.c:273
1 lock held by syz-executor2/10880:
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __do_sys_acct  
kernel/acct.c:285 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __se_sys_acct  
kernel/acct.c:273 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __x64_sys_acct+0xba/0x1f0  
kernel/acct.c:273
1 lock held by syz-executor2/10939:
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __do_sys_acct  
kernel/acct.c:285 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __se_sys_acct  
kernel/acct.c:273 [inline]
  #0: 00000000a79969e4 (acct_on_mutex){+.+.}, at: __x64_sys_acct+0xba/0x1f0  
kernel/acct.c:273

=============================================

NMI backtrace for cpu 0
CPU: 0 PID: 902 Comm: khungtaskd Not tainted 4.18.0-rc5+ #151
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  nmi_cpu_backtrace.cold.4+0x19/0xce lib/nmi_backtrace.c:103
  nmi_trigger_cpumask_backtrace+0x151/0x192 lib/nmi_backtrace.c:62
  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
  trigger_all_cpu_backtrace include/linux/nmi.h:138 [inline]
  check_hung_uninterruptible_tasks kernel/hung_task.c:196 [inline]
  watchdog+0x9c4/0xf80 kernel/hung_task.c:252
  kthread+0x345/0x410 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:412
Sending NMI from CPU 0 to CPUs 1:
NMI backtrace for cpu 1
CPU: 1 PID: 10863 Comm: syz-executor0 Not tainted 4.18.0-rc5+ #151
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__sanitizer_cov_trace_pc+0x3f/0x50 kernel/kcov.c:106
Code: e2 00 01 1f 00 48 8b 75 08 75 2b 8b 90 90 12 00 00 83 fa 02 75 20 48  
8b 88 98 12 00 00 8b 80 94 12 00 00 48 8b 11 48 83 c2 01 <48> 39 d0 76 07  
48 89 34 d1 48 89 11 5d c3 0f 1f 00 55 40 0f b6 d6
RSP: 0018:ffff8801913be760 EFLAGS: 00000216
RAX: 0000000000040000 RBX: ffff88018e06b348 RCX: ffffc90001e34000
RDX: 0000000000040000 RSI: ffffffff81d44df2 RDI: 0000000000000007
RBP: ffff8801913be760 R08: ffff8801b465c540 R09: ffffed003b5e46d6
R10: 0000000000000003 R11: 0000000000000006 R12: dffffc0000000000
R13: 0000000000000042 R14: 0000000000000001 R15: 0000000000000020
FS:  00007f53ece9c700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000119f218 CR3: 00000001ba743000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  init_page_buffers+0x3e2/0x530 fs/buffer.c:904
  grow_dev_page fs/buffer.c:947 [inline]
  grow_buffers fs/buffer.c:1009 [inline]
  __getblk_slow fs/buffer.c:1036 [inline]
  __getblk_gfp+0x906/0xb10 fs/buffer.c:1313
  __bread_gfp+0x2d/0x310 fs/buffer.c:1347
  sb_bread include/linux/buffer_head.h:307 [inline]
  fat12_ent_bread+0x14e/0x3d0 fs/fat/fatent.c:75
  fat_ent_read_block fs/fat/fatent.c:441 [inline]
  fat_alloc_clusters+0x8ce/0x16e0 fs/fat/fatent.c:489
  fat_add_cluster+0x7a/0x150 fs/fat/inode.c:101
  __fat_get_block fs/fat/inode.c:148 [inline]
  fat_get_block+0x375/0xaf0 fs/fat/inode.c:183
  __block_write_begin_int+0x50d/0x1b00 fs/buffer.c:1958
  __block_write_begin fs/buffer.c:2008 [inline]
  block_write_begin+0xda/0x370 fs/buffer.c:2067
  cont_write_begin+0x569/0x860 fs/buffer.c:2417
  fat_write_begin+0x8d/0x120 fs/fat/inode.c:229
  generic_perform_write+0x3ae/0x6c0 mm/filemap.c:3139
  __generic_file_write_iter+0x26e/0x630 mm/filemap.c:3264
  generic_file_write_iter+0x438/0x870 mm/filemap.c:3292
  call_write_iter include/linux/fs.h:1793 [inline]
  new_sync_write fs/read_write.c:474 [inline]
  __vfs_write+0x6c6/0x9f0 fs/read_write.c:487
  __kernel_write+0x10c/0x380 fs/read_write.c:506
  do_acct_process+0x1148/0x1660 kernel/acct.c:520
  acct_pin_kill+0x2e/0x100 kernel/acct.c:174
  pin_kill+0x29f/0xb60 fs/fs_pin.c:50
  acct_on+0x63b/0x8b0 kernel/acct.c:254
  __do_sys_acct kernel/acct.c:286 [inline]
  __se_sys_acct kernel/acct.c:273 [inline]
  __x64_sys_acct+0xc2/0x1f0 kernel/acct.c:273
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x455ab9
Code: 1d ba fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 eb b9 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f53ece9bc68 EFLAGS: 00000246 ORIG_RAX: 00000000000000a3
RAX: ffffffffffffffda RBX: 00007f53ece9c6d4 RCX: 0000000000455ab9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000020000280
RBP: 000000000072bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004bb522 R14: 00000000004c8788 R15: 0000000000000000
INFO: NMI handler (nmi_cpu_backtrace_handler) took too long to run: 1.663  
msecs


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
