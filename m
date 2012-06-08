Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 8272F6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 20:37:48 -0400 (EDT)
Date: Thu, 7 Jun 2012 20:24:51 -0400
From: Dave Jones <davej@redhat.com>
Subject: a whole bunch of crashes since todays -mm merge.
Message-ID: <20120608002451.GA821@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

I just started seeing crashes while doing simple things, like logging on a console..

First there was this hard lockup.. https://twitpic.com/9tx3aw

and then on another boot..


[  330.714107] general protection fault: 0000 [#1] SMP 
[  330.719191] CPU 1 
[  330.720049] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat xt_LOG xt_limit ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack microcode pcspkr r8169 mii nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video backlight i2c_algo_bit drm_kms_helper drm [last unloaded: scsi_wait_scan]
[  330.720049] 
[  330.720049] Pid: 442, comm: dbus-daemon Not tainted 3.5.0-rc1+ #104                  /D510MO
[  330.720049] RIP: 0010:[<ffffffff8116cbc6>]  [<ffffffff8116cbc6>] anon_vma_clone+0x56/0x140
[  330.720049] RSP: 0018:ffff880069423cc0  EFLAGS: 00010282
[  330.720049] RAX: ffff88005cb948d0 RBX: ffff8800773998c0 RCX: 0000000000000030
[  330.720049] RDX: 0000000000002160 RSI: ffff880076b2d5d0 RDI: ffff880076b2cce0
[  330.720049] RBP: ffff880069423d00 R08: 0000000000000000 R09: 0000000000000000
[  330.720049] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800644a7a70
[  330.720049] R13: 0000000000000000 R14: ffff88005cb948d0 R15: 008453d500845391
[  330.720049] FS:  00007fb43c545800(0000) GS:ffff88007e800000(0000) knlGS:0000000000000000
[  330.720049] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  330.720049] CR2: 00000000021b5000 CR3: 0000000079270000 CR4: 00000000000007e0
[  330.720049] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  330.720049] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  330.720049] Process dbus-daemon (pid: 442, threadinfo ffff880069422000, task ffff880076b2cce0)
[  330.720049] Stack:
[  330.720049]  ffff88005cb907e0 ffff8800645d7df8 ffffffff81044e4b ffff8800773998c0
[  330.720049]  ffff8800645d7d88 ffff88005cb907e0 0000000000000001 ffff88005cb907e0
[  330.720049]  ffff880069423d30 ffffffff8116cce8 ffff8800773998c0 ffff8800645d7d88
[  330.720049] Call Trace:
[  330.720049]  [<ffffffff81044e4b>] ? dup_mm+0x1fb/0x600
[  330.720049]  [<ffffffff8116cce8>] anon_vma_fork+0x38/0x110
[  330.720049]  [<ffffffff81044eaa>] dup_mm+0x25a/0x600
[  330.720049]  [<ffffffff81046093>] copy_process.part.29+0xe03/0x1720
[  330.720049]  [<ffffffff8108b19f>] ? local_clock+0x4f/0x60
[  330.720049]  [<ffffffff810af44d>] ? trace_hardirqs_off+0xd/0x10
[  330.720049]  [<ffffffff81046b56>] do_fork+0x156/0x4d0
[  330.720049]  [<ffffffff81606c37>] ? sysret_check+0x1b/0x56
[  330.720049]  [<ffffffff8100bef8>] sys_clone+0x28/0x30
[  330.720049]  [<ffffffff81606f63>] stub_clone+0x13/0x20
[  330.720049]  [<ffffffff81606c12>] ? system_call_fastpath+0x16/0x1b
[  330.720049] Code: c6 4c 8d 60 f0 74 6f 66 0f 1f 44 00 00 48 8b 3d 01 5c 88 01 be 00 02 00 00 e8 b7 b0 01 00 48 85 c0 49 89 c6 74 61 4d 8b 7c 24 08 <49> 8b 1f 4c 39 eb 74 17 4d 85 ed 0f 85 89 00 00 00 48 8d 7b 08 
[  330.720049] RIP  [<ffffffff8116cbc6>] anon_vma_clone+0x56/0x140
[  330.720049]  RSP <ffff880069423cc0>
[  331.001495] ---[ end trace 7014228b5c0562c9 ]---

