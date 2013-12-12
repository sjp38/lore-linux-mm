Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA086B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 09:36:23 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id m1so497439oag.17
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 06:36:23 -0800 (PST)
Received: from eusmtp01.atmel.com (eusmtp01.atmel.com. [212.144.249.243])
        by mx.google.com with ESMTPS id bx5si16292819oec.104.2013.12.12.06.36.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 12 Dec 2013 06:36:22 -0800 (PST)
Date: Thu, 12 Dec 2013 15:36:19 +0100
From: Ludovic Desroches <ludovic.desroches@atmel.com>
Subject: Re: possible regression on 3.13 when calling flush_dcache_page
Message-ID: <20131212143618.GJ12099@ldesroches-Latitude-E6320>
References: <20131212143149.GI12099@ldesroches-Latitude-E6320>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20131212143149.GI12099@ldesroches-Latitude-E6320>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, iamjoonsoo.kim@lge.com
Cc: Ludovic Desroches <ludovic.desroches@atmel.com>

fix mmc mailing list address error

On Thu, Dec 12, 2013 at 03:31:50PM +0100, Ludovic Desroches wrote:
> Hi,
> 
> With v3.13-rc3 I have an error when the atmel-mci driver calls
> flush_dcache_page (log at the end of the message).
> 
> Since I didn't have it before, I did a git bisect and the commit introducing
> the error is the following one:
> 
> 106a74e slab: replace free and inuse in struct slab with newly introduced active
> 
> I don't know if this commit has introduced a bug or if it has revealed a bug
> in the atmel-mci driver.
> 
> I'll investigate on atmel-mci driver side but if someone has also this issue or
> see what is wrong in the driver, please tell me all about it.
> 
> Thanks
> 
> Regards
> 
> Ludovic
> 
> 
> # mmc0: mmc_rescan_try_freq: trying to init card at 400000 Hz
> mmc0: queuing unknown CIS tuple 0x01 (3 bytes)
> mmc0: queuing unknown CIS tuple 0x1a (5 bytes)
> mmc0: queuing unknown CIS tuple 0x1b (8 bytes)
> mmc0: queuing unknown CIS tuple 0x14 (0 bytes)
> mmc0: queuing unknown CIS tuple 0x80 (1 bytes)
> mmc0: queuing unknown CIS tuple 0x81 (1 bytes)
> mmc0: queuing unknown CIS tuple 0x82 (1 bytes)
> mmc0: new SDIO card at address 0001
> Unable to handle kernel paging request at virtual address 0a00000c
> pgd = c0004000
> [0a00000c] *pgd=00000000
> Internal error: Oops: 5 [#1] ARM
> Modules linked in:
> CPU: 0 PID: 9 Comm: kworker/u2:1 Not tainted 3.11.0+ #68
> Workqueue: kmmcd mmc_rescan
> task: c384e800 ti: c385e000 task.ti: c385e000
> PC is at vma_interval_tree_subtree_search+0x18/0x74
> LR is at flush_dcache_page+0x90/0x12c
> pc : [<c0064a50>]    lr : [<c000f00c>]    psr: 20000093
> sp : c385fab8  ip : 00000000  fp : c10ca400
> r10: c385fc64  r9 : c12f92fc  r8 : 00000000
> r7 : c2ace640  r6 : c0cc5be0  r5 : c0cd0000  r4 : c1323a00
> r3 : 0a000000  r2 : c0cc5be0  r1 : c0cc5be0  r0 : c034ae48
> Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> Control: 0005317f  Table: 22b7c000  DAC: 00000017
> Process kworker/u2:1 (pid: 9, stack limit = 0xc385e1b8)
> Stack: (0xc385fab8 to 0xc3860000)
> faa0:                                                       c1323a00 c000f00c
> fac0: c0cd02d0 c2b0cb40 c385fc30 00000003 00000004 c0281380 44006d72 43495645
> fae0: 0000c0ef 00000000 3a6d726f 00000000 30303038 c2b42ec0 c3868b80 0000001e
> fb00: 00000000 00000000 c10f26ed 00000200 0008a000 c0049d3c c3868b80 c2b42ec0
> fb20: c3868b80 00000000 ffffffff c385fb9c c0cd02d0 1408a004 00000200 c0049ed8
> fb40: c3868b80 c004c384 0000001e c0049718 0000001e c0009cc8 c10f2a60 c001d7ec
> fb60: 20000013 c000bf20 c10f3900 c2b0cbd8 0000184a a0000013 c2b0cbd8 ffff824a
> fb80: c10f30e0 00000000 c0cd02d0 1408a004 00000200 0008a000 ffff814a c385fbb0
> fba0: c001d560 c001d7ec 20000013 ffffffff c2b0cbd8 a0000013 f7cedc96 c2b07400
> fbc0: c2b0cb40 c385fc40 00000001 c028207c c385fc40 c2b07400 00000004 c0270e28
> fbe0: 00000200 000003e8 00000000 61666666 30303038 c2b07400 c385fc50 c385fc40
> fc00: 00001000 c027100c c1323a02 00000004 c2b48000 00000001 00001000 c027a06c
> fc20: 00000015 c38f2800 c2ace7c0 c002f804 c1323a02 000002d0 00000004 00000000
> fc40: 00000000 c385fc94 c385fc64 00000000 00000000 c385fc54 c385fc54 c0270c3c
> fc60: 00000000 3b9aca00 00000000 00000004 00000001 ffffff8d 00000200 00000000
> fc80: 00000000 c385fc40 00000001 c385fc30 00000000 00000035 1408a004 00000000
> fca0: 00000000 00000000 00000000 000001b5 00000000 ffffff8d 00000000 00000000
> fcc0: c385fc64 c385fc40 00000007 00000004 c2bfb400 c0cd02d0 00000450 00000001
> fce0: 00000000 00000004 000001ff c027af0c 00000001 c0cd02d0 00000000 00000004
> fd00: 00000000 00000000 c10cf4f0 00000450 00000004 c2bfb400 c0cd02d0 00000251
> fd20: 00000450 c0cd02d0 00000251 c027b010 c0cd02d0 00000004 00000450 c022d0e8
> fd40: c0cd02d0 c3859000 00000004 00000251 00000000 c022d6ac 00000004 00000450
> fd60: c0cd02c0 c10ce7e8 c0cd02d0 00000004 c385fdb4 c10ce7e8 ffff81c9 c022da4c
> fd80: 00000251 c385fdb4 00000004 c385fddc 00000000 c0cd02c0 c03b5ccc 00000001
> fda0: 00000000 c2b48008 c2bfb400 c021bb1c c0cd02c0 00000008 c385fd84 c0cd02c0
> fdc0: 00000000 00000000 c03b5ccc c022c37c 00000000 c0476909 00000000 00000000
> fde0: 00000000 c385fd7c c3859000 c0cd02c0 00000000 c022e010 c022de8c c2bfb400
> fe00: 00000000 c10e18f0 c03b5ccc c027a32c c027a2d4 c2bfb408 00000000 c10e18f0
> fe20: c01cafc8 c01cadf4 00000000 c385fe38 c2bfb408 c01c966c c38d7a1c c2ad6f34
> fe40: c2bfb408 c2bfb408 c2bfb43c c2bfb408 00000000 c01cad10 c2bfb408 c10eb49c
> fe60: c2bfb408 c01ca398 c2bfb408 00000000 c2bfb410 c01c898c c2bfb410 00000000
> fe80: 00000000 c01818b0 00000001 c2bfb400 c2bfb408 c2bfb400 c2bfb408 00000000
> fea0: c2b48000 00000001 00000000 c385fed3 c2bfb400 c027a4c4 c2b48000 c2b07400
> fec0: 00000000 c0279b8c 00000000 c385fed3 00000000 10ffff00 00000000 c2b0757c
> fee0: c2b07400 00000000 00061a80 c03b9d90 00000000 00000000 00000089 c0272fb8
> ff00: c385df60 c2b0757c c3817200 c10f26b5 c3849c00 c00270e0 c385df60 c2b0757c
> ff20: 00000081 c385df60 c3817200 c385e000 c10f26b5 c385df78 c3817200 c3817210
> ff40: 00000089 c00276d0 c384e800 c384debc 00000000 c385df60 c00274c0 00000000
> ff60: 00000000 00000000 00000000 c002c130 00000000 00000000 00000000 c385df60
> ff80: 00000000 c385ff84 c385ff84 00000000 c385ff90 c385ff90 c385ffac c384debc
> ffa0: c002c090 00000000 00000000 c00094b0 00000000 00000000 00000000 00000000
> ffc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> ffe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
> [<c0064a50>] (vma_interval_tree_subtree_search+0x18/0x74) from [<c000f00c>] (flush_dcache_page+0x90/0x12c)
> [<c000f00c>] (flush_dcache_page+0x90/0x12c) from [<c0281380>] (atmci_interrupt+0x3cc/0x900)
> [<c0281380>] (atmci_interrupt+0x3cc/0x900) from [<c0049d3c>] (handle_irq_event_percpu+0x2c/0x1a0)
> [<c0049d3c>] (handle_irq_event_percpu+0x2c/0x1a0) from [<c0049ed8>] (handle_irq_event+0x28/0x38)
> [<c0049ed8>] (handle_irq_event+0x28/0x38) from [<c004c384>] (handle_fasteoi_irq+0xa4/0xe4)
> [<c004c384>] (handle_fasteoi_irq+0xa4/0xe4) from [<c0049718>] (generic_handle_irq+0x20/0x30)
> [<c0049718>] (generic_handle_irq+0x20/0x30) from [<c0009cc8>] (handle_IRQ+0x60/0x84)
> [<c0009cc8>] (handle_IRQ+0x60/0x84) from [<c000bf20>] (__irq_svc+0x40/0x4c)
> [<c000bf20>] (__irq_svc+0x40/0x4c) from [<c001d7ec>] (mod_timer+0xf8/0x110)
> [<c001d7ec>] (mod_timer+0xf8/0x110) from [<c028207c>] (atmci_request+0xd0/0x120)
> [<c028207c>] (atmci_request+0xd0/0x120) from [<c0270e28>] (mmc_start_request+0x1e4/0x204)
> [<c0270e28>] (mmc_start_request+0x1e4/0x204) from [<c027100c>] (mmc_wait_for_req+0x6c/0x16c)
> [<c027100c>] (mmc_wait_for_req+0x6c/0x16c) from [<c027a06c>] (mmc_io_rw_extended+0x214/0x290)
> [<c027a06c>] (mmc_io_rw_extended+0x214/0x290) from [<c027af0c>] (sdio_io_rw_ext_helper+0x160/0x1a0)
> [<c027af0c>] (sdio_io_rw_ext_helper+0x160/0x1a0) from [<c027b010>] (sdio_memcpy_fromio+0x14/0x18)
> [<c027b010>] (sdio_memcpy_fromio+0x14/0x18) from [<c022d0e8>] (ath6kl_sdio_io+0x88/0x9c)
> [<c022d0e8>] (ath6kl_sdio_io+0x88/0x9c) from [<c022d6ac>] (ath6kl_sdio_read_write_sync+0xb0/0x100)
> [<c022d6ac>] (ath6kl_sdio_read_write_sync+0xb0/0x100) from [<c022da4c>] (ath6kl_sdio_bmi_write+0x54/0xf8)
> [<c022da4c>] (ath6kl_sdio_bmi_write+0x54/0xf8) from [<c021bb1c>] (ath6kl_bmi_get_target_info+0x44/0x190)
> [<c021bb1c>] (ath6kl_bmi_get_target_info+0x44/0x190) from [<c022c37c>] (ath6kl_core_init+0xa4/0x404)
> [<c022c37c>] (ath6kl_core_init+0xa4/0x404) from [<c022e010>] (ath6kl_sdio_probe+0x184/0x1ec)
> [<c022e010>] (ath6kl_sdio_probe+0x184/0x1ec) from [<c027a32c>] (sdio_bus_probe+0x58/0x6c)
> [<c027a32c>] (sdio_bus_probe+0x58/0x6c) from [<c01cadf4>] (driver_probe_device+0xac/0x1f4)
> [<c01cadf4>] (driver_probe_device+0xac/0x1f4) from [<c01c966c>] (bus_for_each_drv+0x48/0x8c)
> [<c01c966c>] (bus_for_each_drv+0x48/0x8c) from [<c01cad10>] (device_attach+0x68/0x80)
> [<c01cad10>] (device_attach+0x68/0x80) from [<c01ca398>] (bus_probe_device+0x28/0x98)
> [<c01ca398>] (bus_probe_device+0x28/0x98) from [<c01c898c>] (device_add+0x424/0x5fc)
> [<c01c898c>] (device_add+0x424/0x5fc) from [<c027a4c4>] (sdio_add_func+0x34/0x4c)
> [<c027a4c4>] (sdio_add_func+0x34/0x4c) from [<c0279b8c>] (mmc_attach_sdio+0x260/0x314)
> [<c0279b8c>] (mmc_attach_sdio+0x260/0x314) from [<c0272fb8>] (mmc_rescan+0x22c/0x2b4)
> [<c0272fb8>] (mmc_rescan+0x22c/0x2b4) from [<c00270e0>] (process_one_work+0x1f4/0x348)
> [<c00270e0>] (process_one_work+0x1f4/0x348) from [<c00276d0>] (worker_thread+0x210/0x36c)
> [<c00276d0>] (worker_thread+0x210/0x36c) from [<c002c130>] (kthread+0xa0/0xb0)
> [<c002c130>] (kthread+0xa0/0xb0) from [<c00094b0>] (ret_from_fork+0x14/0x24)
> Code: e243002c e5903034 e3530000 0a000002 (e593c00c) 
> ---[ end trace 3f7f9bc3f451e9c9 ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
