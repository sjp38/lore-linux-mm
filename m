Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C1BEA8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 03:18:46 -0400 (EDT)
Received: by gyg10 with SMTP id 10so3460849gyg.14
        for <linux-mm@kvack.org>; Wed, 23 Mar 2011 00:18:44 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 23 Mar 2011 10:18:44 +0300
Message-ID: <AANLkTinkeB=TxCaM3UjLoyM5Qaf9zyvRJ+tX0inFnuZr@mail.gmail.com>
Subject: 2.6.39-rc: panic at rcu_kthread()
From: Alexander Beregalov <a.beregalov@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi

I do not have a testcase to reproduce it.
Kernel is 2.6.38-07035-g6447f55d

BUG (null): Not a valid slab page
-----------------------------------------------------------------------------
INFO: Slab 0xf6c1dcc0 objects=65535 used=65535 fp=0x  (null) flags=0x40000401
Pid: 6, comm: rcu_kthread Tainted: G        W   2.6.38-07035-g6447f55d #1
Call Trace:
 [<c1366f9f>] ? printk+0x18/0x21
 [<c109866c>] slab_err+0x6c/0x80
 [<c1098a2f>] ? slab_pad_check+0x2f/0x150
 [<c1098a2f>] ? slab_pad_check+0x2f/0x150
 [<c1047b2d>] ? sched_clock_cpu+0x7d/0xf0
 [<c1098c1c>] check_slab+0xcc/0x120
 [<c1099408>] ? init_object+0x38/0x70
 [<c1066125>] ? rcu_process_callbacks+0x55/0x90
 [<c10999fa>] free_debug_processing+0x1a/0x220
 [<c105197b>] ? trace_hardirqs_off+0xb/0x10
 [<c10544d9>] ? debug_check_no_locks_freed+0x129/0x140
 [<c1066125>] ? rcu_process_callbacks+0x55/0x90
 [<c1099cac>] __slab_free+0xac/0x140
 [<c13079f0>] ? inetpeer_free_rcu+0x10/0x20
 [<c1066125>] ? rcu_process_callbacks+0x55/0x90
 [<c1099f7b>] kmem_cache_free+0xeb/0x100
 [<c13079f0>] ? inetpeer_free_rcu+0x10/0x20
 [<c13079f0>] ? inetpeer_free_rcu+0x10/0x20
 [<c109efd0>] ? file_free_rcu+0x0/0x30
 [<c13079f0>] inetpeer_free_rcu+0x10/0x20
 [<c106612a>] ? rcu_process_callbacks+0x5a/0x90
 [<c1066245>] ? rcu_kthread+0xe5/0x100
 [<c1042100>] ? autoremove_wake_function+0x0/0x50
 [<c1066160>] ? rcu_kthread+0x0/0x100
 [<c1041e14>] ? kthread+0x74/0x80
 [<c1041da0>] ? kthread+0x0/0x80
 [<c136f5fa>] ? kernel_thread_helper+0x6/0xd
FIX (null): Object at 0xc1066125 not freed
BUG: unable to handle kernel NULL pointer dereference at 00000002
IP: [<f64665e0>] 0xf64665e0
*pde = 00000000
Oops: 0002 [#1]
last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
Modules linked in: hwmon_vid sata_sil i2c_nforce2

Pid: 6, comm: rcu_kthread Tainted: G        W   2.6.38-07035-g6447f55d
#1    /NF7-S/NF7,NF7-V (nVidia-nForce2)
EIP: 0060:[<f64665e0>] EFLAGS: 00010286 CPU: 0
EIP is at 0xf64665e0
EAX: 00000002 EBX: db384030 ECX: 00000000 EDX: 00000000
ESI: d8805700 EDI: 00000283 EBP: c106612a ESP: f6479f58
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process rcu_kthread (pid: 6, ti=f6478000 task=f64665e0 task.ti=f6478000)
Stack:
 f6479f74 f6479f80 f6479f94 c1066245 00000001 f64665e0 00000202 00000000
 f64665e0 c1042100 f6479f80 f6479f80 f6469f30 00000000 c1066160 f6479fe4
 c1041e14 00000000 00000000 00000000 00000001 dead4ead ffffffff ffffffff
Call Trace:
 [<c1066245>] ? rcu_kthread+0xe5/0x100
 [<c1042100>] ? autoremove_wake_function+0x0/0x50
 [<c1066160>] ? rcu_kthread+0x0/0x100
 [<c1041e14>] ? kthread+0x74/0x80
 [<c1041da0>] ? kthread+0x0/0x80
 [<c136f5fa>] ? kernel_thread_helper+0x6/0xd
Code: 94 02 c1 00 00 00 00 1b 08 00 00 bf c8 02 00 89 8c 02 c1 00 00
00 00 06 00 00 00 8c c8 02 00 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
00 00 00 00 80 47 f6 02 00 00 00 40 a0 20 80 00 00 00 00 ff
EIP: [<f64665e0>] 0xf64665e0 SS:ESP 0068:f6479f58
CR2: 0000000000000002
---[ end trace 8a45d2bc24cd677d ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 6, comm: rcu_kthread Tainted: G      D W   2.6.38-07035-g6447f55d #1
Call Trace:
 [<c1366f9f>] ? printk+0x18/0x21
 [<c1366e9e>] panic+0x57/0x140
 [<c136afcf>] oops_end+0x8f/0x90
 [<c101b284>] no_context+0xb4/0x150
 [<c101b3ad>] __bad_area_nosemaphore+0x8d/0x130
 [<c104fbea>] ? tick_dev_program_event+0x3a/0x130
 [<c136cc7e>] ? do_page_fault+0x1ee/0x480
 [<c136ca90>] ? do_page_fault+0x0/0x480
 [<c136ca90>] ? do_page_fault+0x0/0x480
 [<c101b462>] bad_area_nosemaphore+0x12/0x20
 [<c136cd6c>] do_page_fault+0x2dc/0x480
 [<c103020d>] ? irq_exit+0x3d/0x90
 [<c136a24c>] ? restore_all_notrace+0x0/0x18
 [<c11e0134>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c136a24c>] ? restore_all_notrace+0x0/0x18
 [<c1066125>] ? rcu_process_callbacks+0x55/0x90
 [<c106612a>] ? rcu_process_callbacks+0x5a/0x90
 [<c136ca90>] ? do_page_fault+0x0/0x480
 [<c106612a>] ? rcu_process_callbacks+0x5a/0x90
 [<c136a5d1>] error_code+0x5d/0x64
 [<c106612a>] ? rcu_process_callbacks+0x5a/0x90
 [<c136ca90>] ? do_page_fault+0x0/0x480
 [<c1066245>] ? rcu_kthread+0xe5/0x100
 [<c1042100>] ? autoremove_wake_function+0x0/0x50
 [<c1066160>] ? rcu_kthread+0x0/0x100
 [<c1041e14>] ? kthread+0x74/0x80
 [<c1041da0>] ? kthread+0x0/0x80
 [<c136f5fa>] ? kernel_thread_helper+0x6/0xd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