[  437.593174] =============================================================================
[  437.602303] BUG eventpoll_epi (Tainted: G      D     ): Redzone overwritten
[  437.602303] -----------------------------------------------------------------------------
[  437.602303] 
[  437.602303] INFO: 0xffff8800644aa288-0xffff8800644aa28f. First byte 0x4b instead of 0xbb
[  437.602303] INFO: Allocated in 0x847cae00847be7 age=18409436566142233285 cpu=101100 pid=101113
[  437.602303]         0x847e5000017e4d
[  437.602303]         0x17e8900847e52
[  437.602303]         0x17e8e00847e8c
[  437.602303]         0x847f5500017f44
[  437.602303]         0x180af0001809e
[  437.602303]         0x18245008480b2
[  437.602303]         0x182bd00018248
[  437.602303]         0x182df008482c0
[  437.602303]         0x18404008482e3
[  437.602303]         0x84852700018458
[  437.602303]         0x8485410001853f
[  437.602303]         0x186db000185f1
[  437.602303]         0x8486e4000186e2
[  437.602303]         0x188d9008486ef
[  437.602303]         0x84895800018955
[  437.602303]         0x18ae700018a22
[  437.602303] INFO: Freed in 0x18c9800848aff age=5668 cpu=0 pid=1
[  437.602303]         0x18c9b00018c9a
[  437.602303]         0x848c9e00858c9d
[  437.602303]         0x18eff00018d57
[  437.602303]         0x18f2400848f02
[  437.602303]         0x1909900018fa8
[  437.602303]         0x8491660001909f
[  437.602303]         0x1923d00849167
[  437.602303]         0x192a500849240
[  437.602303]         0x193c4008492ab
[  437.602303]         0x84945d00019439
[  437.602303] INFO: Slab 0xffffea0001912a80 objects=16 used=16 fp=0x          (null) flags=0x10000000004080
[  437.602303] INFO: Object 0xffff8800644aa200 @offset=512 fp=0x00017be400017bcb
[  437.602303] 
[  437.602303] Bytes b4 ffff8800644aa1f0: 1c 62 01 00 05 63 01 00 08 63 84 00 d0 63 84 00  .b...c...c...c..
[  437.602303] Object ffff8800644aa200: c9 64 01 00 66 65 01 00 69 65 84 00 6b 65 84 00  .d..fe..ie..ke..
[  437.602303] Object ffff8800644aa210: 69 66 01 00 ca 67 01 00 cd 67 84 00 55 68 01 00  if...g...g..Uh..
[  437.602303] Object ffff8800644aa220: 5c 68 01 00 61 69 01 00 66 69 01 00 2e 6a 84 00  \h..ai..fi...j..
[  437.602303] Object ffff8800644aa230: 5f 6b 01 00 d0 6b 01 00 d3 6b 84 00 d5 6b 84 00  _k...k...k...k..
[  437.602303] Object ffff8800644aa240: 73 6d 01 00 39 6e 84 00 cb 6f 01 00 ce 6f 84 00  sm..9n...o...o..
[  437.602303] Object ffff8800644aa250: d0 6f 84 00 47 71 01 00 6e 71 01 00 35 72 84 00  .o..Gq..nq..5r..
[  437.602303] Object ffff8800644aa260: d9 73 01 00 df 73 84 00 e0 73 84 00 8d 75 01 00  .s...s...s...u..
[  437.602303] Object ffff8800644aa270: 54 76 84 00 e9 77 01 00 ec 77 84 00 ed 77 84 00  Tv...w...w...w..
[  437.602303] Object ffff8800644aa280: 64 78 01 00 85 79 01 00                          dx...y..
[  437.602303] Redzone ffff8800644aa288: 4b 7a 84 00 ab 7a 01 00                          Kz...z..
[  437.602303] Padding ffff8800644aa3c8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  437.602303] Padding ffff8800644aa3d8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  437.602303] Padding ffff8800644aa3e8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  437.602303] Padding ffff8800644aa3f8: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
[  437.602303] Pid: 1031, comm: named Tainted: G      D      3.5.0-rc1+ #104
[  437.602303] Call Trace:
[  437.602303]  [<ffffffff81184c3d>] ? print_section+0x3d/0x40
[  437.602303]  [<ffffffff811857de>] print_trailer+0xfe/0x160
[  437.602303]  [<ffffffff81185972>] check_bytes_and_report+0xe2/0x120
[  437.602303]  [<ffffffff81185f3b>] check_object+0x18b/0x250
[  437.602303]  [<ffffffff811eab69>] ? sys_epoll_ctl+0x3c9/0x830
[  437.602303]  [<ffffffff815f52d0>] alloc_debug_processing+0x67/0x109
[  437.602303]  [<ffffffff815f5781>] __slab_alloc+0x40f/0x4b3
[  437.602303]  [<ffffffff811eab69>] ? sys_epoll_ctl+0x3c9/0x830
[  437.602303]  [<ffffffff811ea8d6>] ? sys_epoll_ctl+0x136/0x830
[  437.602303]  [<ffffffff810aec34>] ? mutex_remove_waiter+0x44/0x120
[  437.602303]  [<ffffffff815fa42c>] ? mutex_lock_nested+0x29c/0x360
[  437.602303]  [<ffffffff811eab69>] ? sys_epoll_ctl+0x3c9/0x830
[  437.602303]  [<ffffffff81187e7d>] kmem_cache_alloc+0x20d/0x240
[  437.602303]  [<ffffffff811a02f0>] ? fget_raw+0x310/0x310
[  437.602303]  [<ffffffff811eab69>] sys_epoll_ctl+0x3c9/0x830
[  437.602303]  [<ffffffff81305ebe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  437.602303]  [<ffffffff81606c12>] system_call_fastpath+0x16/0x1b
[  437.602303] FIX eventpoll_epi: Restoring 0xffff8800644aa288-0xffff8800644aa28f=0xbb
[  437.602303] 
[  437.602303] FIX eventpoll_epi: Marking all objects used
[  616.542210] general protection fault: 0000 [#2] SMP 
[  616.550030] CPU 1 
[  616.550030] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat xt_LOG xt_limit ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack microcode pcspkr r8169 mii nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video backlight i2c_algo_bit drm_kms_helper drm [last unloaded: scsi_wait_scan]
[  616.573575] 
[  616.573575] Pid: 1, comm: systemd Tainted: G      D      3.5.0-rc1+ #104                  /D510MO
[  616.573575] RIP: 0010:[<ffffffff811ea8ed>]  [<ffffffff811ea8ed>] sys_epoll_ctl+0x14d/0x830
[  616.573575] RSP: 0018:ffff88007b09ded8  EFLAGS: 00010202
[  616.573575] RAX: ffff8800769b6760 RBX: ffff880076a76100 RCX: dead000000200200
[  616.573575] RDX: ffff8800769b67f8 RSI: 2222222222222222 RDI: 2222222222222222
[  616.573575] RBP: ffff88007b09df78 R08: 00011ce800011c98 R09: 2222222222222222
[  616.573575] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000001
[  616.573575] R13: 000000000000000f R14: ffff88005cbf23c0 R15: ffffffffffffffea
[  616.573575] FS:  00007faff2643840(0000) GS:ffff88007e800000(0000) knlGS:0000000000000000
[  616.573575] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  616.573575] CR2: 00007fba1fadac86 CR3: 0000000076ae4000 CR4: 00000000000007e0
[  616.573575] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  616.573575] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  616.573575] Process systemd (pid: 1, threadinfo ffff88007b09c000, task ffff88007b0b0000)
[  616.573575] Stack:
[  616.573575]  702f646d65747379 ff00657461766972 0000000000000800 ffff88005cbf23e8
[  616.573575]  ffff88007b09df18 00000001815fe2db ffff8800769b67a8 ffff8800769b6760
[  616.573575]  ffff88007b09df78 0000000002d0c4f0 0000000002b6b6e0 ffffffff81305ebe
[  616.573575] Call Trace:
[  616.573575]  [<ffffffff81305ebe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  616.573575]  [<ffffffff81606c12>] system_call_fastpath+0x16/0x1b
[  616.573575] Code: 55 98 31 f6 48 83 c2 48 48 89 d7 48 89 55 90 e8 ba f8 40 00 48 8b 45 98 4c 8b 80 b0 01 00 00 0f 1f 80 00 00 00 00 4d 85 c0 74 1d <4d> 3b 70 30 77 0e 72 5b 44 89 e8 41 2b 40 38 83 f8 00 7e 4b 4d 
[  616.573575] RIP  [<ffffffff811ea8ed>] sys_epoll_ctl+0x14d/0x830
[  616.573575]  RSP <ffff88007b09ded8>
[  616.597321] ---[ end trace 7014228b5c0562ca ]---

