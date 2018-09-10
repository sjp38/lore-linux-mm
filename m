Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6328E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 04:28:05 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id w132-v6so37936445ita.6
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 01:28:05 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id c67-v6sor9179477iof.298.2018.09.10.01.28.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 01:28:03 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 10 Sep 2018 01:28:02 -0700
Message-ID: <000000000000c1dd4b057580223c@google.com>
Subject: WARNING in __local_bh_enable_ip (3)
From: syzbot <syzbot+5f9fe77fc9b743772535@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, hmclauchlan@fb.com, joe@perches.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Hello,

syzbot found the following crash on:

HEAD commit:    f2b6e66e9885 Add linux-next specific files for 20180904
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=110d0dea400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=15ad48400e39c1b3
dashboard link: https://syzkaller.appspot.com/bug?extid=5f9fe77fc9b743772535
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+5f9fe77fc9b743772535@syzkaller.appspotmail.com

Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
IRQs not enabled as expected
  fail_dump lib/fault-inject.c:51 [inline]
  should_fail.cold.4+0xa/0x11 lib/fault-inject.c:149
WARNING: CPU: 1 PID: 10172 at kernel/softirq.c:169  
__local_bh_enable_ip+0x1bb/0x230 kernel/softirq.c:169
Kernel panic - not syncing: panic_on_warn set ...

  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1557
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc mm/slab.c:3378 [inline]
  __do_kmalloc mm/slab.c:3716 [inline]
  __kmalloc+0x63/0x720 mm/slab.c:3727
  kmalloc include/linux/slab.h:518 [inline]
  tty_buffer_alloc drivers/tty/tty_buffer.c:170 [inline]
  __tty_buffer_request_room+0x2da/0x810 drivers/tty/tty_buffer.c:268
  tty_insert_flip_string_fixed_flag+0x8d/0x1f0 drivers/tty/tty_buffer.c:313
  tty_insert_flip_string include/linux/tty_flip.h:37 [inline]
  pty_write+0x12c/0x1f0 drivers/tty/pty.c:121
  tty_put_char+0x137/0x160 drivers/tty/tty_io.c:2865
  __process_echoes+0x462/0x9b0 drivers/tty/n_tty.c:714
  flush_echoes drivers/tty/n_tty.c:814 [inline]
  __receive_buf drivers/tty/n_tty.c:1633 [inline]
  n_tty_receive_buf_common+0x11d3/0x2c70 drivers/tty/n_tty.c:1727
  n_tty_receive_buf+0x30/0x40 drivers/tty/n_tty.c:1756
  tiocsti drivers/tty/tty_io.c:2171 [inline]
  tty_ioctl+0x7e7/0x1870 drivers/tty/tty_io.c:2557
  vfs_ioctl fs/ioctl.c:46 [inline]
  file_ioctl fs/ioctl.c:501 [inline]
  do_vfs_ioctl+0x1de/0x1720 fs/ioctl.c:685
  ksys_ioctl+0xa9/0xd0 fs/ioctl.c:702
  __do_sys_ioctl fs/ioctl.c:709 [inline]
  __se_sys_ioctl fs/ioctl.c:707 [inline]
  __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:707
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457099
Code: fd b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f7cf6e7dc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 00007f7cf6e7e6d4 RCX: 0000000000457099
RDX: 0000000020000040 RSI: 0000000000005412 RDI: 0000000000000004
RBP: 00000000009300a0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000006
R13: 00000000004d0df8 R14: 00000000004c6736 R15: 0000000000000000
CPU: 1 PID: 10172 Comm: syz-executor7 Not tainted 4.19.0-rc2-next-20180904+  
#55

======================================================
WARNING: possible circular locking dependency detected
4.19.0-rc2-next-20180904+ #55 Not tainted
------------------------------------------------------
syz-executor5/10168 is trying to acquire lock:
0000000024f4e687 (console_owner){-.-.}, at: log_next  
kernel/printk/printk.c:498 [inline]
0000000024f4e687 (console_owner){-.-.}, at: console_unlock+0x7a7/0x10d0  
kernel/printk/printk.c:2394

