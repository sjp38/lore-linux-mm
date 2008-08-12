Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m7CHWM8O009816
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 23:02:22 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7CHWLj91749044
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 23:02:21 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m7CHWKRI022012
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 23:02:21 +0530
Message-ID: <48A1C924.6020000@linux.vnet.ibm.com>
Date: Tue, 12 Aug 2008 23:02:20 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [BUG] linux-next: Tree for August 11/12 - powerpc - oops at __kmalloc_node_track_caller
 ()
References: <20080812185345.d7496513.sfr@canb.auug.org.au>
In-Reply-To: <20080812185345.d7496513.sfr@canb.auug.org.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,

2.6.27-rc2-next20080811/12 kernel oopses at various places,
while booting up on the powerpc box

eth0      device: Intel Corporation 82545EM Gigabit Ethernet Controller (Copper) (rev 01)
eth0      configuration: eth-Unable to handle kernel paging request for data at address 0xc00000077cb7a8
Faulting instruction address: 0xc0000000000df740
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=128 NUMA pSeries
Modules linked in:
NIP: c0000000000df740 LR: c0000000000df6d0 CTR: 0000000000000000
REGS: c00000077e22b090 TRAP: 0300   Not tainted  (2.6.27-rc2-next-20080811-autotest)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24000242  XER: 20000000
DAR: 00c00000077cb7a8, DSISR: 0000000040000000
TASK = c00000077b112bc0[3336] 'ip' THREAD: c00000077e228000 CPU: 0
GPR00: 0000000000000000 c00000077e22b310 c000000000872120 c00000000089a0d0 
GPR04: 0000000000000020 ffffffffffffffff c00000000042c5dc c00000000095d2c8 
GPR08: 0000000000000000 c00000000089a0d0 c00000077b006000 c00000000089a0d0 
GPR12: 0000000000000000 c0000000008a4300 000000001002326c 000000001002487c 
GPR16: 0000000010021480 0000000010020454 0000000010020000 c00000077e2d0000 
GPR20: 00000000000000ef c00000077b021a80 c00000077e041800 00000000000005f2 
GPR24: 0000000000000000 0000000000000800 0000000000000020 c00000000042c5dc 
GPR28: 0000000000000001 ffffffffffffffff c000000000805440 00c00000077cb7a8 
NIP [c0000000000df740] .__kmalloc_node_track_caller+0xd4/0x144
LR [c0000000000df6d0] .__kmalloc_node_track_caller+0x64/0x144
Call Trace:
[c00000077e22b310] [c00000077e22b3c0] 0xc00000077e22b3c0 (unreliable)
[c00000077e22b3c0] [c00000000042afc4] .__alloc_skb+0x98/0x184
[c00000077e22b470] [c00000000042c5dc] .__netdev_alloc_skb+0x3c/0x74
[c00000077e22b4f0] [c0000000002f0388] .e1000_alloc_rx_buffers+0xa0/0x3dc
[c00000077e22b5d0] [c0000000002eb6a0] .e1000_configure+0x5c0/0x610
[c00000077e22b670] [c0000000002ed740] .e1000_open+0xc0/0x248
[c00000077e22b710] [c000000000434b0c] .dev_open+0xe8/0x158
[c00000077e22b7a0] [c000000000432fa8] .dev_change_flags+0x104/0x204
[c00000077e22b840] [c000000000486de8] .devinet_ioctl+0x2c4/0x758
[c00000077e22b940] [c000000000487d70] .inet_ioctl+0xd8/0x12c
[c00000077e22b9c0] [c000000000423f64] .sock_ioctl+0x29c/0x2f0
[c00000077e22ba60] [c0000000000f5f3c] .vfs_ioctl+0x5c/0xf0
[c00000077e22bb00] [c0000000000f63ac] .do_vfs_ioctl+0x3dc/0x418
[c00000077e22bbb0] [c0000000000f6434] .sys_ioctl+0x4c/0x88
[c00000077e22bc60] [c000000000129b58] .dev_ifsioc+0x134/0x2f4
[c00000077e22bd40] [c000000000129304] .compat_sys_ioctl+0x394/0x424
[c00000077e22be30] [c0000000000086ac] syscall_exit+0x0/0x40
Instruction dump:
80070010 7f80e800 41be0020 7d635b78 7fa5eb78 7f66db78 7f44d378 4bffe16d 
7c7f1b78 48000014 80070014 78001f24 <7c1f002a> f8070000 2fbc0000 38600000 
---[ end trace 1ee5b1711a7e1dbb ]---

