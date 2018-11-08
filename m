Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
Message-ID: <trinity-7128b38b-7a1d-4584-aa34-174a2906ec88-1541694235634@3c-app-mailcom-bs15>
From: "Qian Cai" <cai@gmx.us>
Subject: BUG: sleeping function called from invalid context at mm/slab.h:421
Content-Type: text/plain; charset=UTF-8
Date: Thu, 8 Nov 2018 17:23:55 +0100
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just booting up the latest git master (b00d209) on an aarch64 server and saw this.

Nov  8 11:06:36 huawei-t2280-03 kernel: BUG: sleeping function called from invalid context at mm/slab.h:421
Nov  8 11:06:36 huawei-t2280-03 kernel: in_atomic(): 1, irqs_disabled(): 128, pid: 0, name: swapper/1
Nov  8 11:06:36 huawei-t2280-03 kernel: no locks held by swapper/1/0.
Nov  8 11:06:36 huawei-t2280-03 kernel: irq event stamp: 0
Nov  8 11:06:36 huawei-t2280-03 kernel: hardirqs last  enabled at (0): [<0000000000000000>]           (null)
Nov  8 11:06:36 huawei-t2280-03 kernel: hardirqs last disabled at (0): [<ffff2000080e24ec>] copy_process.isra.32.part.33+0x460/0x1534
Nov  8 11:06:36 huawei-t2280-03 kernel: softirqs last  enabled at (0): [<ffff2000080e24ec>] copy_process.isra.32.part.33+0x460/0x1534
Nov  8 11:06:36 huawei-t2280-03 kernel: softirqs last disabled at (0): [<0000000000000000>]           (null)
Nov  8 11:06:36 huawei-t2280-03 kernel: CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.20.0-rc1+ #3
Nov  8 11:06:36 huawei-t2280-03 kernel: Call trace:
Nov  8 11:06:36 huawei-t2280-03 kernel: dump_backtrace+0x0/0x190
Nov  8 11:06:36 huawei-t2280-03 kernel: show_stack+0x24/0x2c
Nov  8 11:06:36 huawei-t2280-03 kernel: dump_stack+0xa4/0xe0
Nov  8 11:06:36 huawei-t2280-03 kernel: ___might_sleep+0x208/0x234
Nov  8 11:06:36 huawei-t2280-03 kernel: __might_sleep+0x58/0x8c
Nov  8 11:06:36 huawei-t2280-03 kernel: kmem_cache_alloc_trace+0x29c/0x420
Nov  8 11:06:36 huawei-t2280-03 kernel: efi_mem_reserve_persistent+0x50/0xe8
Nov  8 11:06:36 huawei-t2280-03 kernel: its_cpu_init_lpis+0x298/0x2e0
Nov  8 11:06:36 huawei-t2280-03 kernel: its_cpu_init+0x7c/0x1a8
Nov  8 11:06:36 huawei-t2280-03 kernel: gic_starting_cpu+0x28/0x34
Nov  8 11:06:36 huawei-t2280-03 kernel: cpuhp_invoke_callback+0x104/0xd04
Nov  8 11:06:36 huawei-t2280-03 kernel: notify_cpu_starting+0x60/0xa0
Nov  8 11:06:36 huawei-t2280-03 kernel: secondary_start_kernel+0xcc/0x178

Any idea?
