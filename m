Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mAALgCEE017219
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 16:42:12 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAALgHle125412
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 16:42:17 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAALgGT3007816
	for <linux-mm@kvack.org>; Mon, 10 Nov 2008 16:42:16 -0500
Subject: 2.6.28-rc4 mem_cgroup_charge_common panic
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Mon, 10 Nov 2008 13:43:28 -0800
Message-Id: <1226353408.8805.12.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi KAME,

Thank you for the fix for online/offline page_cgroup panic.

While running memory offline/online tests ran into another
mem_cgroup panic.

Thanks,
Badari

Unable to handle kernel paging request for data at address 0x00000020
Faulting instruction address: 0xc0000000001055e4
Oops: Kernel access of bad area, sig: 11 [#2]
SMP NR_CPUS=32 NUMA pSeries
Modules linked in:
NIP: c0000000001055e4 LR: c00000000010557c CTR: c0000000000bfb74
REGS: c0000000f6c7f1b0 TRAP: 0300   Tainted: G      D     (2.6.28-rc4)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 44044422  XER: 20000018
DAR: 0000000000000020, DSISR: 0000000042000000
TASK = c0000000f6c56cc0[4610] 'crash' THREAD: c0000000f6c7c000 CPU: 0
GPR00: c0000000e910b560 c0000000f6c7f430 c000000000b36fc0 0000000000000001 
GPR04: c000000005355278 0000000000000001 0000000000000000 0000000000000000 
GPR08: c000000005355290 0000000000000018 c0000000e910b558 c0000000e910b548 
GPR12: 0000000000000000 c000000000b58300 00000400001ca30a 0000000000000000 
GPR16: 0000000000000000 0000000000000006 c0000000d43cb5c0 c0000000e66d0b88 
GPR20: 0000000000000004 0000000000000000 c0000000e64c6180 0000000000000000 
GPR24: 00000000000000d0 0000000000000005 c000000000bac418 0000000000000001 
GPR28: c0000000e910b538 c000000005355278 c000000000aacad8 c0000000f6c7f430 
NIP [c0000000001055e4] .mem_cgroup_charge_common+0x26c/0x330
LR [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330
Call Trace:
[c0000000f6c7f430] [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330 (unreliable)
[c0000000f6c7f4f0] [c000000000105c70] .mem_cgroup_cache_charge+0x130/0x154
[c0000000f6c7f590] [c0000000000c29bc] .add_to_page_cache_locked+0x64/0x18c
[c0000000f6c7f640] [c0000000000c2b64] .add_to_page_cache_lru+0x80/0xe4
[c0000000f6c7f6e0] [c000000000144348] .mpage_readpages+0xc8/0x170
[c0000000f6c7f810] [c000000000182e68] .reiserfs_readpages+0x50/0x78
[c0000000f6c7f8b0] [c0000000000cee80] .__do_page_cache_readahead+0x174/0x280
[c0000000f6c7f980] [c0000000000cf6e0] .do_page_cache_readahead+0xa4/0xd0
[c0000000f6c7fa20] [c0000000000c5274] .filemap_fault+0x198/0x420
[c0000000f6c7fb00] [c0000000000d9660] .__do_fault+0xb8/0x664
[c0000000f6c7fc10] [c0000000000dbcc4] .handle_mm_fault+0x1ec/0xaf4
[c0000000f6c7fd00] [c0000000005a8b10] .do_page_fault+0x384/0x570
[c0000000f6c7fe30] [c00000000000517c] handle_page_fault+0x20/0x5c
Instruction dump:
794a26e4 391d0018 38a00001 7d6be214 7d5c5214 7fa4eb78 e92b0048 380a0008 
39290001 f92b0048 60000000 e92a0008 <f9090008> f93d0018 f8080008 f90a0008 
---[ end trace aaa19ed35042c148 ]---
BUG: soft lockup - CPU#1 stuck for 61s! [udevd:1249]
Modules linked in:
NIP: c0000000005a69fc LR: c0000000005a69f4 CTR: c0000000000bfb74
REGS: c0000000e7f9b040 TRAP: 0901   Tainted: G      D     (2.6.28-rc4)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 80004424  XER: 20000018
TASK = c0000000e9b5ccc0[1249] 'udevd' THREAD: c0000000e7f98000 CPU: 1
GPR00: 00000000c0000000 c0000000e7f9b2c0 c000000000b36fc0 0000000000000001 
GPR04: c00000000010557c c0000000000bfb74 0000000000000000 0000000000000000 
GPR08: c000000000bd7700 00000000c0000000 00000000004d3000 c0000000007296c0 
GPR12: 000000000000d032 c000000000b58500 
NIP [c0000000005a69fc] ._spin_lock_irqsave+0x84/0xd4
LR [c0000000005a69f4] ._spin_lock_irqsave+0x7c/0xd4
Call Trace:
[c0000000e7f9b2c0] [c0000000005a69a0] ._spin_lock_irqsave+0x28/0xd4 (unreliable)
[c0000000e7f9b360] [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330
[c0000000e7f9b420] [c000000000105c70] .mem_cgroup_cache_charge+0x130/0x154
[c0000000e7f9b4c0] [c0000000000c29bc] .add_to_page_cache_locked+0x64/0x18c
[c0000000e7f9b570] [c0000000000c2b64] .add_to_page_cache_lru+0x80/0xe4
[c0000000e7f9b610] [c0000000000c2c34] .__grab_cache_page+0x6c/0xb4
[c0000000e7f9b6b0] [c000000000187628] .reiserfs_write_begin+0xb0/0x2bc
[c0000000e7f9b790] [c0000000000c38a8] .generic_file_buffered_write+0x150/0x354
[c0000000e7f9b8d0] [c0000000000c40a8] .__generic_file_aio_write_nolock+0x384/0x3fc
[c0000000e7f9b9d0] [c0000000000c41b0] .generic_file_aio_write+0x90/0x128
[c0000000e7f9ba90] [c0000000001093a4] .do_sync_write+0xe0/0x148
[c0000000e7f9bc30] [c000000000188868] .reiserfs_file_write+0x8c/0xd4
[c0000000e7f9bcd0] [c000000000109d00] .vfs_write+0xf0/0x1c4
[c0000000e7f9bd80] [c00000000010a69c] .sys_write+0x6c/0xb8
[c0000000e7f9be30] [c00000000000852c] syscall_exit+0x0/0x40
Instruction dump:
40a2fff0 4c00012c 2fa90000 41be0050 8b8d01da 2fbd0000 38600000 419e0008 
7fa3eb78 4ba65179 60000000 7c210b78 <801b0000> 2fa00000 40befff4 7c421378 
RCU detected CPU 1 stall (t=4299517593/1725750 jiffies)
Call Trace:
[c0000000e7f9aa00] [c0000000000102a4] .show_stack+0x94/0x198 (unreliable)
[c0000000e7f9aab0] [c0000000000103d0] .dump_stack+0x28/0x3c
[c0000000e7f9ab30] [c0000000000b1020] .__rcu_pending+0xa8/0x2c4
[c0000000e7f9abd0] [c0000000000b1288] .rcu_pending+0x4c/0xa0
[c0000000e7f9ac60] [c000000000076a8c] .update_process_times+0x50/0xa8
[c0000000e7f9ad00] [c000000000095e88] .tick_sched_timer+0xb0/0x100
[c0000000e7f9adb0] [c00000000008ae98] .__run_hrtimer+0xa4/0x13c
[c0000000e7f9ae50] [c00000000008c0b8] .hrtimer_interrupt+0x128/0x200
[c0000000e7f9af30] [c00000000002858c] .timer_interrupt+0xc0/0x11c
[c0000000e7f9afd0] [c000000000003710] decrementer_common+0x110/0x180
--- Exception: 901 at ._spin_lock_irqsave+0x84/0xd4
    LR = ._spin_lock_irqsave+0x7c/0xd4
[c0000000e7f9b2c0] [c0000000005a69a0] ._spin_lock_irqsave+0x28/0xd4 (unreliable)
[c0000000e7f9b360] [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330
[c0000000e7f9b420] [c000000000105c70] .mem_cgroup_cache_charge+0x130/0x154
[c0000000e7f9b4c0] [c0000000000c29bc] .add_to_page_cache_locked+0x64/0x18c
[c0000000e7f9b570] [c0000000000c2b64] .add_to_page_cache_lru+0x80/0xe4
[c0000000e7f9b610] [c0000000000c2c34] .__grab_cache_page+0x6c/0xb4
[c0000000e7f9b6b0] [c000000000187628] .reiserfs_write_begin+0xb0/0x2bc
[c0000000e7f9b790] [c0000000000c38a8] .generic_file_buffered_write+0x150/0x354
[c0000000e7f9b8d0] [c0000000000c40a8] .__generic_file_aio_write_nolock+0x384/0x3fc
[c0000000e7f9b9d0] [c0000000000c41b0] .generic_file_aio_write+0x90/0x128
[c0000000e7f9ba90] [c0000000001093a4] .do_sync_write+0xe0/0x148
[c0000000e7f9bc30] [c000000000188868] .reiserfs_file_write+0x8c/0xd4
[c0000000e7f9bcd0] [c000000000109d00] .vfs_write+0xf0/0x1c4
[c0000000e7f9bd80] [c00000000010a69c] .sys_write+0x6c/0xb8
[c0000000e7f9be30] [c00000000000852c] syscall_exit+0x0/0x40
RCU detected CPU 1 stall (t=4299525093/1733250 jiffies)
Call Trace:
[c0000000e7f9aa00] [c0000000000102a4] .show_stack+0x94/0x198 (unreliable)
[c0000000e7f9aab0] [c0000000000103d0] .dump_stack+0x28/0x3c
[c0000000e7f9ab30] [c0000000000b1020] .__rcu_pending+0xa8/0x2c4
[c0000000e7f9abd0] [c0000000000b1288] .rcu_pending+0x4c/0xa0
[c0000000e7f9ac60] [c000000000076a8c] .update_process_times+0x50/0xa8
[c0000000e7f9ad00] [c000000000095e88] .tick_sched_timer+0xb0/0x100
[c0000000e7f9adb0] [c00000000008ae98] .__run_hrtimer+0xa4/0x13c
[c0000000e7f9ae50] [c00000000008c0b8] .hrtimer_interrupt+0x128/0x200
[c0000000e7f9af30] [c00000000002858c] .timer_interrupt+0xc0/0x11c
[c0000000e7f9afd0] [c000000000003710] decrementer_common+0x110/0x180
--- Exception: 901 at ._spin_lock_irqsave+0x84/0xd4
    LR = ._spin_lock_irqsave+0x7c/0xd4
[c0000000e7f9b2c0] [c0000000005a69a0] ._spin_lock_irqsave+0x28/0xd4 (unreliable)
[c0000000e7f9b360] [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330
[c0000000e7f9b420] [c000000000105c70] .mem_cgroup_cache_charge+0x130/0x154
[c0000000e7f9b4c0] [c0000000000c29bc] .add_to_page_cache_locked+0x64/0x18c
[c0000000e7f9b570] [c0000000000c2b64] .add_to_page_cache_lru+0x80/0xe4
[c0000000e7f9b610] [c0000000000c2c34] .__grab_cache_page+0x6c/0xb4
[c0000000e7f9b6b0] [c000000000187628] .reiserfs_write_begin+0xb0/0x2bc
[c0000000e7f9b790] [c0000000000c38a8] .generic_file_buffered_write+0x150/0x354
[c0000000e7f9b8d0] [c0000000000c40a8] .__generic_file_aio_write_nolock+0x384/0x3fc
[c0000000e7f9b9d0] [c0000000000c41b0] .generic_file_aio_write+0x90/0x128
[c0000000e7f9ba90] [c0000000001093a4] .do_sync_write+0xe0/0x148
[c0000000e7f9bc30] [c000000000188868] .reiserfs_file_write+0x8c/0xd4
[c0000000e7f9bcd0] [c000000000109d00] .vfs_write+0xf0/0x1c4
[c0000000e7f9bd80] [c00000000010a69c] .sys_write+0x6c/0xb8
[c0000000e7f9be30] [c00000000000852c] syscall_exit+0x0/0x40
RCU detected CPU 1 stall (t=4299532593/1740750 jiffies)
Call Trace:
[c0000000e7f9aa00] [c0000000000102a4] .show_stack+0x94/0x198 (unreliable)
[c0000000e7f9aab0] [c0000000000103d0] .dump_stack+0x28/0x3c
[c0000000e7f9ab30] [c0000000000b1020] .__rcu_pending+0xa8/0x2c4
[c0000000e7f9abd0] [c0000000000b1288] .rcu_pending+0x4c/0xa0
[c0000000e7f9ac60] [c000000000076a8c] .update_process_times+0x50/0xa8
[c0000000e7f9ad00] [c000000000095e88] .tick_sched_timer+0xb0/0x100
[c0000000e7f9adb0] [c00000000008ae98] .__run_hrtimer+0xa4/0x13c
[c0000000e7f9ae50] [c00000000008c0b8] .hrtimer_interrupt+0x128/0x200
[c0000000e7f9af30] [c00000000002858c] .timer_interrupt+0xc0/0x11c
[c0000000e7f9afd0] [c000000000003710] decrementer_common+0x110/0x180
--- Exception: 901 at ._spin_lock_irqsave+0x84/0xd4
    LR = ._spin_lock_irqsave+0x7c/0xd4
[c0000000e7f9b2c0] [c0000000005a69a0] ._spin_lock_irqsave+0x28/0xd4 (unreliable)
[c0000000e7f9b360] [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330
[c0000000e7f9b420] [c000000000105c70] .mem_cgroup_cache_charge+0x130/0x154
[c0000000e7f9b4c0] [c0000000000c29bc] .add_to_page_cache_locked+0x64/0x18c
[c0000000e7f9b570] [c0000000000c2b64] .add_to_page_cache_lru+0x80/0xe4
[c0000000e7f9b610] [c0000000000c2c34] .__grab_cache_page+0x6c/0xb4
[c0000000e7f9b6b0] [c000000000187628] .reiserfs_write_begin+0xb0/0x2bc
[c0000000e7f9b790] [c0000000000c38a8] .generic_file_buffered_write+0x150/0x354
[c0000000e7f9b8d0] [c0000000000c40a8] .__generic_file_aio_write_nolock+0x384/0x3fc
[c0000000e7f9b9d0] [c0000000000c41b0] .generic_file_aio_write+0x90/0x128
[c0000000e7f9ba90] [c0000000001093a4] .do_sync_write+0xe0/0x148
[c0000000e7f9bc30] [c000000000188868] .reiserfs_file_write+0x8c/0xd4
[c0000000e7f9bcd0] [c000000000109d00] .vfs_write+0xf0/0x1c4
[c0000000e7f9bd80] [c00000000010a69c] .sys_write+0x6c/0xb8
[c0000000e7f9be30] [c00000000000852c] syscall_exit+0x0/0x40
Unable to handle kernel paging request for data at address 0x00000008
Faulting instruction address: 0xc0000000001055e4
Oops: Kernel access of bad area, sig: 11 [#3]
SMP NR_CPUS=32 NUMA pSeries
Modules linked in:
NIP: c0000000001055e4 LR: c00000000010557c CTR: c0000000000bfb74
REGS: c0000000f6c87720 TRAP: 0300   Tainted: G      D     (2.6.28-rc4)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 28044482  XER: 20000010
DAR: 0000000000000008, DSISR: 0000000042000000
TASK = c0000000f6bdecc0[4614] 'sshd' THREAD: c0000000f6c84000 CPU: 3
GPR00: c0000000e9009150 c0000000f6c879a0 c000000000b36fc0 0000000000000001 
GPR04: c000000005355688 0000000000000001 0000000000000001 0000000000000000 
GPR08: c0000000053556a0 0000000000000000 c0000000e9009148 c0000000e9009140 
GPR12: 0000000000000000 c000000000b58900 00000400000382d0 0000000000000006 
GPR16: 0000000000000000 0000000000000001 0000000000000001 c0000000e612e818 
GPR20: 00000fffffdba4e0 0000040000744d98 c0000000e66d2138 0000000000000001 
GPR24: 00000000000000d0 0000000000000005 c000000000bac418 0000000000000001 
GPR28: c0000000e9009138 c000000005355688 c000000000aacad8 c0000000f6c879a0 
NIP [c0000000001055e4] .mem_cgroup_charge_common+0x26c/0x330
LR [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330
Call Trace:
[c0000000f6c879a0] [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330 (unreliable)
[c0000000f6c87a60] [c0000000001057e4] .mem_cgroup_charge+0x9c/0xc8
[c0000000f6c87b00] [c0000000000d96fc] .__do_fault+0x154/0x664
[c0000000f6c87c10] [c0000000000dbcc4] .handle_mm_fault+0x1ec/0xaf4
[c0000000f6c87d00] [c0000000005a8b10] .do_page_fault+0x384/0x570
[c0000000f6c87e30] [c00000000000517c] handle_page_fault+0x20/0x5c
Instruction dump:
794a26e4 391d0018 38a00001 7d6be214 7d5c5214 7fa4eb78 e92b0048 380a0008 
39290001 f92b0048 60000000 e92a0008 <f9090008> f93d0018 f8080008 f90a0008 
---[ end trace aaa19ed35042c148 ]---
RCU detected CPU 1 stall (t=4299540093/1748250 jiffies)
Call Trace:
[c0000000e7f9aa00] [c0000000000102a4] .show_stack+0x94/0x198 (unreliable)
[c0000000e7f9aab0] [c0000000000103d0] .dump_stack+0x28/0x3c
[c0000000e7f9ab30] [c0000000000b1020] .__rcu_pending+0xa8/0x2c4
[c0000000e7f9abd0] [c0000000000b1288] .rcu_pending+0x4c/0xa0
[c0000000e7f9ac60] [c000000000076a8c] .update_process_times+0x50/0xa8
[c0000000e7f9ad00] [c000000000095e88] .tick_sched_timer+0xb0/0x100
[c0000000e7f9adb0] [c00000000008ae98] .__run_hrtimer+0xa4/0x13c
[c0000000e7f9ae50] [c00000000008c0b8] .hrtimer_interrupt+0x128/0x200
[c0000000e7f9af30] [c00000000002858c] .timer_interrupt+0xc0/0x11c
[c0000000e7f9afd0] [c000000000003710] decrementer_common+0x110/0x180
--- Exception: 901 at ._spin_lock_irqsave+0x84/0xd4
    LR = ._spin_lock_irqsave+0x7c/0xd4
[c0000000e7f9b2c0] [c0000000005a69a0] ._spin_lock_irqsave+0x28/0xd4 (unreliable)
[c0000000e7f9b360] [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330
[c0000000e7f9b420] [c000000000105c70] .mem_cgroup_cache_charge+0x130/0x154
[c0000000e7f9b4c0] [c0000000000c29bc] .add_to_page_cache_locked+0x64/0x18c
[c0000000e7f9b570] [c0000000000c2b64] .add_to_page_cache_lru+0x80/0xe4
[c0000000e7f9b610] [c0000000000c2c34] .__grab_cache_page+0x6c/0xb4
[c0000000e7f9b6b0] [c000000000187628] .reiserfs_write_begin+0xb0/0x2bc
[c0000000e7f9b790] [c0000000000c38a8] .generic_file_buffered_write+0x150/0x354
[c0000000e7f9b8d0] [c0000000000c40a8] .__generic_file_aio_write_nolock+0x384/0x3fc
[c0000000e7f9b9d0] [c0000000000c41b0] .generic_file_aio_write+0x90/0x128
[c0000000e7f9ba90] [c0000000001093a4] .do_sync_write+0xe0/0x148
[c0000000e7f9bc30] [c000000000188868] .reiserfs_file_write+0x8c/0xd4
[c0000000e7f9bcd0] [c000000000109d00] .vfs_write+0xf0/0x1c4
[c0000000e7f9bd80] [c00000000010a69c] .sys_write+0x6c/0xb8
[c0000000e7f9be30] [c00000000000852c] syscall_exit+0x0/0x40
BUG: soft lockup - CPU#0 stuck for 61s! [sshd:3665]
Modules linked in:
NIP: c0000000005a69fc LR: c0000000005a69f4 CTR: c0000000000bfb74
REGS: c0000000e667f6c0 TRAP: 0901   Tainted: G      D     (2.6.28-rc4)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 88004484  XER: 20000010
TASK = c0000000e9905980[3665] 'sshd' THREAD: c0000000e667c000 CPU: 0
GPR00: 0000000080000000 c0000000e667f940 c000000000b36fc0 0000000000000001 
GPR04: c00000000010557c c0000000000bfb74 0000000000000001 0000000000000000 
GPR08: c000000000bd7700 0000000080000000 00000000004cc000 c0000000007296c0 
GPR12: 0000000000000000 c000000000b58300 
NIP [c0000000005a69fc] ._spin_lock_irqsave+0x84/0xd4
LR [c0000000005a69f4] ._spin_lock_irqsave+0x7c/0xd4
Call Trace:
[c0000000e667f940] [c0000000005a69a0] ._spin_lock_irqsave+0x28/0xd4 (unreliable)
[c0000000e667f9e0] [c00000000010557c] .mem_cgroup_charge_common+0x204/0x330
[c0000000e667faa0] [c0000000001057e4] .mem_cgroup_charge+0x9c/0xc8
[c0000000e667fb40] [c0000000000da170] .do_wp_page+0x564/0x8ec
[c0000000e667fc10] [c0000000000dc500] .handle_mm_fault+0xa28/0xaf4
[c0000000e667fd00] [c0000000005a8b10] .do_page_fault+0x384/0x570
[c0000000e667fe30] [c00000000000517c] handle_page_fault+0x20/0x5c
Instruction dump:









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
