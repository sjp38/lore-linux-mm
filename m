Received: by nf-out-0910.google.com with SMTP id c10so699060nfd.6
        for <linux-mm@kvack.org>; Sun, 06 Jul 2008 16:48:47 -0700 (PDT)
Message-ID: <487159DA.708@gmail.com>
Date: Mon, 07 Jul 2008 03:48:42 +0400
From: Alexander Beregalov <a.beregalov@gmail.com>
MIME-Version: 1.0
Subject: next-0704: WARNING: at kernel/sched.c:4254 add_preempt_count; PANIC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

WARNING: at kernel/sched.c:4254 add_preempt_count+0x61/0x63()
Modules linked in: i2c_nforce2
Pid: 3620, comm: rtorrent Not tainted 2.6.26-rc8-next-20080704 #5
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] warn_on_slowpath+0x41/0x7b
 [<c0157a94>] ? mmap_region+0x1c5/0x414
 [<c0156499>] ? remove_vma+0x50/0x56
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
BUG: unable to handle kernel paging request at fffef4f1
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00007067 *pte = 00000000
Oops: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3620, comm: rtorrent Not tainted (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c0103c53>] EFLAGS: 00210097 CPU: 0
EIP is at dump_trace+0xa5/0xe2
EAX: fffefffc EBX: fffef4f1 ECX: c0396978 EDX: c0455a08
ESI: 5a5a5a5a EDI: f4d4c084 EBP: f4d4bf34 ESP: f4d4bf14
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process rtorrent (pid: 3620, ti=f4d4b000 task=f4cc45c0 task.ti=f4d4c000)
Stack: fffefffc c0103b6f fffef000 f4d4c084 00000000 00000002 f4d4bf7c
c0426908
       f4d4bf48 c01045f5 f4d4bf7c c0396978 c047904c f4d4bf7c c038e33b
f4d4bf7c
       c041ff98 00000e24 f4cc48b4 c050a434 c049959a 00000002 c04995db
