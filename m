Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDCF48E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 12:16:04 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id r65so17524593iod.12
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:16:04 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id d195sor7814923iog.23.2018.12.12.09.16.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 09:16:03 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 12 Dec 2018 09:16:03 -0800
Message-ID: <0000000000004a25cc057cd65aad@google.com>
Subject: INFO: rcu detected stall in sys_mount (2)
From: syzbot <syzbot+5751b57c82cd229ffbee@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, amir73il@gmail.com, darrick.wong@oracle.com, david@fromorbit.com, hannes@cmpxchg.org, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, willy@infradead.org

Hello,

syzbot found the following crash on:

HEAD commit:    f5d582777bcb Merge branch 'for-linus' of git://git.kernel...
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=149f8ba3400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c8970c89a0efbb23
dashboard link: https://syzkaller.appspot.com/bug?extid=5751b57c82cd229ffbee
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+5751b57c82cd229ffbee@syzkaller.appspotmail.com

audit: type=1800 audit(2000000150.760:153): pid=30410 uid=0 auid=4294967295  
ses=4294967295 subj=_ op=collect_data cause=failed comm="syz-executor1"  
name="bus" dev="sda1" ino=16548 res=0
ip6_tunnel: ip6tnl1 xmit: Local address not yet configured!
ip6_tunnel: 6tnl0 xmit: Local address not yet configured!
rcu: INFO: rcu_preempt self-detected stall on CPU
rcu: 	0-....: (1 GPs behind) idle=512/1/0x4000000000000002  
softirq=146256/146258 fqs=5248
rcu: 	 (t=10501 jiffies g=205577 q=1497)
NMI backtrace for cpu 0
CPU: 0 PID: 30404 Comm: syz-executor0 Not tainted 4.20.0-rc6+ #150
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  <IRQ>
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x39d lib/dump_stack.c:113
  nmi_cpu_backtrace.cold.2+0x5c/0xa1 lib/nmi_backtrace.c:101
  nmi_trigger_cpumask_backtrace+0x1e8/0x22a lib/nmi_backtrace.c:62
  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
  trigger_single_cpu_backtrace include/linux/nmi.h:164 [inline]
  rcu_dump_cpu_stacks+0x16f/0x1bc kernel/rcu/tree.c:1195
  print_cpu_stall.cold.67+0x1f3/0x3c7 kernel/rcu/tree.c:1334
  check_cpu_stall kernel/rcu/tree.c:1408 [inline]
  rcu_pending kernel/rcu/tree.c:2961 [inline]
  rcu_check_callbacks+0xf3b/0x13f0 kernel/rcu/tree.c:2506
  update_process_times+0x2d/0x70 kernel/time/timer.c:1636
  tick_sched_handle+0x9f/0x180 kernel/time/tick-sched.c:164
  tick_sched_timer+0x45/0x130 kernel/time/tick-sched.c:1274
  __run_hrtimer kernel/time/hrtimer.c:1398 [inline]
  __hrtimer_run_queues+0x41c/0x10d0 kernel/time/hrtimer.c:1460
  hrtimer_interrupt+0x313/0x780 kernel/time/hrtimer.c:1518
  local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1034 [inline]
  smp_apic_timer_interrupt+0x1a1/0x760 arch/x86/kernel/apic/apic.c:1059
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
RIP: 0010:preempt_count arch/x86/include/asm/preempt.h:23 [inline]
RIP: 0010:preempt_count_sub+0x49/0x150 kernel/sched/core.c:3217
Code: 0f b6 14 02 48 89 f8 83 e0 07 83 c0 03 38 d0 7c 08 84 d2 0f 85 f9 00  
00 00 8b 0d 92 eb b9 09 85 c9 75 18 65 8b 05 77 41 ac 7e <25> ff ff ff 7f  
39 c3 7f 1b 81 fb fe 00 00 00 76 6e 65 8b 05 5f 41
RSP: 0018:ffff88817b0b6a58 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff13
RAX: 0000000080000001 RBX: 0000000000000001 RCX: 0000000000000000
RDX: 0000000000000004 RSI: ffffffff83933488 RDI: ffffffff8b0f97e0
RBP: ffff88817b0b6a60 R08: ffff88817d73e4c0 R09: ffffed103b5c5b5f
R10: ffffed103b5c5b5f R11: ffff8881dae2dafb R12: 1ffff1102f616d01
R13: 0000000000000003 R14: ffff88817b0b6ad8 R15: 0000000000000001
  rcu_lockdep_current_cpu_online+0x1a4/0x210 kernel/rcu/tree.c:958
  rcu_read_lock_held+0x90/0xc0 kernel/rcu/update.c:279
  xa_entry include/linux/xarray.h:848 [inline]
  xas_reload include/linux/xarray.h:1196 [inline]
  find_get_entry+0xc9d/0x1120 mm/filemap.c:1440
  pagecache_get_page+0x12f/0xf00 mm/filemap.c:1518
  find_or_create_page include/linux/pagemap.h:322 [inline]
  grow_dev_page fs/buffer.c:947 [inline]
  grow_buffers fs/buffer.c:1016 [inline]
  __getblk_slow fs/buffer.c:1043 [inline]
  __getblk_gfp+0x3aa/0xd50 fs/buffer.c:1320
  __bread_gfp+0x2d/0x310 fs/buffer.c:1354
  sb_bread include/linux/buffer_head.h:307 [inline]
  fat__get_entry+0x5a6/0xa40 fs/fat/dir.c:101
  fat_get_entry fs/fat/dir.c:129 [inline]
  fat_get_short_entry+0x13c/0x2c0 fs/fat/dir.c:878
  fat_subdirs+0x142/0x290 fs/fat/dir.c:944
  fat_read_root fs/fat/inode.c:1416 [inline]
  fat_fill_super+0x2a9f/0x4310 fs/fat/inode.c:1851
  vfat_fill_super+0x31/0x40 fs/fat/namei_vfat.c:1049
  mount_bdev+0x30c/0x3e0 fs/super.c:1158
  vfat_mount+0x34/0x40 fs/fat/namei_vfat.c:1056
  mount_fs+0xae/0x31d fs/super.c:1261
  vfs_kern_mount.part.35+0xdc/0x4f0 fs/namespace.c:961
  vfs_kern_mount fs/namespace.c:951 [inline]
  do_new_mount fs/namespace.c:2469 [inline]
  do_mount+0x581/0x31f0 fs/namespace.c:2801
  ksys_mount+0x12d/0x140 fs/namespace.c:3017
  __do_sys_mount fs/namespace.c:3031 [inline]
  __se_sys_mount fs/namespace.c:3028 [inline]
  __x64_sys_mount+0xbe/0x150 fs/namespace.c:3028
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x45a0ea
Code: b8 a6 00 00 00 0f 05 48 3d 01 f0 ff ff 0f 83 7d 89 fb ff c3 66 2e 0f  
1f 84 00 00 00 00 00 66 90 49 89 ca b8 a5 00 00 00 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 5a 89 fb ff c3 66 0f 1f 84 00 00 00 00 00
RSP: 002b:00007f9204806a88 EFLAGS: 00000206 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 00007f9204806b30 RCX: 000000000045a0ea
RDX: 00007f9204806ad0 RSI: 00000000200004c0 RDI: 00007f9204806af0
RBP: 00000000200004c0 R08: 00007f9204806b30 R09: 00007f9204806ad0
R10: 0000000000000000 R11: 0000000000000206 R12: 0000000000000007
R13: 0000000000000000 R14: 00000000004d9c28 R15: 00000000ffffffff


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