7:4a
Unable to handle kernel paging request for data at address 0xc00000077cb7a8
Faulting instruction address: 0xc0000000000dff5c
Oops: Kernel access of bad area, sig: 11 [#2]
SMP NR_CPUS=128 NUMA pSeries
Modules linked in:
NIP: c0000000000dff5c LR: c0000000000dff04 CTR: 0000000000000004
REGS: c00000077e5e3730 TRAP: 0300   Tainted: G      D    (2.6.27-rc2-next-20080811-autotest)
MSR: 800000000000b032 <EE,FP,ME,IR,DR>  CR: 24282444  XER: 20000000
DAR: 00c00000077cb7a8, DSISR: 0000000040000000
TASK = c00000077b111a40[3341] 'ifup-route' THREAD: c00000077e5e0000 CPU: 0
GPR00: 0000000000000000 c00000077e5e39b0 c000000000872120 c00000000089a0d0 
GPR04: 00000000000000d0 ffffffffffffffff c000000000101e00 c00000000095d2c8 
GPR08: c00000077e7ace90 c00000000089a0d0 c00000077e7ace88 c00000000089a0d0 
GPR12: 000000000000f032 c0000000008a4300 0000000000000000 0000000000000001 
GPR16: 00000000ffffffff 0000000000000000 c00000077e5e3ea0 00000000ff91eb90 
GPR20: 0000000000000000 c00000077e7ace00 c00000077cc8e600 c00000077e7ace00 
GPR24: 0000000000000100 0000000000000100 0000000000000800 00000000000000d0 
GPR28: c000000000101e28 0000000000000001 c0000000007ec530 00c00000077cb7a8 
NIP [c0000000000dff5c] .__kmalloc+0xc0/0x130
LR [c0000000000dff04] .__kmalloc+0x68/0x130
Call Trace:
[c00000077e5e39b0] [c00000000002f1f0] .htab_call_hpte_insert1+0x4/0x38 (unreliable)
[c00000077e5e3a50] [c000000000101e28] .alloc_fdtable+0x9c/0x174
[c00000077e5e3ae0] [c000000000102640] .dup_fd+0x15c/0x3a4
[c00000077e5e3bc0] [c0000000000540b0] .copy_process+0x51c/0x10fc
[c00000077e5e3cc0] [c000000000054f84] .do_fork+0x140/0x300
[c00000077e5e3db0] [c000000000010144] .sys_clone+0x5c/0x74
[c00000077e5e3e30] [c0000000000088e0] .ppc_clone+0x8/0xc
Instruction dump:
ebe70000 83470018 2fbf0000 40be001c 7f86e378 7f64db78 38a0ffff 4bffd951 
7c7f1b78 48000014 80070014 78001f24 <7c1f002a> f8070000 2fbd0000 38600000 
---[ end trace 1ee5b1711a7e1dbb ]---

/sbin/ifup: lineUnable to handle kernel paging request for data at address 0xc00000077cb7a8
Faulting instruction address: 0xc0000000000dff5c
Oops: Kernel access of bad area, sig: 11 [#3]
SMP NR_CPUS=128 NUMA pSeries
Modules linked in:
NIP: c0000000000dff5c LR: c0000000000dff04 CTR: 0000000000000004
REGS: c00000077b017730 TRAP: 0300   Tainted: G      D    (2.6.27-rc2-next-20080811-autotest)
MSR: 800000000000b032 <EE,FP,ME,IR,DR>  CR: 24222444  XER: 20000000
DAR: 00c00000077cb7a8, DSISR: 0000000040000000
TASK = c00000077e38c600[3291] 'ifup' THREAD: c00000077b014000 CPU: 0
GPR00: 0000000000000000 c00000077b0179b0 c000000000872120 c00000000089a0d0 
GPR04: 00000000000000d0 ffffffffffffffff c000000000101e00 c00000000095d2c8 
GPR08: c00000077e7ad490 c00000000089a0d0 c00000077e7ad488 c00000000089a0d0 
GPR12: 000000000000f032 c0000000008a4300 0000000010080000 0000000000000000 
GPR16: 00000000100a0000 0000000000000000 c00000077b017ea0 00000000ff9711a0 
GPR20: 0000000000000000 c00000077e7ad400 c00000077cceb000 c00000077e7ad400 
GPR24: 0000000000000100 0000000000000100 0000000000000800 00000000000000d0 
GPR28: c000000000101e28 0000000000000001 c0000000007ec530 00c00000077cb7a8 
NIP [c0000000000dff5c] .__kmalloc+0xc0/0x130
LR [c0000000000dff04] .__kmalloc+0x68/0x130
Call Trace:
[c00000077b0179b0] [c0000000007e6b18] net_sysctl_ro_root+0xb688/0x263e0 (unreliable)
[c00000077b017a50] [c000000000101e28] .alloc_fdtable+0x9c/0x174
[c00000077b017ae0] [c000000000102640] .dup_fd+0x15c/0x3a4
[c00000077b017bc0] [c0000000000540b0] .copy_process+0x51c/0x10fc
[c00000077b017cc0] [c000000000054f84] .do_fork+0x140/0x300
[c00000077b017db0] [c000000000010144] .sys_clone+0x5c/0x74
[c00000077b017e30] [c0000000000088e0] .ppc_clone+0x8/0xc
Instruction dump:
ebe70000 83470018 2fbf0000 40be001c 7f86e378 7f64db78 38a0ffff 4bffd951 
7c7f1b78 48000014 80070014 78001f24 <7c1f002a> f8070000 2fbd0000 38600000 
---[ end trace 1ee5b1711a7e1dbb ]---

Unable to handle kernel paging request for data at address 0xc00000077cb7a8
Faulting instruction address: 0xc0000000000dff5c
Oops: Kernel access of bad area, sig: 11 [#6]
SMP NR_CPUS=128 NUMA pSeries
Modules linked in:
NIP: c0000000000dff5c LR: c0000000000dff04 CTR: c0000000000f5d44
REGS: c00000077e5f3930 TRAP: 0300   Tainted: G      D    (2.6.27-rc2-next-20080811-autotest)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 22002444  XER: 20000000
DAR: 00c00000077cb7a8, DSISR: 0000000040000000
TASK = c00000077b110000[3347] 'syslog' THREAD: c00000077e5f0000 CPU: 0
GPR00: 0000000000000000 c00000077e5f3bb0 c000000000872120 c00000000089a0d0 
GPR04: 00000000000000d0 ffffffffffffffff c000000000101e00 c00000000095d2c8 
GPR08: 000000000000f032 c00000000089a0d0 c0000000000f5d44 c00000000089a0d0 
GPR12: 000000000000f032 c0000000008a4300 00000000000000a9 0000000000000018 
GPR16: 00000000ffffffff 0000000000000007 0000000000000000 0000000000000014 
GPR20: 0000000010010000 00000000ffe91994 0000000000099a1b 0000000010010000 
GPR24: 00000000f7fddb60 c00000077cc8bc00 0000000000000800 00000000000000d0 
GPR28: c000000000101e28 0000000000000001 c0000000007ec530 00c00000077cb7a8 
NIP [c0000000000dff5c] .__kmalloc+0xc0/0x130
LR [c0000000000dff04] .__kmalloc+0x68/0x130
Call Trace:
[c00000077e5f3bb0] [c00000077e29c0b0] 0xc00000077e29c0b0 (unreliable)
[c00000077e5f3c50] [c000000000101e28] .alloc_fdtable+0x9c/0x174
[c00000077e5f3ce0] [c000000000101f98] .expand_files+0x98/0x28c
[c00000077e5f3d90] [c0000000000f5ba8] .sys_dup3+0x60/0x1fc
[c00000077e5f3e30] [c0000000000086ac] syscall_exit+0x0/0x40
Instruction dump:
ebe70000 83470018 2fbf0000 40be001c 7f86e378 7f64db78 38a0ffff 4bffd951 
7c7f1b78 48000014 80070014 78001f24 <7c1f002a> f8070000 2fbd0000 38600000 
---[ end trace 1ee5b1711a7e1dbb ]---

Unable to handle kernel paging request for data at address 0xc00000077cb7a8
Faulting instruction address: 0xc0000000000de37c
Oops: Kernel access of bad area, sig: 11 [#16]
SMP NR_CPUS=128 NUMA Starting SSH daepSeries
Modules linked in:
NIP: c0000000000de37c LR: c0000000000ab7bc CTR: c0000000000ab7a0
REGS: c00000077b016d50 TRAP: 0300   Tainted: G      D    (2.6.27-rc2-next-20080811-autotest)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 44224484  XER: 20000000
DAR: 00c00000077cb7a8, DSISR: 0000000040000000
TASK = c00000077b113480[3360] 'kbd' THREAD: c00000077b014000 CPU: 0
GPR00: 0000000000000000 c00000077b016fd0 c000000000872120 c00000000089a0d0 
GPR04: 0000000000011220 ffffffffffffffff c0000000000ab7bc c00000000095d2c8 
GPR08: c00000077cbf3058 c00000000095d2c8 0000000000000620 0000000000000000 
GPR12: c00000077cc6c800 c0000000008a4300 0000000000000000 0000000000000001 
GPR16: 00000000100a0000 00000000100a0000 0000000000000000 c00000077d410c88 
GPR20: c00000077cbf3058 000000000000007f 0000000000000fe0 0000000000000080 
GPR24: c00000000084bc88 c00000077b095410 0000000000000000 0000000000011220 
GPR28: 0000000000000800 0000000000000000 c0000000007ea4f0 00c00000077cb7a8 
NIP [c0000000000de37c] .kmem_cache_alloc+0x6c/0xd4
LR [c0000000000ab7bc] .mempool_alloc_slab+0x1c/0x30
Call Trace:
[c00000077b016fd0] [c00000077d410c88] 0xc00000077d410c88 (unreliable)
[c00000077b017070] [c0000000000ab7bc] .mempool_alloc_slab+0x1c/0x30
[c00000077b0170f0] [c0000000000ab9a8] .mempool_alloc+0x64/0x158
[c00000077b0171c0] [c000000000351c80] .scsi_sg_alloc+0x74/0x8c
[c00000077b017240] [c000000000264bec] .__sg_alloc_table+0xa8/0x180
[c00000077b017310] [c000000000351b60] .scsi_init_sgtable+0x48/0xf4
[c00000077b0173a0] [c000000000351f48] .scsi_init_io+0x30/0xf0
[c00000077b017430] [c000000000389764] .sd_prep_fn+0x8c/0x608
[c00000077b017500] [c000000000243958] .elv_next_request+0x13c/0x260
[c00000077b0175a0] [c0000000003537bc] .scsi_request_fn+0x98/0x470
[c00000077b017650] [c0000000002461fc] .__generic_unplug_device+0x54/0x6c
[c00000077b0176d0] [c0000000002472c8] .generic_unplug_device+0x3c/0x84
[c00000077b017750] [c000000000244534] .blk_unplug+0x30/0x44
[c00000077b0177d0] [c00000000011363c] .block_sync_page+0x78/0x90
[c00000077b017850] [c0000000000a85c4] .sync_page+0x74/0x98
[c00000077b0178d0] [c0000000004d5fc8] .__wait_on_bit_lock+0x94/0x11c
[c00000077b017980] [c0000000000a850c] .__lock_page+0xbc/0xd8
[c00000077b017a90] [c0000000000a8844] .find_lock_page+0x5c/0xa0
[c00000077b017b20] [c0000000000ab398] .filemap_fault+0x198/0x40c
[c00000077b017c00] [c0000000000bbf94] .__do_fault+0xa0/0x51c
[c00000077b017d00] [c0000000004d9f48] .do_page_fault+0x3b4/0x598
[c00000077b017e30] [c0000000000051fc] handle_page_fault+0x20/0x5c
Instruction dump:
7d291a14 e9290170 ebe90000 7d274b78 83890018 2fbf0000 40be0010 4bfff531 
7c7f1b78 48000014 80090014 78001f24 <7c1f002a> f8090000 2fbd0000 38600000 
---[ end trace 1ee5b1711a7e1dbb ]---

BUG: soft lockup - CPU#0 stuck for 61s! [kbd:3360]
Modules linked in:
NIP: c0000000004d7f98 LR: c0000000004d7f74 CTR: c000000000254900
REGS: c00000077b016630 TRAP: 0901   Tainted: G      D    (2.6.27-rc2-next-20080811-autotest)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 28224444  XER: 20000000
TASK = c00000077b113480[3360] 'kbd' THREAD: c00000077b014000 CPU: 0
GPR00: 0000020000000000 c00000077b0168b0 c000000000872120 c00000077cbf3288 
GPR04: c00000077cf4d0a8 0000000000000001 0000000000000000 0000000000000000 
GPR08: 0000000000010840 0000000000000000 c000000000882180 0000000000000000 
GPR12: c00000000003a488 c0000000008a4300 
NIP [c0000000004d7f98] ._spin_lock_irqsave+0x90/0xdc
LR [c0000000004d7f74] ._spin_lock_irqsave+0x6c/0xdc
Call Trace:
[c00000077b0168b0] [c00000077b016950] 0xc00000077b016950 (unreliable)
[c00000077b016940] [c000000000254938] .cfq_exit_single_io_context+0x38/0x7c
[c00000077b0169e0] [c000000000254050] .__call_for_each_cic+0x60/0x88
[c00000077b016a70] [c000000000249a08] .exit_io_context+0xd8/0x108
[c00000077b016af0] [c00000000005aa54] .do_exit+0x81c/0x864
[c00000077b016bc0] [c000000000023c34] .die+0x24c/0x27c
[c00000077b016c60] [c00000000002b1ec] .bad_page_fault+0xb8/0xd4
[c00000077b016ce0] [c000000000005218] handle_page_fault+0x3c/0x5c
--- Exception: 300 at .kmem_cache_alloc+0x6c/0xd4
    LR = .mempool_alloc_slab+0x1c/0x30
[c00000077b016fd0] [c00000077d410c88] 0xc00000077d410c88 (unreliable)
[c00000077b017070] [c0000000000ab7bc] .mempool_alloc_slab+0x1c/0x30
[c00000077b0170f0] [c0000000000ab9a8] .mempool_alloc+0x64/0x158
[c00000077b0171c0] [c000000000351c80] .scsi_sg_alloc+0x74/0x8c
[c00000077b017240] [c000000000264bec] .__sg_alloc_table+0xa8/0x180
[c00000077b017310] [c000000000351b60] .scsi_init_sgtable+0x48/0xf4
[c00000077b0173a0] [c000000000351f48] .scsi_init_io+0x30/0xf0
[c00000077b017430] [c000000000389764] .sd_prep_fn+0x8c/0x608
[c00000077b017500] [c000000000243958] .elv_next_request+0x13c/0x260
[c00000077b0175a0] [c0000000003537bc] .scsi_request_fn+0x98/0x470
[c00000077b017650] [c0000000002461fc] .__generic_unplug_device+0x54/0x6c
[c00000077b0176d0] [c0000000002472c8] .generic_unplug_device+0x3c/0x84
[c00000077b017750] [c000000000244534] .blk_unplug+0x30/0x44
[c00000077b0177d0] [c00000000011363c] .block_sync_page+0x78/0x90
[c00000077b017850] [c0000000000a85c4] .sync_page+0x74/0x98
[c00000077b0178d0] [c0000000004d5fc8] .__wait_on_bit_lock+0x94/0x11c
[c00000077b017980] [c0000000000a850c] .__lock_page+0xbc/0xd8
[c00000077b017a90] [c0000000000a8844] .find_lock_page+0x5c/0xa0
[c00000077b017b20] [c0000000000ab398] .filemap_fault+0x198/0x40c
[c00000077b017c00] [c0000000000bbf94] .__do_fault+0xa0/0x51c
[c00000077b017d00] [c0000000004d9f48] .do_page_fault+0x3b4/0x598
[c00000077b017e30] [c0000000000051fc] handle_page_fault+0x20/0x5c
Instruction dump:
419e0008 7fe3fb78 4bb33c51 60000000 7c210b78 e92d0000 7fa3eb78 e8090008 
78097fe1 4182000c 4bb5ae39 60000000 <801d0000> 2fa00000 40beffd8 7c421378 

BUG: soft lockup - CPU#2 stuck for 61s! [startpar:3082]
Modules linked in:
NIP: c0000000004d7f98 LR: c0000000004d7f74 CTR: c000000000254900
REGS: c00000077ccc7810 TRAP: 0901   Tainted: G      D    (2.6.27-rc2-next-20080811-autotest)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24004484  XER: 20000000
TASK = c00000077e24d780[3082] 'startpar' THREAD: c00000077ccc4000 CPU: 2
GPR00: 0000020000000000 c00000077ccc7a90 c000000000872120 c00000077cbf3288 
GPR04: c00000077b009000 0000000000000001 0000000000000000 0000000000000000 
GPR08: c00000077e24d780 0000000000000000 0000000000000004 0000000000000000 
GPR12: 000000000000d032 c0000000008a4700 
NIP [c0000000004d7f98] ._spin_lock_irqsave+0x90/0xdc
LR [c0000000004d7f74] ._spin_lock_irqsave+0x6c/0xdc
Call Trace:
[c00000077ccc7a90] [c00000077ccc7b30] 0xc00000077ccc7b30 (unreliable)
[c00000077ccc7b20] [c000000000254938] .cfq_exit_single_io_context+0x38/0x7c
[c00000077ccc7bc0] [c000000000254050] .__call_for_each_cic+0x60/0x88
[c00000077ccc7c50] [c000000000249a08] .exit_io_context+0xd8/0x108
[c00000077ccc7cd0] [c00000000005aa54] .do_exit+0x81c/0x864
[c00000077ccc7da0] [c00000000005ab50] .do_group_exit+0xb4/0xe8
[c00000077ccc7e30] [c0000000000086ac] syscall_exit+0x0/0x40
Instruction dump:
419e0008 7fe3fb78 4bb33c51 60000000 7c210b78 e92d0000 7fa3eb78 e8090008 
78097fe1 4182000c 4bb5ae39 60000000 <801d0000> 2fa00000 40beffd8 7c421378 

(gdb) l *0xc0000000000df740
0xc0000000000df740 is in __kmalloc_node_track_caller (slub.c:1613).
1608
1609                    object = __slab_alloc(s, gfpflags, node, addr, c);
1610
1611            else {
1612                    object = c->freelist;
1613                    c->freelist = object[c->offset];
1614                    stat(c, ALLOC_FASTPATH);
1615            }
1616            local_irq_restore(flags);
1617

(gdb) l *0xc0000000000df6d0
0xc0000000000df6d0 is in __kmalloc_node_track_caller (slub.c:3240).
3235            if (unlikely(size > PAGE_SIZE))
3236                    return kmalloc_large_node(size, gfpflags, node);
3237
3238            s = get_slab(size, gfpflags);
3239
3240            if (unlikely(ZERO_OR_NULL_PTR(s)))
3241                    return s;
3242
3243            return slab_alloc(s, gfpflags, node, caller);
3244    }

(gdb) l *0xc0000000000dff5c
0xc0000000000dff5c is in __kmalloc (slub.c:1613).
1608
1609                    object = __slab_alloc(s, gfpflags, node, addr, c);
1610
1611            else {
1612                    object = c->freelist;
1613                    c->freelist = object[c->offset];
1614                    stat(c, ALLOC_FASTPATH);
1615            }
1616            local_irq_restore(flags);
1617

(gdb) l *0xc0000000000dff04
0xc0000000000dff04 is in __kmalloc (slub.c:2671).
2666            if (unlikely(size > PAGE_SIZE))
2667                    return kmalloc_large(size, flags);
2668
2669            s = get_slab(size, flags);
2670
2671            if (unlikely(ZERO_OR_NULL_PTR(s)))
2672                    return s;
2673
2674            return slab_alloc(s, flags, -1, __builtin_return_address(0));
2675    }


(gdb) l *0xc0000000000de37c
0xc0000000000de37c is in kmem_cache_alloc (slub.c:1613).
1608
1609                    object = __slab_alloc(s, gfpflags, node, addr, c);
1610
1611            else {
1612                    object = c->freelist;
1613                    c->freelist = object[c->offset];
1614                    stat(c, ALLOC_FASTPATH);
1615            }
1616            local_irq_restore(flags);
1617

(gdb) l *0xc0000000000ab7bc
0xc0000000000ab7bc is in mempool_alloc_slab (mempool.c:289).
284      * A commonly used alloc and free fn.
285      */
286     void *mempool_alloc_slab(gfp_t gfp_mask, void *pool_data)
287     {
288             struct kmem_cache *mem = pool_data;
289             return kmem_cache_alloc(mem, gfp_mask);
290     }
291     EXPORT_SYMBOL(mempool_alloc_slab);
292
293     void mempool_free_slab(void *element, void *pool_data)

(gdb) l *0xc0000000004d7f98
0xc0000000004d7f98 is in _spin_lock_irqsave (spinlock.h:137).
132                     local_irq_restore(flags);
133                     do {
134                             HMT_low();
135                             if (SHARED_PROCESSOR)
136                                     __spin_yield(lock);
137                     } while (unlikely(lock->slock != 0));
138                     HMT_medium();
139                     local_irq_restore(flags_dis);
140             }
141     }

(gdb) l*0xc0000000004d7f74
0xc0000000004d7f74 is in _spin_lock_irqsave (spinlock.h:132).
127             CLEAR_IO_SYNC;
128             while (1) {
129                     if (likely(__spin_trylock(lock) == 0))
130                             break;
131                     local_save_flags(flags_dis);
132                     local_irq_restore(flags);
133                     do {
134                             HMT_low();
135                             if (SHARED_PROCESSOR)
136                                     __spin_yield(lock);




-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
