Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id BEF9F6B0070
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 07:56:03 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id a1so810978wgh.39
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 04:56:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hc7si49395705wjc.87.2014.12.05.04.56.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 04:56:02 -0800 (PST)
Date: Fri, 5 Dec 2014 13:55:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Question] page allocation failure
Message-ID: <20141205125559.GC2321@dhcp22.suse.cz>
References: <BLUPR03MB373E2C46779976D0794B804F5790@BLUPR03MB373.namprd03.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLUPR03MB373E2C46779976D0794B804F5790@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Cc: "andi@firstfloor.org" <andi@firstfloor.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "vegardno@ifi.uio.no" <vegardno@ifi.uio.no>, "penberg@kernel.org" <penberg@kernel.org>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "ezequiel.garcia@free-electrons.com" <ezequiel.garcia@free-electrons.com>, "David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>

On Fri 05-12-14 10:22:49, fugang.duan@freescale.com wrote:
[...]
> [Playing  (List Repeated)][Vol=01][00:02:54/00:04:07]swapper/0: page allocation failure: order:0, mode:0x200020
> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.53-1.1.0_ga+g67f859d #1
> [<80013b00>] (unwind_backtrace+0x0/0xf4) from [<80011524>] (show_stack+0x10/0x14)
> [<80011524>] (show_stack+0x10/0x14) from [<80094474>] (warn_alloc_failed+0xe0/0x118)
> [<80094474>] (warn_alloc_failed+0xe0/0x118) from [<8009723c>] (__alloc_pages_nodemask+0x640/0x89c)
> [<8009723c>] (__alloc_pages_nodemask+0x640/0x89c) from [<800c13e4>] (new_slab+0x1e4/0x218)
> [<800c13e4>] (new_slab+0x1e4/0x218) from [<8067ef38>] (__slab_alloc.isra.64.constprop.69+0x380/0x590)
> [<8067ef38>] (__slab_alloc.isra.64.constprop.69+0x380/0x590) from [<800c29a8>] (kmem_cache_alloc+0xdc/0x110)
> [<800c29a8>] (kmem_cache_alloc+0xdc/0x110) from [<805197d0>] (build_skb+0x28/0x98)
> [<805197d0>] (build_skb+0x28/0x98) from [<8051c0c8>] (__netdev_alloc_skb+0x54/0xfc)
> [<8051c0c8>] (__netdev_alloc_skb+0x54/0xfc) from [<803ab878>] (fec_enet_rx_napi+0x758/0xa28)
> [<803ab878>] (fec_enet_rx_napi+0x758/0xa28) from [<80527618>] (net_rx_action+0xbc/0x17c)
> [<80527618>] (net_rx_action+0xbc/0x17c) from [<800332ec>] (__do_softirq+0x120/0x200)
> [<800332ec>] (__do_softirq+0x120/0x200) from [<80033460>] (do_softirq+0x50/0x58)
> [<80033460>] (do_softirq+0x50/0x58) from [<800336fc>] (irq_exit+0x9c/0xd0)
> [<800336fc>] (irq_exit+0x9c/0xd0) from [<8000e94c>] (handle_IRQ+0x44/0x90)
> [<8000e94c>] (handle_IRQ+0x44/0x90) from [<80008558>] (gic_handle_irq+0x2c/0x5c)
> [<80008558>] (gic_handle_irq+0x2c/0x5c) from [<8000dc80>] (__irq_svc+0x40/0x70)
> Exception stack(0x80cbff20 to 0x80cbff68)
> ff20: 80cbff68 00003fee b2931c73 00000ee2 b292c14d 00000ee2 81597180 80ccbd68
> ff40: 00000000 00000000 80cbe000 80cbe000 00000017 80cbff68 8005fbd4 80456db0
> ff60: 60010013 ffffffff
> [<8000dc80>] (__irq_svc+0x40/0x70) from [<80456db0>] (cpuidle_enter_state+0x50/0xe0)
> [<80456db0>] (cpuidle_enter_state+0x50/0xe0) from [<80456ef0>] (cpuidle_idle_call+0xb0/0x148)
> [<80456ef0>] (cpuidle_idle_call+0xb0/0x148) from [<8000ec68>] (arch_cpu_idle+0x10/0x54)
> [<8000ec68>] (arch_cpu_idle+0x10/0x54) from [<8005f4a8>] (cpu_startup_entry+0x104/0x150)
> [<8005f4a8>] (cpu_startup_entry+0x104/0x150) from [<80c71a9c>] (start_kernel+0x324/0x330)
> Mem-info:
> DMA per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 208
> CPU    1: hi:  186, btch:  31 usd:   0
> CPU    2: hi:  186, btch:  31 usd:   0
> CPU    3: hi:  186, btch:  31 usd:  97
> active_anon:11642 inactive_anon:331 isolated_anon:0
> active_file:78585 inactive_file:79182 isolated_file:0
> unevictable:0 dirty:0 writeback:0 unstable:0
> free:35948 slab_reclaimable:1318 slab_unreclaimable:2242
> mapped:5698 shmem:367 pagetables:477 bounce:0
> free_cma:35784
> DMA free:143792kB min:3336kB low:4168kB high:5004kB active_anon:46568kB inactive_anon:1324kB active_file:314340kB inactive_file:316728kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1048576kB managed:697164kB mlocked:0kB dirty:0kB writeback:0kB mapped:22792kB shmem:1468kB slab_reclaimable:5272kB slab_unreclaimable:8968kB kernel_stack:1704kB pagetables:1908kB unstable:0kB bounce:0kB free_cma:143136kB writeback_tmp:0kB pages_scanned:51 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> DMA: 4452*4kB (UC) 4382*8kB (UC) 4111*16kB (UC) 786*32kB (UC) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB = 143792kB

All your remaining memory is apparently reserved for C - CMA allocator.
I would recommend to contact CMA people and check your configuration
with them.

> 158126 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> SLUB: Unable to allocate memory on node -1 (gfp=0x20)
>   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
>   node 0: slabs: 0, objs: 0, free: 0
> [Playing  (List Repeated)][Vol=01][00:02:56/00:04:07]
> 
> 
> Regards,
> Andy

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