c038e436
Call Trace:
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] ? show_trace+0x15/0x29
 [<c038e33b>] ? dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] ? warn_on_slowpath+0x41/0x7b
 [<c0157a94>] ? mmap_region+0x1c5/0x414
 [<c0156499>] ? remove_vma+0x50/0x56
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
BUG: unable to handle kernel paging request at fffef4f1
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00007067 *pte = 00000000
Oops: 0000 [#2] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3620, comm: rtorrent Not tainted (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c0103c53>] EFLAGS: 00210097 CPU: 0
EIP is at dump_trace+0xa5/0xe2
EAX: fffefffc EBX: fffef4f1 ECX: c0396978 EDX: c0455a08
ESI: 5a5a5a5a EDI: f4d4c084 EBP: f4d4bf34 ESP: f4d4bf14
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process rtorrent (pid: 3620, ti=f4d4b000 task=f4cc45c0 task.ti=f4d4c000)
Stack: fffefffc c0103b6f fffef000 f4d4c084 00000000 00000002 f4d4bf7c
c0426908
       f4d4bf48 c01045f5 f4d4bf7c c0396978 c047904c f4d4bf7c c038e33b
f4d4bf7c
       c041ff98 00000e24 f4cc48b4 c050a434 c049959a 00000002 c04995db
c038e436
Call Trace:
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] ? show_trace+0x15/0x29
 [<c038e33b>] ? dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] ? warn_on_slowpath+0x41/0x7b
 [<c0157a94>] ? mmap_region+0x1c5/0x414
 [<c0156499>] ? remove_vma+0x50/0x56
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
BUG: unable to handle kernel paging request at fffef4f1
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00007067 *pte = 00000000
Oops: 0000 [#2] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3620, comm: rtorrent Not tainted (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c0103c53>] EFLAGS: 00210097 CPU: 0
EIP is at dump_trace+0xa5/0xe2
EAX: fffefffc EBX: fffef4f1 ECX: c0396978 EDX: c0455a08
ESI: 5a5a5a5a EDI: f4d4bd18 EBP: f4d4bd18 ESP: f4d4bcf8
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process rtorrent (pid: 3620, ti=f4d4b000 task=f4cc45c0 task.ti=f4d4c000)
Stack: fffefffc c0103b6f fffef000 f4d4bd18 00000018 00000018 f4d4bf77
00000000
       f4d4bd48 c0103d1f 00000000 c0396978 c041fab4 c041fbc2 c041fab4
f4d4bedc
       f4d4bf14 f4d4bf14 c04258bf f4d4bedc f4d4bd80 c0103dc5 00000000
c041fab4
Call Trace:
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] ? show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] ? show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] ? __die+0x7f/0xcb
 [<c0103f7b>] ? die+0x87/0x119
 [<c0392c65>] ? do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c0390020>] ? rt_mutex_slowlock+0x26a/0x446
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] ? error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] ? show_trace+0x15/0x29
 [<c038e33b>] ? dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] ? warn_on_slowpath+0x41/0x7b
 [<c0157a94>] ? mmap_region+0x1c5/0x414
 [<c0156499>] ? remove_vma+0x50/0x56
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
BUG: unable to handle kernel paging request at fffef4f1
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00007067 *pte = 00000000
Recursive die() failure, output suppressed
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 3620, comm: rtorrent Tainted: G      D   2.6.26-rc8-next-20080704 #5
 [<c038e436>] ? printk+0xf/0x11
 [<c038e388>] panic+0x43/0xe2
 [<c0103fe6>] die+0xf2/0x119
 [<c0392c65>] do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] __die+0x7f/0xcb
 [<c0103f7b>] die+0x87/0x119
 [<c0392c65>] do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] __die+0x7f/0xcb
 [<c0103f7b>] die+0x87/0x119
 [<c0392c65>] do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c0390020>] ? rt_mutex_slowlock+0x26a/0x446
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] show_trace+0x15/0x29
 [<c038e33b>] dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] warn_on_slowpath+0x41/0x7b
 [<c0157a94>] ? mmap_region+0x1c5/0x414
 [<c0156499>] ? remove_vma+0x50/0x56
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
BUG: unable to handle kernel paging request at fffef4f1
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00007067 *pte = 00000000
Oops: 0000 [#3] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3620, comm: rtorrent Tainted: G      D   (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c0103c53>] EFLAGS: 00210097 CPU: 0
EIP is at dump_trace+0xa5/0xe2
EAX: fffefffc EBX: fffef4f1 ECX: c0396978 EDX: c0455a08
ESI: 5a5a5a5a EDI: f4d4c084 EBP: f4d4b8f4 ESP: f4d4b8d4
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process rtorrent (pid: 3620, ti=f4d4b000 task=f4cc45c0 task.ti=f4d4c000)
Stack: fffefffc c0103b6f fffef000 f4d4c084 00000020 00000002 f4d4b93c
00000000
       f4d4b908 c01045f5 f4d4b93c c0396978 c047904c f4d4b93c c038e33b
f4d4b93c
       c041ff98 00000e24 f4cc48b4 c050a434 c049959a 00000002 c04995db
c038e436
Call Trace:
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] ? show_trace+0x15/0x29
 [<c038e33b>] ? dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c038e388>] ? panic+0x43/0xe2
 [<c0103fe6>] ? die+0xf2/0x119
 [<c0392c65>] ? do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] ? error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] ? show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] ? show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] ? __die+0x7f/0xcb
 [<c0103f7b>] ? die+0x87/0x119
 [<c0392c65>] ? do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] ? error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] ? show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] ? show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] ? __die+0x7f/0xcb
 [<c0103f7b>] ? die+0x87/0x119
 [<c0392c65>] ? do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c0390020>] ? rt_mutex_slowlock+0x26a/0x446
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] ? error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] ? show_trace+0x15/0x29
 [<c038e33b>] ? dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] ? warn_on_slowpath+0x41/0x7b
 [<c0157a94>] ? mmap_region+0x1c5/0x414
 [<c0156499>] ? remove_vma+0x50/0x56
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159798>] ? anon_vma_unlink+0x3a/0x3e
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
 [<c0159836>] ? anon_vma_prepare+0x52/0xc5
BUG: unable to handle kernel paging request at fffef4f1
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00007067 *pte = 00000000
Oops: 0000 [#4] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3620, comm: rtorrent Tainted: G      D   (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c0103c53>] EFLAGS: 00210097 CPU: 0
EIP is at dump_trace+0xa5/0xe2
EAX: fffefffc EBX: fffef4f1 ECX: c0396978 EDX: c0455a08
ESI: 5a5a5a5a EDI: f4d4b6d8 EBP: f4d4b6d8 ESP: f4d4b6b8
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process rtorrent (pid: 3620, ti=f4d4b000 task=f4cc45c0 task.ti=f4d4c000)
Stack: fffefffc c0103b6f fffef000 f4d4b6d8 00000018 00000018 f4d4b937
00000000
       f4d4b708 c0103d1f 00000000 c0396978 c041fab4 c041fbc2 c041fab4
f4d4b89c
       f4d4b8d4 f4d4b8d4 c04258bf f4d4b89c f4d4b740 c0103dc5 00000000
c041fab4
Call Trace:
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] ? show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] ? show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] ? __die+0x7f/0xcb
 [<c0103f7b>] ? die+0x87/0x119
 [<c0392c65>] ? do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c0390020>] ? rt_mutex_slowlock+0x26a/0x446
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] ? error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] ? show_trace+0x15/0x29
 [<c038e33b>] ? dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c038e388>] ? panic+0x43/0xe2
 [<c0103fe6>] ? die+0xf2/0x119
 [<c0392c65>] ? do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] ? error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] ? show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] ? show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] ? __die+0x7f/0xcb
 [<c0103f7b>] ? die+0x87/0x119
 [<c0392c65>] ? do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] ? error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] ? show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] ? show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] ? __die+0x7f/0xcb
 [<c0103f7b>] ? die+0x87/0x119
 [<c0392c65>] ? do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c0390020>] ? rt_mutex_slowlock+0x26a/0x446
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] ? error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] ? show_trace+0x15/0x29
 [<c038e33b>] ? dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] ? warn_on_slowpath+0x41/0x7b
 [<c0157a94>] ? mmap_region+0x1c5/0x414
 [<c0156499>] ? remove_vma+0x50/0x56
