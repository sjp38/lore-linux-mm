Received: by ik-out-1112.google.com with SMTP id b32so1092099ika.6
        for <linux-mm@kvack.org>; Sun, 06 Jul 2008 23:23:30 -0700 (PDT)
Message-ID: <4871B65D.3020901@gmail.com>
Date: Mon, 07 Jul 2008 10:23:25 +0400
From: Alexander Beregalov <a.beregalov@gmail.com>
MIME-Version: 1.0
Subject: Re: next-0704: WARNING: at kernel/sched.c:4254 add_preempt_count;
 PANIC
References: <487159DA.708@gmail.com>
In-Reply-To: <487159DA.708@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

One more time:

WARNING: at kernel/sched.c:4254 add_preempt_count+0x61/0x63()
Modules linked in: i2c_nforce2
Pid: 3654, comm: rtorrent Not tainted 2.6.26-rc8-next-20080704 #5
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] warn_on_slowpath+0x41/0x7b
 [<c01666b9>] ? get_empty_filp+0x54/0x11d
 [<c016629f>] ? file_free_rcu+0xf/0x11
BUG: unable to handle kernel paging request at 73746365
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00000000
Oops: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3654, comm: rtorrent Not tainted (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c0103c53>] EFLAGS: 00210097 CPU: 0
EIP is at dump_trace+0xa5/0xe2
EAX: 73746ffc EBX: 73746365 ECX: c0396978 EDX: c0455a08
ESI: 69620036 EDI: f3e49084 EBP: f3e48f34 ESP: f3e48f14
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process rtorrent (pid: 3654, ti=f3e48000 task=f7d0dd00 task.ti=f3e49000)
Stack: 73746ffc c0103b6f 73746000 f3e49084 00000000 00000002 f3e48f7c c0426908
       f3e48f48 c01045f5 f3e48f7c c0396978 c047904c f3e48f7c c038e33b f3e48f7c
       c041ff98 00000e46 f7d0dff4 c050a434 c049959a 00000002 c04995db c038e436
Call Trace:
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c01045f5>] ? show_trace+0x15/0x29
 [<c038e33b>] ? dump_stack+0x59/0x63
 [<c038e436>] ? printk+0xf/0x11
 [<c011b681>] ? warn_on_slowpath+0x41/0x7b
 [<c01666b9>] ? get_empty_filp+0x54/0x11d
 [<c016629f>] ? file_free_rcu+0xf/0x11
