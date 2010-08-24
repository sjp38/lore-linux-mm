Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CBD6C6B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 15:18:59 -0400 (EDT)
Date: Tue, 24 Aug 2010 21:21:08 +0200 (CEST)
From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: 2.6.34.1 page allocation failure
In-Reply-To: <4C74097A.5020504@kernel.org>
Message-ID: <alpine.DEB.1.10.1008242114120.8562@uplift.swm.pp.se>
References: <4C70BFF3.8030507@hardwarefreak.com> <alpine.DEB.1.10.1008220842400.8562@uplift.swm.pp.se> <AANLkTin48SJ58HvFqjrOnQBMqLcbECtqXokweV00dNgv@mail.gmail.com> <alpine.DEB.2.00.1008221734410.21916@router.home> <4C724141.8060000@kernel.org>
 <4C72F7C6.3020109@hardwarefreak.com> <4C74097A.5020504@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Stan Hoeppner <stan@hardwarefreak.com>, Christoph Lameter <cl@linux.com>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Linux Netdev List <netdev@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010, Pekka Enberg wrote:

> It looks to me as if tcp_create_openreq_child() is able to cope with the 
> situation so the warning could be harmless. If that's the case, we 
> should probably stick a __GFP_NOWARN there.

What about my situation? (a complete dmesg can be had at 
<http://swm.pp.se/dmesg.100809-2.txt.gz>)

[87578.494471] swapper: page allocation failure. order:0, mode:0x4020
[87578.494476] Pid: 0, comm: swapper Not tainted 2.6.32-24-generic #39-Ubuntu
[87578.494480] Call Trace:
[87578.494483]  <IRQ>  [<ffffffff810fad0e>] __alloc_pages_slowpath+0x56e/0x580
[87578.494499]  [<ffffffff810fae7e>] __alloc_pages_nodemask+0x15e/0x1a0
[87578.494506]  [<ffffffff8112dba7>] alloc_pages_current+0x87/0xd0
[87578.494511]  [<ffffffff81133b17>] new_slab+0x2f7/0x310
[87578.494516]  [<ffffffff811363c1>] __slab_alloc+0x201/0x2d0
[87578.494522]  [<ffffffff81455fe6>] ? __netdev_alloc_skb+0x36/0x60
[87578.494528]  [<ffffffff81137408>] __kmalloc_node_track_caller+0xb8/0x180
[87578.494532]  [<ffffffff81455fe6>] ? __netdev_alloc_skb+0x36/0x60
[87578.494536]  [<ffffffff81455ca0>] __alloc_skb+0x80/0x190
[87578.494540]  [<ffffffff81455fe6>] __netdev_alloc_skb+0x36/0x60
[87578.494564]  [<ffffffffa008f5c7>] rtl8169_rx_interrupt+0x247/0x5b0 [r8169]
[87578.494572]  [<ffffffffa008faad>] rtl8169_poll+0x3d/0x270 [r8169]
[87578.494580]  [<ffffffff810397a9>] ? default_spin_lock_flags+0x9/0x10
[87578.494586]  [<ffffffff8146029f>] net_rx_action+0x10f/0x250
[87578.494594]  [<ffffffffa008d54e>] ? rtl8169_interrupt+0xde/0x1e0 [r8169]
[87578.494600]  [<ffffffff8106e467>] __do_softirq+0xb7/0x1e0
[87578.494605]  [<ffffffff810c52c0>] ? handle_IRQ_event+0x60/0x170
[87578.494610]  [<ffffffff810142ec>] call_softirq+0x1c/0x30
[87578.494614]  [<ffffffff81015cb5>] do_softirq+0x65/0xa0
[87578.494618]  [<ffffffff8106e305>] irq_exit+0x85/0x90
[87578.494623]  [<ffffffff81549515>] do_IRQ+0x75/0xf0
[87578.494627]  [<ffffffff81013b13>] ret_from_intr+0x0/0x11
[87578.494629]  <EOI>  [<ffffffff8130f7cb>] ? acpi_idle_enter_c1+0xa3/0xc1
[87578.494639]  [<ffffffff8130f7aa>] ? acpi_idle_enter_c1+0x82/0xc1
[87578.494646]  [<ffffffff8143a5a7>] ? cpuidle_idle_call+0xa7/0x140
[87578.494652]  [<ffffffff81011e73>] ? cpu_idle+0xb3/0x110
[87578.494657]  [<ffffffff8153e27e>] ? start_secondary+0xa8/0xaa
[87578.494660] Mem-Info:
[87578.494662] Node 0 DMA per-cpu:
[87578.494666] CPU    0: hi:    0, btch:   1 usd:   0
[87578.494669] CPU    1: hi:    0, btch:   1 usd:   0
[87578.494672] CPU    2: hi:    0, btch:   1 usd:   0
[87578.494674] CPU    3: hi:    0, btch:   1 usd:   0
[87578.494677] Node 0 DMA32 per-cpu:
[87578.494680] CPU    0: hi:  186, btch:  31 usd: 173
[87578.494683] CPU    1: hi:  186, btch:  31 usd:  87
[87578.494686] CPU    2: hi:  186, btch:  31 usd: 168
[87578.494689] CPU    3: hi:  186, btch:  31 usd:  63
[87578.494691] Node 0 Normal per-cpu:
[87578.494695] CPU    0: hi:  186, btch:  31 usd: 177
[87578.494698] CPU    1: hi:  186, btch:  31 usd: 176
[87578.494700] CPU    2: hi:  186, btch:  31 usd:  82
[87578.494703] CPU    3: hi:  186, btch:  31 usd: 191
[87578.494710] active_anon:22970 inactive_anon:6433 isolated_anon:0
[87578.494711]  active_file:916528 inactive_file:914736 isolated_file:0
[87578.494713]  unevictable:0 dirty:135959 writeback:24423 unstable:0
[87578.494714]  free:9990 slab_reclaimable:59767 slab_unreclaimable:11135
[87578.494716]  mapped:119343 shmem:985 pagetables:2113 bounce:0
[87578.494719] Node 0 DMA free:15860kB min:20kB low:24kB high:28kB 
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15272kB 
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB 
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB 
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 
all_unreclaimable? yes
[87578.494733] lowmem_reserve[]: 0 2866 7852 7852
[87578.494738] Node 0 DMA32 free:21420kB min:4136kB low:5168kB high:6204kB 
active_anon:4056kB inactive_anon:5856kB active_file:1322360kB 
inactive_file:1320432kB unevictable:0kB isolated(anon):0kB 
isolated(file):0kB present:2935456kB mlocked:0kB dirty:190824kB 
writeback:31900kB mapped:157676kB shmem:0kB slab_reclaimable:107316kB 
slab_unreclaimable:15480kB kernel_stack:56kB pagetables:764kB unstable:0kB 
bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[87578.494754] lowmem_reserve[]: 0 0 4986 4986
[87578.494759] Node 0 Normal free:2680kB min:7192kB low:8988kB 
high:10788kB active_anon:87824kB inactive_anon:19876kB 
active_file:2343752kB inactive_file:2338512kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:5105664kB mlocked:0kB 
dirty:353012kB writeback:65792kB mapped:319696kB shmem:3940kB 
slab_reclaimable:131752kB slab_unreclaimable:29060kB kernel_stack:2160kB 
pagetables:7688kB unstable:0kB bounce:0kB writeback_tmp:0kB 
pages_scanned:0 all_unreclaimable? no
[87578.494775] lowmem_reserve[]: 0 0 0 0
[87578.494779] Node 0 DMA: 3*4kB 3*8kB 3*16kB 1*32kB 2*64kB 2*128kB 
0*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15860kB
[87578.494792] Node 0 DMA32: 789*4kB 765*8kB 589*16kB 1*32kB 1*64kB 
4*128kB 4*256kB 2*512kB 0*1024kB 0*2048kB 0*4096kB = 21356kB
[87578.494805] Node 0 Normal: 374*4kB 4*8kB 20*16kB 1*32kB 0*64kB 0*128kB 
1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 2648kB
[87578.494818] 1832322 total pagecache pages
[87578.494820] 0 pages in swap cache
[87578.494823] Swap cache stats: add 0, delete 0, find 0/0
[87578.494825] Free swap  = 0kB
[87578.494827] Total swap = 0kB
[87578.531041] 2064368 pages RAM
[87578.531044] 66019 pages reserved
[87578.531046] 1501227 pages shared
[87578.531048] 619257 pages non-shared
[87578.531053] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
[87578.531057]   cache: kmalloc-4096, object size: 4096, buffer size: 
4096, default order: 3, min order: 0
[87578.531061]   node 0: slabs: 1322, objs: 4129, free: 0

This actually made the machine go offline for hours before it for some 
reason came back. The second time this happened it did not come back 
(waited 8 hours).

I also seem to have TCP related problems:

[87578.531806]  [<ffffffff8113651f>] kmem_cache_alloc_node+0x8f/0x160
[87578.531812]  [<ffffffff81455c6f>] __alloc_skb+0x4f/0x190
[87578.531820]  [<ffffffff814acbe0>] ? tcp_delack_timer+0x0/0x270
[87578.531828]  [<ffffffff814ab423>] tcp_send_ack+0x33/0x120
[87578.531834]  [<ffffffff814acd22>] tcp_delack_timer+0x142/0x270
[87578.531842]  [<ffffffff8105a34d>] ? scheduler_tick+0x18d/0x260
[87578.531849]  [<ffffffff8107776b>] run_timer_softirq+0x19b/0x340
[87578.531857]  [<ffffffff81094ac0>] ? tick_sched_timer+0x0/0xc0
[87578.531865]  [<ffffffff8108f723>] ? ktime_get+0x63/0xe0
[87578.531871]  [<ffffffff8106e467>] __do_softirq+0xb7/0x1e0
[87578.531878]  [<ffffffff810946aa>] ? tick_program_event+0x2a/0x30
[87578.531885]  [<ffffffff810142ec>] call_softirq+0x1c/0x30
[87578.531891]  [<ffffffff81015cb5>] do_softirq+0x65/0xa0
[87578.531897]  [<ffffffff8106e305>] irq_exit+0x85/0x90
[87578.531904]  [<ffffffff81549601>] smp_apic_timer_interrupt+0x71/0x9c
[87578.531910]  [<ffffffff81013cb3>] apic_timer_interrupt+0x13/0x20
[87578.531914]  <EOI>  [<ffffffff8130fbbe>] ? acpi_idle_enter_simple+0x117/0x14b
[87578.531928]  [<ffffffff8130fbb7>] ? acpi_idle_enter_simple+0x110/0x14b
[87578.531936]  [<ffffffff8143a5a7>] ? cpuidle_idle_call+0xa7/0x140
[87578.531943]  [<ffffffff81011e73>] ? cpu_idle+0xb3/0x110
[87578.531950]  [<ffffffff8153e27e>] ? start_secondary+0xa8/0xaa


-- 
Mikael Abrahamsson    email: swmike@swm.pp.se

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