and another boot..


[  319.667406] general protection fault: 0000 [#1] SMP 
[  319.672483] CPU 2 
[  319.674601] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat xt_LOG xt_limit ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack microcode pcspkr r8169 mii nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video backlight i2c_algo_bit drm_kms_helper drm [last unloaded: scsi_wait_scan]
[  319.676286] 
[  319.676286] Pid: 444, comm: dbus-daemon Not tainted 3.5.0-rc1+ #104                  /D510MO
[  319.676286] RIP: 0010:[<ffffffff8108ba6b>]  [<ffffffff8108ba6b>] effective_load.isra.25+0x5b/0xa0
[  319.676286] RSP: 0018:ffff8800646879c8  EFLAGS: 00010082
[  319.676286] RAX: 0000000000000000 RBX: ffff88007662d9c8 RCX: 0000000000000000
[  319.676286] RDX: 0000000000000003 RSI: 0001313f00012f3d RDI: ffff880069a996f8
[  319.676286] RBP: ffff8800646879c8 R08: fffffffffffffc00 R09: ffff880076abc4a8
[  319.676286] R10: 0000000000000002 R11: 0000000000000000 R12: fffffffffffffc00
[  319.676286] R13: 0000000000000002 R14: 0000000000000387 R15: 0000000000000003
[  319.676286] FS:  00007f5955e1f800(0000) GS:ffff88007ea00000(0000) knlGS:0000000000000000
[  319.676286] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  319.676286] CR2: 00007f8ec9dcb538 CR3: 0000000064752000 CR4: 00000000000007e0
[  319.676286] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  319.676286] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  319.676286] Process dbus-daemon (pid: 444, threadinfo ffff880064686000, task ffff8800698f4ce0)
[  319.676286] Stack:
[  319.676286]  ffff880064687a98 ffffffff8108d0f5 ffffffff8108c9e3 0000000000000046
[  319.676286]  0000000000000000 ffffffff81087f91 0000000000000002 ffff8800698f4ce0
[  319.676286]  ffff880064687a58 0000001000000046 0000000200000248 ffffffff00000001
[  319.676286] Call Trace:
[  319.676286]  [<ffffffff8108d0f5>] select_task_rq_fair+0x775/0xd10
[  319.676286]  [<ffffffff8108c9e3>] ? select_task_rq_fair+0x63/0xd10
[  319.676286]  [<ffffffff81087f91>] ? try_to_wake_up+0x31/0x350
[  319.676286]  [<ffffffff81087f91>] ? try_to_wake_up+0x31/0x350
[  319.676286]  [<ffffffff81088098>] try_to_wake_up+0x138/0x350
[  319.676286]  [<ffffffff810882c2>] default_wake_function+0x12/0x20
[  319.676286]  [<ffffffff811b45f6>] pollwake+0x66/0x70
[  319.676286]  [<ffffffff810882b0>] ? try_to_wake_up+0x350/0x350
[  319.676286]  [<ffffffff8107c965>] __wake_up_common+0x55/0x90
[  319.676286]  [<ffffffff8107ff87>] ? __wake_up_sync_key+0x37/0x80
[  319.676286]  [<ffffffff8107ffa3>] __wake_up_sync_key+0x53/0x80
[  319.676286]  [<ffffffff814b1d66>] sock_def_readable+0xa6/0x1e0
[  319.676286]  [<ffffffff814b1cc0>] ? sk_common_release+0xd0/0xd0
[  319.676286]  [<ffffffff815fe2db>] ? _raw_spin_unlock+0x2b/0x50
[  319.676286]  [<ffffffff8157f7fa>] unix_stream_sendmsg+0x21a/0x4a0
[  319.676286]  [<ffffffff814b0e88>] ? sock_update_classid+0x148/0x2e0
[  319.676286]  [<ffffffff814aa778>] sock_sendmsg+0xf8/0x130
[  319.676286]  [<ffffffff8108af25>] ? sched_clock_local+0x25/0xa0
[  319.676286]  [<ffffffff8108b0d8>] ? sched_clock_cpu+0xa8/0x120
[  319.676286]  [<ffffffff811a0a69>] ? fget_light+0xf9/0x520
[  319.676286]  [<ffffffff811a09ac>] ? fget_light+0x3c/0x520
[  319.676286]  [<ffffffff814ae000>] sys_sendto+0x130/0x180
[  319.676286]  [<ffffffff81606c37>] ? sysret_check+0x1b/0x56
[  319.676286]  [<ffffffff810b572d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[  319.676286]  [<ffffffff81305ebe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  319.676286]  [<ffffffff81606c12>] system_call_fastpath+0x16/0x1b
[  319.676286] Code: 81 80 00 00 00 31 d2 48 f7 f1 48 83 f8 01 49 0f 46 c2 48 2b 07 48 8b bf 40 01 00 00 45 31 c0 48 85 ff 74 3c 48 8b b7 50 01 00 00 <4c> 8b 8e 80 00 00 00 48 8b 16 49 63 89 88 00 00 00 48 01 d0 48 
[  319.676286] RIP  [<ffffffff8108ba6b>] effective_load.isra.25+0x5b/0xa0
[  319.676286]  RSP <ffff8800646879c8>
[  319.676286] ---[ end trace 360dbcc73fa5635a ]---
[  319.676286] BUG: sleeping function called from invalid context at kernel/rwsem.c:20
[  319.676286] in_atomic(): 1, irqs_disabled(): 1, pid: 444, name: dbus-daemon
[  319.676286] INFO: lockdep is turned off.
[  319.676286] irq event stamp: 38842
[  319.676286] hardirqs last  enabled at (38841): [<ffffffff815fe27f>] _raw_spin_unlock_irqrestore+0x3f/0x70
[  319.676286] hardirqs last disabled at (38842): [<ffffffff815fd7e5>] _raw_spin_lock_irqsave+0x25/0xa0
[  319.676286] softirqs last  enabled at (38724): [<ffffffff8157e96d>] unix_accept+0xfd/0x130
[  319.676286] softirqs last disabled at (38722): [<ffffffff815fdb68>] _raw_write_lock_bh+0x18/0x80
[  319.676286] Pid: 444, comm: dbus-daemon Tainted: G      D      3.5.0-rc1+ #104
[  319.676286] Call Trace:
[  319.676286]  [<ffffffff810b27d0>] ? print_irqtrace_events+0xd0/0xe0
[  319.676286]  [<ffffffff8108159e>] __might_sleep+0x17e/0x230
[  319.676286]  [<ffffffff815fb566>] down_read+0x26/0x93
[  319.676286]  [<ffffffff81061504>] exit_signals+0x24/0x130
[  319.676286]  [<ffffffff8104dc9c>] do_exit+0xbc/0xb90
[  319.676286]  [<ffffffff8104a913>] ? kmsg_dump+0x83/0x2c0
[  319.676286]  [<ffffffff815f222f>] ? printk+0x61/0x63
[  319.676286]  [<ffffffff815ff2a7>] oops_end+0x97/0xe0
[  319.676286]  [<ffffffff81005928>] die+0x58/0x90
[  319.676286]  [<ffffffff815fedc2>] do_general_protection+0x162/0x170
[  319.676286]  [<ffffffff815fe509>] ? restore_args+0x30/0x30
[  319.676286]  [<ffffffff815fe6af>] general_protection+0x1f/0x30
[  319.676286]  [<ffffffff8108ba6b>] ? effective_load.isra.25+0x5b/0xa0
[  319.676286]  [<ffffffff8108d0f5>] select_task_rq_fair+0x775/0xd10
[  319.676286]  [<ffffffff8108c9e3>] ? select_task_rq_fair+0x63/0xd10
[  319.676286]  [<ffffffff81087f91>] ? try_to_wake_up+0x31/0x350
[  319.676286]  [<ffffffff81087f91>] ? try_to_wake_up+0x31/0x350
[  319.676286]  [<ffffffff81088098>] try_to_wake_up+0x138/0x350
[  319.676286]  [<ffffffff810882c2>] default_wake_function+0x12/0x20
[  319.676286]  [<ffffffff811b45f6>] pollwake+0x66/0x70
[  319.676286]  [<ffffffff810882b0>] ? try_to_wake_up+0x350/0x350
[  319.676286]  [<ffffffff8107c965>] __wake_up_common+0x55/0x90
[  319.676286]  [<ffffffff8107ff87>] ? __wake_up_sync_key+0x37/0x80
[  319.676286]  [<ffffffff8107ffa3>] __wake_up_sync_key+0x53/0x80
[  319.676286]  [<ffffffff814b1d66>] sock_def_readable+0xa6/0x1e0
[  319.676286]  [<ffffffff814b1cc0>] ? sk_common_release+0xd0/0xd0
[  319.676286]  [<ffffffff815fe2db>] ? _raw_spin_unlock+0x2b/0x50
[  319.676286]  [<ffffffff8157f7fa>] unix_stream_sendmsg+0x21a/0x4a0
[  319.676286]  [<ffffffff814b0e88>] ? sock_update_classid+0x148/0x2e0
[  319.676286]  [<ffffffff814aa778>] sock_sendmsg+0xf8/0x130
[  319.676286]  [<ffffffff8108af25>] ? sched_clock_local+0x25/0xa0
[  319.676286]  [<ffffffff8108b0d8>] ? sched_clock_cpu+0xa8/0x120
[  319.676286]  [<ffffffff811a0a69>] ? fget_light+0xf9/0x520
[  319.676286]  [<ffffffff811a09ac>] ? fget_light+0x3c/0x520
[  319.676286]  [<ffffffff814ae000>] sys_sendto+0x130/0x180
[  319.676286]  [<ffffffff81606c37>] ? sysret_check+0x1b/0x56
[  319.676286]  [<ffffffff810b572d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[  319.676286]  [<ffffffff81305ebe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  319.676286]  [<ffffffff81606c12>] system_call_fastpath+0x16/0x1b
[  320.516002] note: dbus-daemon[444] exited with preempt_count 4
[  347.547155] =============================================================================
[  347.550793] BUG filp (Tainted: G      D     ): Poison overwritten
[  347.550793] -----------------------------------------------------------------------------
[  347.550793] 
[  347.550793] INFO: 0xffff880069bdd340-0xffff880069bdd3ab. First byte 0x2f instead of 0x6b
[  347.550793] INFO: Allocated in get_empty_filp+0x5d/0x230 age=2101 cpu=3 pid=807
[  347.550793] 	__slab_alloc+0x40f/0x4b3
[  347.550793] 	kmem_cache_alloc+0x20d/0x240
[  347.550793] 	get_empty_filp+0x5d/0x230
[  347.550793] 	alloc_file+0x2b/0x100
[  347.550793] 	sock_alloc_file+0xa8/0x130
[  347.550793] 	sock_map_fd+0x19/0x40
[  347.550793] 	sys_socket+0x40/0x70
[  347.550793] 	system_call_fastpath+0x16/0x1b
[  347.550793] INFO: Freed in file_free_rcu+0x47/0x70 age=2106 cpu=3 pid=0
[  347.550793] 	__slab_free+0x3d/0x254
[  347.550793] 	kmem_cache_free+0x219/0x230
[  347.550793] 	file_free_rcu+0x47/0x70
[  347.550793] 	__rcu_process_callbacks+0x19a/0x4e0
[  347.550793] 	rcu_process_callbacks+0x2f/0x260
[  347.550793] 	__do_softirq+0xd8/0x3a0
[  347.550793] 	call_softirq+0x1c/0x30
[  347.710144] 	do_softirq+0x8d/0xc0
[  347.710144] 	irq_exit+0xd5/0xe0
[  347.710144] 	smp_apic_timer_interrupt+0x6e/0x99
[  347.710144] 	apic_timer_interrupt+0x6c/0x80
[  347.710144] 	cpuidle_enter+0x19/0x20
[  347.710144] 	cpuidle_idle_call+0xa2/0x5d0
[  347.710144] 	cpu_idle+0xbf/0x130
[  347.710144] 	start_secondary+0x25c/0x25e
[  347.710144] INFO: Slab 0xffffea0001a6f700 objects=23 used=23 fp=0x          (null) flags=0x10000000004080
[  347.710144] INFO: Object 0xffff880069bdd340 @offset=4928 fp=0xffff880069bdd600
[  347.710144] 
[  347.710144] Bytes b4 ffff880069bdd330: b8 82 84 04 b9 82 84 04 ba 82 84 04 ba 82 01 00  ................
[  347.710144] Object ffff880069bdd340: 2f 83 84 04 2f 83 01 00 30 83 84 04 00 84 01 00  /.../...0.......
[  347.710144] Object ffff880069bdd350: f7 89 01 00 c7 8b 84 04 9a 8d 84 04 9b 8d 01 00  ................
[  347.710144] Object ffff880069bdd360: d9 a0 01 00 16 c3 01 00 f1 00 84 04 f2 00 01 00  ................
[  347.710144] Object ffff880069bdd370: f4 00 01 00 1e 02 84 04 22 02 84 04 23 02 01 00  ........"...#...
[  347.710144] Object ffff880069bdd380: 26 02 01 00 f4 03 84 04 f5 03 84 04 f6 03 01 00  &...............
[  347.710144] Object ffff880069bdd390: d6 2b 01 00 a5 2d 84 04 99 65 84 04 9a 65 84 04  .+...-...e...e..
[  347.710144] Object ffff880069bdd3a0: 9b 65 01 00 c7 66 84 04 d4 78 01 00 6b 6b 6b 6b  .e...f...x..kkkk
[  347.710144] Object ffff880069bdd3b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd3c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd3d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd3e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd3f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd400: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd410: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd420: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd430: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd440: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd450: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd460: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd470: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd480: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  347.710144] Object ffff880069bdd490: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  347.710144] Redzone ffff880069bdd4a0: bb bb bb bb bb bb bb bb                          ........
[  347.710144] Padding ffff880069bdd5e0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  347.710144] Padding ffff880069bdd5f0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  347.710144] Pid: 807, comm: snmpd Tainted: G      D      3.5.0-rc1+ #104
[  347.710144] Call Trace:
[  347.710144]  [<ffffffff81184c3d>] ? print_section+0x3d/0x40
[  347.710144]  [<ffffffff811857de>] print_trailer+0xfe/0x160
[  347.710144]  [<ffffffff81185972>] check_bytes_and_report+0xe2/0x120
[  347.710144]  [<ffffffff81185f7f>] check_object+0x1cf/0x250
[  347.710144]  [<ffffffff811a069d>] ? get_empty_filp+0x5d/0x230
[  347.710144]  [<ffffffff815f52d0>] alloc_debug_processing+0x67/0x109
[  347.710144]  [<ffffffff815f5781>] __slab_alloc+0x40f/0x4b3
[  347.710144]  [<ffffffff811a069d>] ? get_empty_filp+0x5d/0x230
[  347.710144]  [<ffffffff811b7262>] ? __d_instantiate+0x82/0xf0
[  347.710144]  [<ffffffff811a069d>] ? get_empty_filp+0x5d/0x230
[  347.710144]  [<ffffffff81187e7d>] kmem_cache_alloc+0x20d/0x240
[  347.710144]  [<ffffffff811a069d>] get_empty_filp+0x5d/0x230
[  347.710144]  [<ffffffff811a089b>] alloc_file+0x2b/0x100
[  347.710144]  [<ffffffff814aa9b8>] sock_alloc_file+0xa8/0x130
[  347.710144]  [<ffffffff814aaa59>] sock_map_fd+0x19/0x40
[  347.710144]  [<ffffffff814ad600>] sys_socket+0x40/0x70
[  347.710144]  [<ffffffff81606c12>] system_call_fastpath+0x16/0x1b
[  347.710144] FIX filp: Restoring 0xffff880069bdd340-0xffff880069bdd3ab=0x6b
[  347.710144] 
[  347.710144] FIX filp: Marking all objects used

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