BUG: unable to handle kernel NULL pointer dereference at 00000008
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00000000
Recursive die() failure, output suppressed
Kernel panic - not syncing: Fatal exception in non-maskable interrupt
Pid: 3620, comm: rtorrent Tainted: G      D   2.6.26-rc8-next-20080704 #5
 [<c038e436>] ? printk+0xf/0x11
 [<c038e388>] panic+0x43/0xe2
 [<c0103fe6>] die+0xf2/0x119
 [<c0392c65>] do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c0392d81>] ? sub_preempt_count+0x17/0x60
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392d81>] ? sub_preempt_count+0x17/0x60
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] __die+0x7f/0xcb
 [<c0103f7b>] die+0x87/0x119
 [<c0392c65>] do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] __die+0x7f/0xcb
 [<c0103f7b>] die+0x87/0x119
 [<c0392c65>] do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c0390020>] ? rt_mutex_slowlock+0x26a/0x446
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] show_trace+0x15/0x29
 [<c038e33b>] dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c038e388>] panic+0x43/0xe2
 [<c0103fe6>] die+0xf2/0x119
 [<c0392c65>] do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] __die+0x7f/0xcb
 [<c0103f7b>] die+0x87/0x119
 [<c0392c65>] do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] __die+0x7f/0xcb
 [<c0103f7b>] die+0x87/0x119
 [<c0392c65>] do_page_fault+0x5e0/0x6e5
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c0392ea3>] ? __atomic_notifier_call_chain+0x2c/0x36
 [<c038e436>] ? printk+0xf/0x11
 [<c013f0fd>] ? __print_symbol+0x21/0x2a
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0390981>] ? _spin_unlock_irqrestore+0x42/0x58
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c011c24a>] ? vprintk+0x327/0x35c
 [<c0390020>] ? rt_mutex_slowlock+0x26a/0x446
 [<c011bd85>] ? release_console_sem+0x197/0x19f
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c0103c53>] ? dump_trace+0xa5/0xe2
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] show_trace+0x15/0x29
 [<c038e33b>] dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] warn_on_slowpath+0x41/0x7b
 [<c0157a94>] ? mmap_region+0x1c5/0x414
 [<c0156499>] ? remove_vma+0x50/0x56
BUG: unable to handle kernel paging request at 5c828b00
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00000000
Oops: 0000 [#5] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2



lspci:
00:00.0 Host bridge [0600]: nVidia Corporation nForce2 AGP (different
version?) [10de:01e0] (rev c1)
00:00.1 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller
1 [10de:01eb] (rev c1)
00:00.2 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller
4 [10de:01ee] (rev c1)
00:00.3 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller
3 [10de:01ed] (rev c1)
00:00.4 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller
2 [10de:01ec] (rev c1)
00:00.5 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller
5 [10de:01ef] (rev c1)
00:01.0 ISA bridge [0601]: nVidia Corporation nForce2 ISA Bridge
[10de:0060] (rev a4)
00:01.1 SMBus [0c05]: nVidia Corporation nForce2 SMBus (MCP) [10de:0064]
(rev a2)
00:02.0 USB Controller [0c03]: nVidia Corporation nForce2 USB Controller
[10de:0067] (rev a4)
00:02.1 USB Controller [0c03]: nVidia Corporation nForce2 USB Controller
[10de:0067] (rev a4)
00:02.2 USB Controller [0c03]: nVidia Corporation nForce2 USB Controller
[10de:0068] (rev a4)
00:04.0 Ethernet controller [0200]: nVidia Corporation nForce2 Ethernet
Controller [10de:0066] (rev a1)
00:08.0 PCI bridge [0604]: nVidia Corporation nForce2 External PCI
Bridge [10de:006c] (rev a3)
00:09.0 IDE interface [0101]: nVidia Corporation nForce2 IDE [10de:0065]
(rev a2)
00:1e.0 PCI bridge [0604]: nVidia Corporation nForce2 AGP [10de:01e8]
(rev c1)
01:06.0 Ethernet controller [0200]: Intel Corporation 82540EM Gigabit
Ethernet Controller [8086:100e] (rev 02)
01:0a.0 RAID bus controller [0104]: Promise Technology, Inc. PDC20270
(FastTrak100 LP/TX2/TX4) [105a:6268] (rev 02)
02:00.0 VGA compatible controller [0300]: ATI Technologies Inc Radeon
RV250 If [Radeon 9000] [1002:4966] (rev 01)
02:00.1 Display controller [0380]: ATI Technologies Inc Radeon RV250
[Radeon 9000] (Secondary) [1002:496e] (rev 01)

Do you need a config?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
