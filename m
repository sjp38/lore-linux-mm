Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id C4C906B0035
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 05:19:29 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so6496926wes.5
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 02:19:29 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:6f8:1178:4:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id o2si19370691wje.108.2014.06.23.02.19.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 02:19:28 -0700 (PDT)
Date: Mon, 23 Jun 2014 11:17:54 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCHv5 2/2] arm: Get rid of meminfo
Message-ID: <20140623091754.GD14781@pengutronix.de>
References: <1396544698-15596-1-git-send-email-lauraa@codeaurora.org>
 <1396544698-15596-3-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1396544698-15596-3-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Russell King <linux@arm.linux.org.uk>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org, Nicolas Pitre <nicolas.pitre@linaro.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Grygorii Strashko <grygorii.strashko@ti.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-arm-msm@vger.kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grant Likely <grant.likely@secretlab.ca>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, kernel@pengutronix.de

On Thu, Apr 03, 2014 at 10:04:58AM -0700, Laura Abbott wrote:
> memblock is now fully integrated into the kernel and is the prefered
> method for tracking memory. Rather than reinvent the wheel with
> meminfo, migrate to using memblock directly instead of meminfo as
> an intermediate.
This patch is in 3.16-rc1 as 1c2f87c22566cd057bc8cde10c37ae9da1a1bb76
now.

Unfortunately it makes my efm32 machine unbootable.