but task is already holding lock:
0000000010640b20 (&(&port->lock)->rlock){-.-.}, at: pty_write+0xf9/0x1f0  
drivers/tty/pty.c:119

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&(&port->lock)->rlock){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x96/0xc0 kernel/locking/spinlock.c:152
        tty_port_tty_get+0x20/0x80 drivers/tty/tty_port.c:288
        tty_port_default_wakeup+0x15/0x40 drivers/tty/tty_port.c:47
        tty_port_tty_wakeup+0x5d/0x70 drivers/tty/tty_port.c:390
        uart_write_wakeup+0x44/0x60 drivers/tty/serial/serial_core.c:103
        serial8250_tx_chars+0x4be/0xb60  
drivers/tty/serial/8250/8250_port.c:1806
        serial8250_handle_irq.part.23+0x1ee/0x280  
drivers/tty/serial/8250/8250_port.c:1879
        serial8250_handle_irq drivers/tty/serial/8250/8250_port.c:1865  
[inline]
        serial8250_default_handle_irq+0xc8/0x150  
drivers/tty/serial/8250/8250_port.c:1895
        serial8250_interrupt+0xfa/0x1d0  
drivers/tty/serial/8250/8250_core.c:125
        __handle_irq_event_percpu+0x1c8/0xa50 kernel/irq/handle.c:149
        handle_irq_event_percpu+0xa0/0x1d0 kernel/irq/handle.c:189
        handle_irq_event+0xa7/0x135 kernel/irq/handle.c:206
        handle_edge_irq+0x20f/0x870 kernel/irq/chip.c:791
        generic_handle_irq_desc include/linux/irqdesc.h:154 [inline]
        handle_irq+0x18c/0x2e7 arch/x86/kernel/irq_64.c:78
        do_IRQ+0x80/0x1a0 arch/x86/kernel/irq.c:246
        ret_from_intr+0x0/0x1e
        native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:57
        arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
        default_idle+0xc2/0x410 arch/x86/kernel/process.c:498
        arch_cpu_idle+0x10/0x20 arch/x86/kernel/process.c:489
        default_idle_call+0x6d/0x90 kernel/sched/idle.c:93
        cpuidle_idle_call kernel/sched/idle.c:153 [inline]
        do_idle+0x3aa/0x580 kernel/sched/idle.c:262
        cpu_startup_entry+0x10c/0x120 kernel/sched/idle.c:368
        start_secondary+0x433/0x5d0 arch/x86/kernel/smpboot.c:271
        secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:242

-> #1 (&port_lock_key){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x96/0xc0 kernel/locking/spinlock.c:152
        serial8250_console_write+0x8e5/0xb20  
drivers/tty/serial/8250/8250_port.c:3247
        univ8250_console_write+0x5f/0x70  
drivers/tty/serial/8250/8250_core.c:590
        call_console_drivers kernel/printk/printk.c:1725 [inline]
        console_unlock+0xace/0x10d0 kernel/printk/printk.c:2407
        vprintk_emit+0x33a/0x910 kernel/printk/printk.c:1926
        vprintk_default+0x28/0x30 kernel/printk/printk.c:1967
        vprintk_func+0x7a/0x117 kernel/printk/printk_safe.c:398
        printk+0xa7/0xcf kernel/printk/printk.c:2000
        register_console+0x7e7/0xc00 kernel/printk/printk.c:2722
        univ8250_console_init+0x3f/0x4b  
drivers/tty/serial/8250/8250_core.c:685
        console_init+0x5d4/0x891 kernel/printk/printk.c:2808
        start_kernel+0x610/0x94e init/main.c:661
        x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:452
        x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:433
        secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:242

-> #0 (console_owner){-.-.}:
        lock_acquire+0x1e4/0x4f0 kernel/locking/lockdep.c:3901
        console_lock_spinning_enable kernel/printk/printk.c:1588 [inline]
        console_unlock+0x814/0x10d0 kernel/printk/printk.c:2404
        vprintk_emit+0x33a/0x910 kernel/printk/printk.c:1926
        vprintk_default+0x28/0x30 kernel/printk/printk.c:1967
        vprintk_func+0x7a/0x117 kernel/printk/printk_safe.c:398
        printk+0xa7/0xcf kernel/printk/printk.c:2000
        fail_dump lib/fault-inject.c:44 [inline]
        should_fail+0xb04/0xd86 lib/fault-inject.c:149
        __should_failslab+0x124/0x180 mm/failslab.c:32
        should_failslab+0x9/0x14 mm/slab_common.c:1557
        slab_pre_alloc_hook mm/slab.h:423 [inline]
        slab_alloc mm/slab.c:3378 [inline]
        __do_kmalloc mm/slab.c:3716 [inline]
        __kmalloc+0x63/0x720 mm/slab.c:3727
        kmalloc include/linux/slab.h:518 [inline]
        tty_buffer_alloc drivers/tty/tty_buffer.c:170 [inline]
        __tty_buffer_request_room+0x2da/0x810 drivers/tty/tty_buffer.c:268
        tty_insert_flip_string_fixed_flag+0x8d/0x1f0  
drivers/tty/tty_buffer.c:313
        tty_insert_flip_string include/linux/tty_flip.h:37 [inline]
        pty_write+0x12c/0x1f0 drivers/tty/pty.c:121
        tty_put_char+0x137/0x160 drivers/tty/tty_io.c:2865
        __process_echoes+0x462/0x9b0 drivers/tty/n_tty.c:714
        flush_echoes drivers/tty/n_tty.c:814 [inline]
        __receive_buf drivers/tty/n_tty.c:1633 [inline]
        n_tty_receive_buf_common+0x11d3/0x2c70 drivers/tty/n_tty.c:1727
        n_tty_receive_buf+0x30/0x40 drivers/tty/n_tty.c:1756
        tiocsti drivers/tty/tty_io.c:2171 [inline]
        tty_ioctl+0x7e7/0x1870 drivers/tty/tty_io.c:2557
        vfs_ioctl fs/ioctl.c:46 [inline]
        file_ioctl fs/ioctl.c:501 [inline]
        do_vfs_ioctl+0x1de/0x1720 fs/ioctl.c:685
        ksys_ioctl+0xa9/0xd0 fs/ioctl.c:702
        __do_sys_ioctl fs/ioctl.c:709 [inline]
        __se_sys_ioctl fs/ioctl.c:707 [inline]
        __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:707
        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

other info that might help us debug this:

Chain exists of:
   console_owner --> &port_lock_key --> &(&port->lock)->rlock

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&(&port->lock)->rlock);
                                lock(&port_lock_key);
                                lock(&(&port->lock)->rlock);
   lock(console_owner);

  *** DEADLOCK ***