BUG: unable to handle kernel paging request at 73746365
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00000000
Oops: 0000 [#2] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3654, comm: rtorrent Not tainted (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c0103c53>] EFLAGS: 00210097 CPU: 0
EIP is at dump_trace+0xa5/0xe2
EAX: 73746ffc EBX: 73746365 ECX: c0396978 EDX: c0455a08
ESI: 69620036 EDI: f3e48d18 EBP: f3e48d18 ESP: f3e48cf8
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process rtorrent (pid: 3654, ti=f3e48000 task=f7d0dd00 task.ti=f3e49000)
Stack: 73746ffc c0103b6f 73746000 f3e48d18 00000018 00000018 f3e48f77 00000000
       f3e48d48 c0103d1f 00000000 c0396978 c041fab4 c041fbc2 c041fab4 f3e48edc
       f3e48f14 f3e48f14 c04258bf f3e48edc f3e48d80 c0103dc5 00000000 c041fab4
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
 [<c01666b9>] ? get_empty_filp+0x54/0x11d
 [<c016629f>] ? file_free_rcu+0xf/0x11
BUG: unable to handle kernel paging request at 73746365
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00000000
Recursive die() failure, output suppressed
---[ end trace 85130c76b53cd30a ]---
note: rtorrent[3654] exited with preempt_count 1
BUG: unable to handle kernel paging request at c045f594
IP: [<c026b57d>] _raw_spin_trylock+0xa/0x3b
*pde = 37368163 *pte = 0045f161
Oops: 0003 [#3] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3654, comm: rtorrent Tainted: G      D   (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c026b57d>] EFLAGS: 00210046 CPU: 0
EIP is at _raw_spin_trylock+0xa/0x3b
EAX: 6f6f6220 EBX: 00000000 ECX: c045f594 EDX: 00000000
ESI: c045f594 EDI: c045f554 EBP: f3e48880 ESP: f3e4887c
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process rtorrent (pid: 3654, ti=f3e48000 task=f7d0dd00 task.ti=f3e49000)
Stack: c045f5a4 f3e4889c c0390abe 00000000 00000002 c0156822 f3eb0e80 f3e48900
       f3e488b4 c0156822 c045f594 f3eb0580 f3eb0e80 f3eb0e80 f3e488d4 c01554f1
       00000000 f3e488f0 b2141000 f3e488f0 f67a4a00 f601c780 f3e48900 c0156511
Call Trace:
 [<c0390abe>] ? _spin_lock+0x2d/0x53
 [<c0156822>] ? unlink_file_vma+0x23/0x72
 [<c0156822>] ? unlink_file_vma+0x23/0x72
 [<c01554f1>] ? free_pgtables+0x4e/0x81
 [<c0156511>] ? exit_mmap+0x72/0xdb
 [<c0119aa2>] ? mmput+0x34/0x84
 [<c011cdf3>] ? exit_mm+0xb2/0xb8
 [<c011e3d0>] ? do_exit+0x1be/0x5d0
 [<c038e436>] ? printk+0xf/0x11
 [<c011b7b5>] ? oops_exit+0x23/0x28
 [<c0104005>] ? die+0x111/0x119
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
 [<c01666b9>] ? get_empty_filp+0x54/0x11d
 [<c016629f>] ? file_free_rcu+0xf/0x11
BUG: unable to handle kernel paging request at 73746365
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00000000
Oops: 0000 [#4] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3654, comm: rtorrent Tainted: G      D   (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c0103c53>] EFLAGS: 00210097 CPU: 0
EIP is at dump_trace+0xa5/0xe2
EAX: 73746ffc EBX: 73746365 ECX: c0396978 EDX: c0455a08
ESI: 69620036 EDI: f3e48680 EBP: f3e48680 ESP: f3e48660
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process rtorrent (pid: 3654, ti=f3e48000 task=f7d0dd00 task.ti=f3e49000)
Stack: 73746ffc c0103b6f 73746000 f3e48680 00000018 00000018 f3e488df 00000000
       f3e486b0 c0103d1f 00000000 c0396978 c041fab4 c041fbc2 c041fab4 f3e48844
       f3e4887c f3e4887c c04258bf f3e48844 f3e486e8 c0103dc5 00000000 c041fab4
Call Trace:
 [<c0103b6f>] ? print_trace_address+0x0/0x3f
 [<c0103d1f>] ? show_stack_log_lvl+0x8f/0xa7
 [<c0103dc5>] ? show_registers+0x8e/0x1bd
 [<c0391720>] ? __die+0x66/0xcb
 [<c0391739>] ? __die+0x7f/0xcb
 [<c0103f7b>] ? die+0x87/0x119
 [<c0392c65>] ? do_page_fault+0x5e0/0x6e5
 [<c02803a7>] ? bit_cursor+0x4e1/0x4f6
 [<c027a9b6>] ? fbcon_clear+0xfa/0x117
 [<c0110d8e>] ? __change_page_attr_set_clr+0x83/0x4e6
 [<c03909be>] ? _spin_unlock+0x27/0x3c
 [<c014ba74>] ? free_pages_bulk+0x1d6/0x213
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] ? error_code+0x6a/0x70
 [<c026b57d>] ? _raw_spin_trylock+0xa/0x3b
 [<c0390abe>] ? _spin_lock+0x2d/0x53
 [<c0156822>] ? unlink_file_vma+0x23/0x72
 [<c0156822>] ? unlink_file_vma+0x23/0x72
 [<c01554f1>] ? free_pgtables+0x4e/0x81
 [<c0156511>] ? exit_mmap+0x72/0xdb
 [<c0119aa2>] ? mmput+0x34/0x84
 [<c011cdf3>] ? exit_mm+0xb2/0xb8
 [<c011e3d0>] ? do_exit+0x1be/0x5d0
 [<c038e436>] ? printk+0xf/0x11
 [<c011b7b5>] ? oops_exit+0x23/0x28
 [<c0104005>] ? die+0x111/0x119
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
 [<c01666b9>] ? get_empty_filp+0x54/0x11d
 [<c016629f>] ? file_free_rcu+0xf/0x11
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c02809d5>] ? soft_cursor+0x81/0x1a0
 [<c0127e3f>] ? call_usermodehelper_freeinfo+0x1c/0x1f
 [<c031b0ed>] ? thermal_cooling_device_trip_point_show+0x0/0x2b
 [<c031bbb3>] ? thermal_zone_bind_cooling_device+0x92/0x1f7
 [<c0127e3f>] ? call_usermodehelper_freeinfo+0x1c/0x1f
 [<c0263b8d>] ? kset_release+0x0/0x2a
 [<c0263bb7>] ? dynamic_kobj_release+0x0/0x25
 [<c0174be8>] ? d_alloc+0x1e/0x189
 [<c0173d51>] ? d_callback+0x24/0x27
 [<c0174be8>] ? d_alloc+0x1e/0x189
 [<c0173d51>] ? d_callback+0x24/0x27
 [<c0174be8>] ? d_alloc+0x1e/0x189
 [<c0173d51>] ? d_callback+0x24/0x27
 [<c0174be8>] ? d_alloc+0x1e/0x189
 [<c0173d51>] ? d_callback+0x24/0x27
BUG: unable to handle kernel NULL pointer dereference at 0000000a
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00000000
Recursive die() failure, output suppressed
---[ end trace 85130c76b53cd30a ]---
Fixing recursive fault but reboot is needed!
BUG: scheduling while atomic: rtorrent/3654/0xf7346d34
INFO: lockdep is turned off.
Modules linked in: i2c_nforce2
irq event stamp: 703016042
hardirqs last  enabled at (703016041): [<c01362e3>] trace_hardirqs_on+0xb/0xd
hardirqs last disabled at (703016042): [<c013506b>] trace_hardirqs_off+0xb/0xd
softirqs last  enabled at (703015250): [<c011fd64>] __do_softirq+0x9c/0xa4
softirqs last disabled at (703015245): [<c0104a8e>] do_softirq+0x5f/0xb5
Pid: 3654, comm: rtorrent Tainted: G      D   2.6.26-rc8-next-20080704 #5
 [<c011848f>] __schedule_bug+0x5d/0x64
 [<c038e6f2>] schedule+0x7a/0x47d
 [<c0257884>] ? cfq_exit_single_io_context+0x38/0x3e
 [<c013506b>] ? trace_hardirqs_off+0xb/0xd
 [<c0141a1c>] ? __rcu_read_unlock+0x54/0x62
 [<c011e2ba>] do_exit+0xa8/0x5d0
 [<c038e436>] ? printk+0xf/0x11
 [<c011b7b5>] ? oops_exit+0x23/0x28
 [<c0104005>] die+0x111/0x119
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
 [<c02803a7>] ? bit_cursor+0x4e1/0x4f6
 [<c027a9b6>] ? fbcon_clear+0xfa/0x117
 [<c0110d8e>] ? __change_page_attr_set_clr+0x83/0x4e6
 [<c03909be>] ? _spin_unlock+0x27/0x3c
 [<c014ba74>] ? free_pages_bulk+0x1d6/0x213
 [<c0392685>] ? do_page_fault+0x0/0x6e5
 [<c039111a>] error_code+0x6a/0x70
 [<c026b57d>] ? _raw_spin_trylock+0xa/0x3b
 [<c0390abe>] _spin_lock+0x2d/0x53
 [<c0156822>] ? unlink_file_vma+0x23/0x72
 [<c0156822>] unlink_file_vma+0x23/0x72
 [<c01554f1>] free_pgtables+0x4e/0x81
 [<c0156511>] exit_mmap+0x72/0xdb
 [<c0119aa2>] mmput+0x34/0x84
 [<c011cdf3>] exit_mm+0xb2/0xb8
 [<c011e3d0>] do_exit+0x1be/0x5d0
 [<c038e436>] ? printk+0xf/0x11
 [<c011b7b5>] ? oops_exit+0x23/0x28
 [<c0104005>] die+0x111/0x119
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
 [<c01666b9>] ? get_empty_filp+0x54/0x11d
 [<c016629f>] ? file_free_rcu+0xf/0x11
BUG: unable to handle kernel paging request at 00200046
IP: [<c0103c53>] dump_trace+0xa5/0xe2
*pde = 00000000
Oops: 0000 [#5] PREEMPT DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:02:00.1/class
Modules linked in: i2c_nforce2

Pid: 3654, comm: rtorrent Tainted: G      D   (2.6.26-rc8-next-20080704 #5)
EIP: 0060:[<c0103c53>] EFLAGS: 00210093 CPU: 0
EIP is at dump_trace+0xa5/0xe2
EAX: 00200ffc EBX: 00200046 ECX: c0396978 EDX: c0455a08
ESI: f7d0de50 EDI: f3e49084 EBP: f3e481f4 ESP: f3e481d4
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process rtorrent (pid: 3654, ti=f3e48000 task=f7d0dd00 task.ti=f3e49000)
Stack: 00200ffc c0103b6f 00200000 f3e49084 00000020 00000002 f3e4823c f7d0df60
       f3e48208 c01045f5 f3e4823c c0396978 c047904c f3e4823c c038e33b f3e4823c
       c041ff98 00000e46 f7d0dff4 c050a434 c049959a 00000002 c04995db c042ae8e
Call Trace:

<And here there is calltrace for about 90000 strings>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