With earlyprintk enabled I get the following output:

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 3.15.0-rc1-00028-g1c2f87c22566-dirty (ukleinek@perseus) (gcc version 4.7.2 (OSELAS.Toolchain-2012.12.1) ) #280 PREEMPT Mon Jun 23 11:05:34 CEST 2014
[    0.000000] CPU: ARMv7-M [412fc231] revision 1 (ARMv7M), cr=00000000
[    0.000000] CPU: unknown data cache, unknown instruction cache
[    0.000000] Machine model: Energy Micro Giant Gecko Development Kit
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] bootconsole [earlycon0] enabled
[    0.000000] On node 0 totalpages: 1024
[    0.000000] free_area_init_node: node 0, pgdat 880208f4, node_mem_map 00000000
[    0.000000]   Normal zone: 3840 pages exceeds freesize 1024
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 1024 pages, LIFO batch:0
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1024
[    0.000000] Kernel command line: console=ttyefm4,115200 init=/linuxrc ignore_loglevel ihash_entries=64 dhash_entries=64 earlyprintk uclinux.physaddr=0x8c400000 root=/dev/mtdblock0
[    0.000000] PID hash table entries: 16 (order: -6, 64 bytes)
[    0.000000] Dentry cache hash table entries: 64 (order: -4, 256 bytes)
[    0.000000] Inode-cache hash table entries: 64 (order: -4, 256 bytes)
[    0.000000] Memory: 0K/4096K available (1156K kernel code, 83K rwdata, 316K rodata, 56K init, 43K bss, 212K reserved)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0x00000000 - 0x00001000   (   4 kB)
[    0.000000]     fixmap  : 0xffc00000 - 0xffe00000   (2048 kB)
[    0.000000]     vmalloc : 0x00000000 - 0xffffffff   (4095 MB)
[    0.000000]     lowmem  : 0x88000000 - 0x88400000   (   4 MB)
[    0.000000]       .text : 0x8c000000 - 0x8c170360   (1473 kB)
[    0.000000]       .init : 0x8800a000 - 0x8800e000   (  16 kB)
[    0.000000]       .data : 0x88008000 - 0x88020f80   ( 100 kB)
[    0.000000]        .bss : 0x88020f8c - 0x8802bf5c   (  44 kB)
[    0.000000] swapper: page allocation failure: order:0, mode:0x200000
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.15.0-rc1-00028-g1c2f87c22566-dirty #280
[    0.000000] [<8c002b95>] (unwind_backtrace) from [<8c001f0b>] (show_stack+0xb/0xc)
[    0.000000] [<8c001f0b>] (show_stack) from [<8c02e997>] (warn_alloc_failed+0x95/0xba)
[    0.000000] [<8c02e997>] (warn_alloc_failed) from [<8c02ff6b>] (__alloc_pages_nodemask+0x437/0x484)
[    0.000000] [<8c02ff6b>] (__alloc_pages_nodemask) from [<8c03b7b5>] (new_slab+0x51/0x184)
[    0.000000] [<8c03b7b5>] (new_slab) from [<8c03c1b5>] (__kmem_cache_create+0x5d/0x12c)
[    0.000000] [<8c03c1b5>] (__kmem_cache_create) from [<8c174667>] (create_boot_cache+0x23/0x3c)
[    0.000000] [<8c174667>] (create_boot_cache) from [<8c1751af>] (kmem_cache_init+0x23/0x88)
[    0.000000] [<8c1751af>] (kmem_cache_init) from [<8c17078b>] (start_kernel+0xfb/0x210)
[    0.000000] [<8c17078b>] (start_kernel) from [<8c000023>] (0x8c000023)
[    0.000000] Mem-info:
[    0.000000] Normal per-cpu:
[    0.000000] CPU    0: hi:    0, btch:   1 usd:   0
[    0.000000] active_anon:0 inactive_anon:0 isolated_anon:0
[    0.000000]  active_file:0 inactive_file:0 isolated_file:0
[    0.000000]  unevictable:0 dirty:0 writeback:0 unstable:0
[    0.000000]  free:0 slab_reclaimable:0 slab_unreclaimable:0
[    0.000000]  mapped:0 shmem:0 pagetables:0 bounce:0
[    0.000000]  free_cma:0
[    0.000000] Normal free:0kB min:0kB low:0kB high:0kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:4096kB managed:2776kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    0.000000] lowmem_reserve[]: 0 0
[    0.000000] Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB = 0kB
[    0.000000] 0 total pagecache pages
[    0.000000] 
[    0.000000] Unhandled exception: IPSR = 00000003 LR = fffffff1
[    0.000000] 
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.15.0-rc1-00028-g1c2f87c22566-dirty #280
[    0.000000] task: 88015950 ti: 88008000 task.ti: 88008000
[    0.000000] PC is at show_mem+0x96/0x150
[    0.000000] LR is at 0x880251e0
[    0.000000] pc : [<8c00359a>]    lr : [<880251e0>]    psr: 0100000b
[    0.000000] sp : 88009e68  ip : 00088000  fp : 4100f101
[    0.000000] r10: 00000080  r9 : f7ff0047  r8 : 00000001
[    0.000000] r7 : 00000001  r6 : d0fb0f3f  r5 : 00000000  r4 : 00000000
[    0.000000] r3 : 00000060  r2 : 88025238  r1 : 00000004  r0 : 8801a2e4
[    0.000000] xPSR: 0100000b
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.15.0-rc1-00028-g1c2f87c22566-dirty #280
[    0.000000] [<8c002b95>] (unwind_backtrace) from [<8c001f0b>] (show_stack+0xb/0xc)
[    0.000000] [<8c001f0b>] (show_stack) from [<8c002547>] (__invalid_entry+0x4b/0x4c)

(The -dirty is just:

diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
index 2b751464d6ff..9536c9ec6f43 100644
--- a/arch/arm/include/asm/memory.h
+++ b/arch/arm/include/asm/memory.h
@@ -92,7 +92,7 @@
  * Fortunately, there is no reference for this in noMMU mode, for now.
  */
 #ifndef TASK_SIZE
-#define TASK_SIZE              (CONFIG_DRAM_SIZE)
+#define TASK_SIZE              UL(0xffffffff)
 #endif
 
 #ifndef TASK_UNMAPPED_BASE

which is needed to make nommu machines boot.)

Any idea?

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
