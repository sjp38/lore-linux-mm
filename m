Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 122A76B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 16:17:07 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u5so1519024lfg.9
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:17:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s195sor1987948lfs.57.2017.10.18.13.17.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 13:17:05 -0700 (PDT)
MIME-Version: 1.0
From: =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Date: Thu, 19 Oct 2017 01:16:48 +0500
Message-ID: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
Subject: swapper/0: page allocation failure: order:0, mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi! Who knows what is happened here?
Bug?

[ 2880.745242] swapper/0: page allocation failure: order:0,
mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
nodemask=(null)
[ 2880.745311] swapper/0 cpuset=/ mems_allowed=0-1023
[ 2880.745504] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
4.13.6-300.fc27.x86_64+debug #1
[ 2880.745505] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[ 2880.745506] Call Trace:
[ 2880.745508]  <IRQ>
[ 2880.745513]  dump_stack+0x8e/0xd6
[ 2880.745517]  warn_alloc+0x114/0x1c0
[ 2880.745525]  __alloc_pages_slowpath+0x104b/0x1100
[ 2880.745533]  ? sched_clock+0x9/0x10
[ 2880.745537]  ? get_partial_node.isra.67+0x226/0x2e0
[ 2880.745542]  ? __lock_is_held+0x65/0xb0
[ 2880.745548]  __alloc_pages_nodemask+0x351/0x3e0
[ 2880.745554]  alloc_pages_current+0x6a/0xe0
[ 2880.745557]  new_slab+0x440/0x740
[ 2880.745559]  ? __slab_alloc+0x51/0x90
[ 2880.745565]  ___slab_alloc+0x3eb/0x5e0
[ 2880.745569]  ? radix_tree_node_alloc.constprop.18+0x46/0xe0
[ 2880.745575]  ? radix_tree_node_alloc.constprop.18+0x46/0xe0
[ 2880.745578]  __slab_alloc+0x51/0x90
[ 2880.745580]  ? __slab_alloc+0x51/0x90
[ 2880.745584]  kmem_cache_alloc+0x235/0x2e0
[ 2880.745585]  ? radix_tree_node_alloc.constprop.18+0x46/0xe0
[ 2880.745589]  radix_tree_node_alloc.constprop.18+0x46/0xe0
[ 2880.745592]  __radix_tree_create+0x16d/0x1d0
[ 2880.745597]  __radix_tree_insert+0x45/0x210
[ 2880.745604]  add_dma_entry+0xbf/0x170
[ 2880.745609]  debug_dma_map_sg+0x11a/0x170
[ 2880.745614]  ata_qc_issue+0x1de/0x380
[ 2880.745618]  ? ata_scsi_var_len_cdb_xlat+0x30/0x30
[ 2880.745620]  ata_scsi_translate+0xcf/0x1a0
[ 2880.745624]  ata_scsi_queuecmd+0xa4/0x210
[ 2880.745628]  scsi_dispatch_cmd+0xf9/0x390
[ 2880.745632]  scsi_request_fn+0x4d6/0x6e0
[ 2880.745638]  __blk_run_queue+0x5c/0xc0
[ 2880.745640]  blk_run_queue+0x30/0x50
[ 2880.745643]  scsi_run_queue+0x23f/0x310
[ 2880.745648]  scsi_end_request+0xf0/0x1d0
[ 2880.745652]  scsi_io_completion+0x283/0x6c0
[ 2880.745657]  scsi_finish_command+0xe4/0x120
[ 2880.745661]  scsi_softirq_done+0x105/0x160
[ 2880.745664]  blk_done_softirq+0xa8/0xd0
[ 2880.745669]  __do_softirq+0xce/0x4ed
[ 2880.745682]  ? sched_clock+0x9/0x10
[ 2880.745684]  ? sched_clock+0x9/0x10
[ 2880.745689]  irq_exit+0x10f/0x120
[ 2880.745692]  do_IRQ+0x92/0x110
[ 2880.745696]  common_interrupt+0x9d/0x9d
[ 2880.745698] RIP: 0010:cpuidle_enter_state+0x135/0x390
[ 2880.745700] RSP: 0018:ffffffffafe03dc0 EFLAGS: 00000206 ORIG_RAX:
ffffffffffffff2e
[ 2880.745703] RAX: ffffffffafe18500 RBX: 0000029eb9c9a7f7 RCX: 0000000000000000
[ 2880.745704] RDX: ffffffffafe18500 RSI: 0000000000000001 RDI: ffffffffafe18500
[ 2880.745705] RBP: ffffffffafe03e00 R08: 0000000000000075 R09: 0000000000000000
[ 2880.745706] R10: 0000000000000000 R11: 0000000000000000 R12: ffffe15e7ee00000
[ 2880.745707] R13: 0000000000000000 R14: 0000000000000001 R15: ffffffffb00634d8
[ 2880.745709]  </IRQ>
[ 2880.745721]  cpuidle_enter+0x17/0x20
[ 2880.745733]  call_cpuidle+0x23/0x40
[ 2880.745735]  do_idle+0x194/0x1f0
[ 2880.745739]  cpu_startup_entry+0x73/0x80
[ 2880.745742]  rest_init+0xd5/0xe0
[ 2880.745745]  start_kernel+0x4f4/0x515
[ 2880.745749]  ? early_idt_handler_array+0x120/0x120
[ 2880.745751]  x86_64_start_reservations+0x24/0x26
[ 2880.745754]  x86_64_start_kernel+0x13e/0x161
[ 2880.745759]  secondary_startup_64+0x9f/0x9f
[ 2880.745847] SLUB: Unable to allocate memory on node -1,
gfp=0x1000000(GFP_NOWAIT)
[ 2880.745849]   cache: radix_tree_node, object size: 576, buffer
size: 584, default order: 2, min order: 0
[ 2880.745851]   node 0: slabs: 3526, objs: 98203, free: 0
[ 2880.745871] DMA-API: cacheline tracking ENOMEM, dma-debug disabled




--
Best Regards,
Mike Gavrilov.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