5 locks held by syz-executor5/10168:
  #0: 000000000d2dc9cb (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:353
  #1: 000000009f357d4f (&o_tty->termios_rwsem/1){++++}, at:  
n_tty_receive_buf_common+0xeb/0x2c70 drivers/tty/n_tty.c:1690
  #2: 0000000005bec1a7 (&ldata->output_lock){+.+.}, at: flush_echoes  
drivers/tty/n_tty.c:812 [inline]
  #2: 0000000005bec1a7 (&ldata->output_lock){+.+.}, at: __receive_buf  
drivers/tty/n_tty.c:1633 [inline]
  #2: 0000000005bec1a7 (&ldata->output_lock){+.+.}, at:  
n_tty_receive_buf_common+0x119b/0x2c70 drivers/tty/n_tty.c:1727
  #3: 0000000010640b20 (&(&port->lock)->rlock){-.-.}, at:  
pty_write+0xf9/0x1f0 drivers/tty/pty.c:119
  #4: 0000000073842333 (console_lock){+.+.}, at: console_trylock_spinning  
kernel/printk/printk.c:1650 [inline]
  #4: 0000000073842333 (console_lock){+.+.}, at: vprintk_emit+0x31f/0x910  
kernel/printk/printk.c:1925

stack backtrace:
CPU: 0 PID: 10168 Comm: syz-executor5 Not tainted 4.19.0-rc2-next-20180904+  
#55
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
  print_circular_bug.isra.34.cold.55+0x1bd/0x27d  
