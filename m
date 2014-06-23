Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 841406B0037
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 05:32:25 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so3756331wib.1
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 02:32:24 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:6f8:1178:4:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id z2si22378291wjz.98.2014.06.23.02.32.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 02:32:22 -0700 (PDT)
Date: Mon, 23 Jun 2014 11:30:52 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCHv5 2/2] arm: Get rid of meminfo
Message-ID: <20140623093052.GF14781@pengutronix.de>
References: <1396544698-15596-1-git-send-email-lauraa@codeaurora.org>
 <1396544698-15596-3-git-send-email-lauraa@codeaurora.org>
 <20140623091754.GD14781@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140623091754.GD14781@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Russell King <linux@arm.linux.org.uk>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org, Nicolas Pitre <nicolas.pitre@linaro.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Grygorii Strashko <grygorii.strashko@ti.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-arm-msm@vger.kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grant Likely <grant.likely@secretlab.ca>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, kernel@pengutronix.de

On Mon, Jun 23, 2014 at 11:17:54AM +0200, Uwe Kleine-Konig wrote:
> On Thu, Apr 03, 2014 at 10:04:58AM -0700, Laura Abbott wrote:
> > memblock is now fully integrated into the kernel and is the prefered
> > method for tracking memory. Rather than reinvent the wheel with
> > meminfo, migrate to using memblock directly instead of meminfo as
> > an intermediate.
> This patch is in 3.16-rc1 as 1c2f87c22566cd057bc8cde10c37ae9da1a1bb76
> now.
> 
> Unfortunately it makes my efm32 machine unbootable.
> 
> With earlyprintk enabled I get the following output:
In case someone needs it, here is the bootlog with memblock_debug = 1
(I changed this in the source as this is the easier change than modifying the
command line):

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
Gecko
[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 3.15.0-rc1-00028-g1c2f87c22566-dirty (ukleinek@perseus) (gcc version 4.7.2 (OSELAS.Toolchain-2012.12.1) ) #281 PREEMPT Mon Jun 23 11:21:49 CEST 2014
[    0.000000] CPU: ARMv7-M [412fc231] revision 1 (ARMv7M), cr=00000000
[    0.000000] CPU: unknown data cache, unknown instruction cache
[    0.000000] Machine model: Energy Micro Giant Gecko Development Kit
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] bootconsole [earlycon0] enabled
[    0.000000] memblock_reserve: [0x00000088008000-0x0000008802bf3b] flags 0x0 arm_memblock_init+0xf/0x48
[    0.000000] memblock_reserve: [0x00000010000000-0x000000100010fd] flags 0x0 arm_dt_memblock_reserve+0x11/0x40
[    0.000000] MEMBLOCK configuration:
[    0.000000]  memory size = 0x400000 reserved size = 0x2503a
[    0.000000]  memory.cnt  = 0x1
[    0.000000]  memory[0x0]	[0x00000088000000-0x000000883fffff], 0x400000 bytes flags: 0x0
[    0.000000]  reserved.cnt  = 0x2
[    0.000000]  reserved[0x0]	[0x00000010000000-0x000000100010fd], 0x10fe bytes flags: 0x0
[    0.000000]  reserved[0x1]	[0x00000088008000-0x0000008802bf3b], 0x23f3c bytes flags: 0x0
[    0.000000] On node 0 totalpages: 1024
[    0.000000] memblock_virt_alloc_try_nid_nopanic: 15728640 bytes align=0x0 nid=0 from=0x0 max_addr=0x0 alloc_node_mem_map.constprop.78+0x33/0x54
[    0.000000] free_area_init_node: node 0, pgdat 880208f4, node_mem_map 00000000
[    0.000000]   Normal zone: 3840 pages exceeds freesize 1024
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 1024 pages, LIFO batch:0
[    0.000000] memblock_virt_alloc_try_nid_nopanic: 720 bytes align=0x0 nid=0 from=0x0 max_addr=0x0 free_area_init_node+0x1b9/0x23a
[    0.000000] memblock_reserve: [0x000000883ffd20-0x000000883fffef] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid_nopanic: 16384 bytes align=0x0 nid=0 from=0x0 max_addr=0x0 zone_wait_table_init+0x53/0x94
[    0.000000] memblock_reserve: [0x000000883fbd20-0x000000883ffd1f] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 28 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 setup_arch+0x295/0x3a6
[    0.000000] memblock_reserve: [0x000000883fbd00-0x000000883fbd1b] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 12832 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f8ae0-0x000000883fbcff] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 24 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f8ac8-0x000000883f8adf] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 24 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f8ab0-0x000000883f8ac7] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 27 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f8a94-0x000000883f8aae] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 27 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f8a78-0x000000883f8a92] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 27 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f8a5c-0x000000883f8a76] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 27 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f8a40-0x000000883f8a5a] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 27 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f8a24-0x000000883f8a3e] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 24 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f8a0c-0x000000883f8a23] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 24 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f89f4-0x000000883f8a0b] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 24 bytes align=0x4 nid=-1 from=0x0 max_addr=0x0 early_init_dt_alloc_memory_arch+0x13/0x14
[    0.000000] memblock_reserve: [0x000000883f89dc-0x000000883f89f3] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 147 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 start_kernel+0x63/0x210
[    0.000000] memblock_reserve: [0x000000883f8940-0x000000883f89d2] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 147 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 start_kernel+0x7b/0x210
[    0.000000] memblock_reserve: [0x000000883f88a0-0x000000883f8932] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 147 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 start_kernel+0x91/0x210
[    0.000000] memblock_reserve: [0x000000883f8800-0x000000883f8892] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid_nopanic: 4096 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 pcpu_alloc_alloc_info+0x2f/0x4c
[    0.000000] memblock_reserve: [0x000000883f7800-0x000000883f87ff] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid_nopanic: 32768 bytes align=0x1000 nid=-1 from=0xffffffff max_addr=0x0 setup_per_cpu_areas+0x21/0x5c
[    0.000000] memblock_reserve: [0x000000883ef000-0x000000883f6fff] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 pcpu_setup_first_chunk+0x3b7/0x42a
[    0.000000] memblock_reserve: [0x000000883f77e0-0x000000883f77e3] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 pcpu_setup_first_chunk+0x3c9/0x42a
[    0.000000] memblock_reserve: [0x000000883f77c0-0x000000883f77c3] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 pcpu_setup_first_chunk+0x3d9/0x42a
[    0.000000] memblock_reserve: [0x000000883f77a0-0x000000883f77a3] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 4 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 pcpu_setup_first_chunk+0x3e9/0x42a
[    0.000000] memblock_reserve: [0x000000883f7780-0x000000883f7783] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] memblock_virt_alloc_try_nid: 120 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 pcpu_setup_first_chunk+0x1c5/0x42a
[    0.000000] memblock_reserve: [0x000000883f7700-0x000000883f7777] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] memblock_virt_alloc_try_nid: 48 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 pcpu_setup_first_chunk+0x1f5/0x42a
[    0.000000] memblock_reserve: [0x000000883f76c0-0x000000883f76ef] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1024
[    0.000000] Kernel command line: console=ttyefm4,115200 init=/linuxrc ignore_loglevel ihash_entries=64 dhash_entries=64 earlyprintk uclinux.physaddr=0x8c400000 root=/dev/mtdblock0
[    0.000000] memblock_virt_alloc_try_nid_nopanic: 64 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 alloc_large_system_hash+0xe9/0x180
[    0.000000] memblock_reserve: [0x000000883f7680-0x000000883f76bf] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] PID hash table entries: 16 (order: -6, 64 bytes)
[    0.000000] memblock_virt_alloc_try_nid_nopanic: 256 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 alloc_large_system_hash+0xe9/0x180
[    0.000000] memblock_reserve: [0x000000883f7580-0x000000883f767f] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
[    0.000000] Dentry cache hash table entries: 64 (order: -4, 256 bytes)
[    0.000000] memblock_virt_alloc_try_nid_nopanic: 256 bytes align=0x0 nid=-1 from=0x0 max_addr=0x0 alloc_large_system_hash+0xe9/0x180
[    0.000000] memblock_reserve: [0x000000883f7480-0x000000883f757f] flags 0x0 memblock_virt_alloc_internal+0x8d/0xe0
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
[    0.000000]        .bss : 0x88020f8c - 0x8802bf3c   (  44 kB)
[    0.000000] swapper: page allocation failure: order:0, mode:0x200000
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.15.0-rc1-00028-g1c2f87c22566-dirty #281
[    0.000000] [<8c002b95>] (unwind_backtrace) from [<8c001f0b>] (show_stack+0xb/0xc)
[    0.000000] [<8c001f0b>] (show_stack) from [<8c02e997>] (warn_alloc_failed+0x95/0xba)
[    0.000000] [<8c02e997>] (warn_alloc_failed) from [<8c02ff6b>] (__alloc_pages_nodemask+0x437/0x484)
[    0.000000] [<8c02ff6b>] (__alloc_pages_nodemask) from [<8c03b7c5>] (new_slab+0x51/0x184)
[    0.000000] [<8c03b7c5>] (new_slab) from [<8c03c1c5>] (__kmem_cache_create+0x5d/0x12c)
[    0.000000] [<8c03c1c5>] (__kmem_cache_create) from [<8c174667>] (create_boot_cache+0x23/0x3c)
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
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.15.0-rc1-00028-g1c2f87c22566-dirty #281
[    0.000000] task: 88015950 ti: 88008000 task.ti: 88008000
[    0.000000] PC is at show_mem+0x96/0x150
[    0.000000] LR is at 0x880251e0
[    0.000000] pc : [<8c00359a>]    lr : [<880251e0>]    psr: 0100000b
[    0.000000] sp : 88009e68  ip : 00088000  fp : 4100f101
[    0.000000] r10: 00000080  r9 : f7ff0047  r8 : 00000001
[    0.000000] r7 : 00000001  r6 : d0fb0f3f  r5 : 00000000  r4 : 00000000
[    0.000000] r3 : 00000060  r2 : 88025234  r1 : 00000004  r0 : 8801a2e8
[    0.000000] xPSR: 0100000b
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.15.0-rc1-00028-g1c2f87c22566-dirty #281
[    0.000000] [<8c002b95>] (unwind_backtrace) from [<8c001f0b>] (show_stack+0xb/0xc)
[    0.000000] [<8c001f0b>] (show_stack) from [<8c002547>] (__invalid_entry+0x4b/0x4c)

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