kernel/locking/lockdep.c:1222
  check_prev_add kernel/locking/lockdep.c:1862 [inline]
  check_prevs_add kernel/locking/lockdep.c:1975 [inline]
  validate_chain kernel/locking/lockdep.c:2416 [inline]
  __lock_acquire+0x3449/0x5020 kernel/locking/lockdep.c:3412
  lock_acquire+0x1e4/0x4f0 kernel/locking/lockdep.c:3901
  console_lock_spinning_enable kernel/printk/printk.c:1588 [inline]
  console_unlock+0x814/0x10d0 kernel/printk/printk.c:2404
  vprintk_emit+0x33a/0x910 kernel/printk/printk.c:1926
  vprintk_default+0x28/0x30 kernel/printk/printk.c:1967
  vprintk_func+0x7a/0x117 kernel/printk/printk_safe.c:398
  printk+0xa7/0xcf kernel/printk/printk.c:2000
  fail_dump lib/fault-inject.c:44 [inline]
  should_fail+0xb04/0xd86 lib/fault-inject.c:149
  __should_failslab+0x124/0x180 mm/failslab.c:32
  should_failslab+0x9/0x14 mm/slab_common.c:1557
  slab_pre_alloc_hook mm/slab.h:423 [inline]
  slab_alloc mm/slab.c:3378 [inline]
  __do_kmalloc mm/slab.c:3716 [inline]
  __kmalloc+0x63/0x720 mm/slab.c:3727
  kmalloc include/linux/slab.h:518 [inline]
  tty_buffer_alloc drivers/tty/tty_buffer.c:170 [inline]
  __tty_buffer_request_room+0x2da/0x810 drivers/tty/tty_buffer.c:268
  tty_insert_flip_string_fixed_flag+0x8d/0x1f0 drivers/tty/tty_buffer.c:313
  tty_insert_flip_string include/linux/tty_flip.h:37 [inline]
  pty_write+0x12c/0x1f0 drivers/tty/pty.c:121
  tty_put_char+0x137/0x160 drivers/tty/tty_io.c:2865
  __process_echoes+0x462/0x9b0 drivers/tty/n_tty.c:714
  flush_echoes drivers/tty/n_tty.c:814 [inline]
  __receive_buf drivers/tty/n_tty.c:1633 [inline]
  n_tty_receive_buf_common+0x11d3/0x2c70 drivers/tty/n_tty.c:1727
  n_tty_receive_buf+0x30/0x40 drivers/tty/n_tty.c:1756
  tiocsti drivers/tty/tty_io.c:2171 [inline]
  tty_ioctl+0x7e7/0x1870 drivers/tty/tty_io.c:2557
  vfs_ioctl fs/ioctl.c:46 [inline]
  file_ioctl fs/ioctl.c:501 [inline]
  do_vfs_ioctl+0x1de/0x1720 fs/ioctl.c:685
  ksys_ioctl+0xa9/0xd0 fs/ioctl.c:702
  __do_sys_ioctl fs/ioctl.c:709 [inline]
  __se_sys_ioctl fs/ioctl.c:707 [inline]
  __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:707
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457099
Code: fd b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 f
Lost 7 message(s)!
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
RIP: 0010:__local_bh_enable_ip+0x1bb/0x230 kernel/softirq.c:169
Code: 44 00 00 5b 41 5c 41 5d 5d c3 80 3d b6 e2 61 07 00 0f 85 3c ff ff ff  
48 c7 c7 40 f4 28 87 c6 05 a2 e2 61 07 01 e8 a5 26 fe ff <0f> 0b e9 22 ff  
ff ff 4c 89 e7 e8 d6 56 16 00 e9 68 ff ff ff 0f 0b
RSP: 0018:ffff880189fa5cb8 EFLAGS: 00010282
RAX: 0000000000000000 RBX: 0000000000000201 RCX: ffffc9000288c000
RDX: 0000000000040000 RSI: ffffffff8163ba91 RDI: ffff880189fa59a8
RBP: ffff880189fa5cd0 R08: ffff880188bd2140 R09: fffffbfff1031404
R10: fffffbfff1031404 R11: ffffffff8818a023 R12: ffffffff8608e7f4
R13: ffff880188bd2140 R14: ffffc90011f27060 R15: dffffc0000000000
  __raw_read_unlock_bh include/linux/rwlock_api_smp.h:251 [inline]
  _raw_read_unlock_bh+0x30/0x40 kernel/locking/spinlock.c:272
  ebt_do_table+0x1c14/0x2170 net/bridge/netfilter/ebtables.c:307
  ebt_nat_in+0x65/0x80 net/bridge/netfilter/ebtable_nat.c:64
  ebt_nat_out+0x25/0x30 net/bridge/netfilter/ebtable_nat.c:64
  nf_hook_entry_hookfn include/linux/netfilter.h:119 [inline]
  nf_hook_slow+0xc2/0x1c0 net/netfilter/core.c:511
  nf_hook include/linux/netfilter.h:242 [inline]
  NF_HOOK include/linux/netfilter.h:285 [inline]
  __br_forward+0x534/0xdc0 net/bridge/br_forward.c:113
  br_flood+0x85b/0x990 net/bridge/br_forward.c:240
  br_dev_xmit+0x111b/0x1810 net/bridge/br_device.c:103
  ? 0xffffffff81000000
  __netdev_start_xmit include/linux/netdevice.h:4313 [inline]
  netdev_start_xmit include/linux/netdevice.h:4322 [inline]
  xmit_one net/core/dev.c:3216 [inline]
  dev_hard_start_xmit+0x272/0xc10 net/core/dev.c:3232
  __dev_queue_xmit+0x2ab2/0x3870 net/core/dev.c:3802
  dev_queue_xmit+0x17/0x20 net/core/dev.c:3835
  neigh_hh_output include/net/neighbour.h:473 [inline]
  neigh_output include/net/neighbour.h:481 [inline]
  ip_finish_output2+0x1063/0x1860 net/ipv4/ip_output.c:229
  ip_do_fragment+0x21a2/0x2ae0 net/ipv4/ip_output.c:678
  ip_fragment.constprop.49+0x179/0x240 net/ipv4/ip_output.c:549
  ip_finish_output+0x6e4/0xfa0 net/ipv4/ip_output.c:315
  NF_HOOK_COND include/linux/netfilter.h:276 [inline]
  ip_output+0x223/0x880 net/ipv4/ip_output.c:405
  dst_output include/net/dst.h:444 [inline]
  ip_local_out+0xc5/0x1b0 net/ipv4/ip_output.c:124
  ip_send_skb+0x40/0xe0 net/ipv4/ip_output.c:1441
  udp_send_skb.isra.41+0x6b7/0x11d0 net/ipv4/udp.c:829
  udp_push_pending_frames+0x5c/0xf0 net/ipv4/udp.c:857
  udp_sendmsg+0x178a/0x38e0 net/ipv4/udp.c:1148
  udpv6_sendmsg+0x296a/0x36b0 net/ipv6/udp.c:1201
  inet_sendmsg+0x1a1/0x690 net/ipv4/af_inet.c:798
  sock_sendmsg_nosec net/socket.c:622 [inline]
  sock_sendmsg+0xd5/0x120 net/socket.c:632
  __sys_sendto+0x3d7/0x670 net/socket.c:1787
  __do_sys_sendto net/socket.c:1799 [inline]
  __se_sys_sendto net/socket.c:1795 [inline]
  __x64_sys_sendto+0xe1/0x1a0 net/socket.c:1795
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457099
Code: fd b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f0550d94c78 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 00007f0550d956d4 RCX: 0000000000457099
RDX: 0000000000000000 RSI: 0000000020000300 RDI: 0000000000000004
RBP: 00000000009300a0 R08: 00000000200002c0 R09: 000000000000001c
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 00000000004d4cc8 R14: 00000000004c91af R15: 0000000000000000
Dumping ftrace buffer:
    (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
