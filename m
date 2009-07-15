Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A08396B004F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 02:10:54 -0400 (EDT)
Date: Wed, 15 Jul 2009 08:47:54 +0200
From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: What to do with this message (2.6.30.1) ?
Message-Id: <20090715084754.36ff73bf.skraw@ithnet.com>
In-Reply-To: <alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com>
References: <20090713134621.124aa18e.skraw@ithnet.com>
	<4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com>
	<alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 2009 22:53:29 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Stephan, perhaps you can try with a CONFIG_SLUB kernel and enable both 
> CONFIG_SLUB_DEBUG and CONFIG_SLUB_DEBUG_ON?  If that doesn't reveal any 
> additional information, this sounds like a candidate for kmemleak.

Well, that does not seem to make a major difference, please have a look at the first three of numerous outputs:


Jul 15 03:01:26 backup kernel: swapper: page allocation failure. order:1, mode:0x4020
Jul 15 03:01:26 backup kernel: Pid: 0, comm: swapper Not tainted 2.6.30.1 #4
Jul 15 03:01:26 backup kernel: Call Trace:
Jul 15 03:01:26 backup kernel:  <IRQ>  [<ffffffff8026919e>] ? __alloc_pages_internal+0x3df/0x3ff
Jul 15 03:01:26 backup kernel:  [<ffffffff802892f3>] ? __slab_alloc+0x175/0x4ba
Jul 15 03:01:26 backup kernel:  [<ffffffff803f2a90>] ? __netdev_alloc_skb+0x15/0x2f
Jul 15 03:01:26 backup kernel:  [<ffffffff803f2a90>] ? __netdev_alloc_skb+0x15/0x2f
Jul 15 03:01:26 backup kernel:  [<ffffffff80289c7d>] ? __kmalloc_track_caller+0x8f/0xb6
Jul 15 03:01:26 backup kernel:  [<ffffffff803f1ec2>] ? __alloc_skb+0x61/0x12f
Jul 15 03:01:26 backup kernel:  [<ffffffff803f2a90>] ? __netdev_alloc_skb+0x15/0x2f
Jul 15 03:01:26 backup kernel:  [<ffffffffa0049da0>] ? e1000_alloc_rx_buffers+0x8c/0x248 [e1000e]
Jul 15 03:01:26 backup kernel:  [<ffffffffa004a262>] ? e1000_clean_rx_irq+0x2a2/0x2db [e1000e]
Jul 15 03:01:26 backup kernel:  [<ffffffffa004b8dc>] ? e1000_clean+0x70/0x219 [e1000e]
Jul 15 03:01:27 backup kernel:  [<ffffffff803f6017>] ? net_rx_action+0x69/0x11f
Jul 15 03:01:27 backup kernel:  [<ffffffff802373eb>] ? __do_softirq+0x66/0xf7
Jul 15 03:01:27 backup kernel:  [<ffffffff8020bebc>] ? call_softirq+0x1c/0x28
Jul 15 03:01:27 backup kernel:  [<ffffffff8020d680>] ? do_softirq+0x2c/0x68
Jul 15 03:01:27 backup kernel:  [<ffffffff8020cf62>] ? do_IRQ+0xa9/0xbf
Jul 15 03:01:27 backup kernel:  [<ffffffff8020b793>] ? ret_from_intr+0x0/0xa
Jul 15 03:01:27 backup kernel:  <EOI>  [<ffffffff802116d8>] ? mwait_idle+0x6e/0x73
Jul 15 03:01:27 backup kernel:  [<ffffffff802116d8>] ? mwait_idle+0x6e/0x73
Jul 15 03:01:27 backup kernel:  [<ffffffff8020a1cb>] ? cpu_idle+0x40/0x7c
Jul 15 03:01:28 backup kernel:  [<ffffffff805a9bb0>] ? start_kernel+0x31e/0x32a
Jul 15 03:01:28 backup kernel:  [<ffffffff805a937e>] ? x86_64_start_kernel+0xe5/0xeb
Jul 15 03:01:28 backup kernel: DMA per-cpu:
Jul 15 03:01:28 backup kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 15 03:01:28 backup kernel: CPU    1: hi:    0, btch:   1 usd:   0
Jul 15 03:01:28 backup kernel: CPU    2: hi:    0, btch:   1 usd:   0
Jul 15 03:01:28 backup kernel: CPU    3: hi:    0, btch:   1 usd:   0
Jul 15 03:01:28 backup kernel: DMA32 per-cpu:
Jul 15 03:01:28 backup kernel: CPU    0: hi:  186, btch:  31 usd: 157
Jul 15 03:01:28 backup kernel: CPU    1: hi:  186, btch:  31 usd:  62
Jul 15 03:01:28 backup kernel: CPU    2: hi:  186, btch:  31 usd:  84
Jul 15 03:01:28 backup kernel: CPU    3: hi:  186, btch:  31 usd:  41
Jul 15 03:01:28 backup kernel: Normal per-cpu:
Jul 15 03:01:28 backup kernel: CPU    0: hi:  186, btch:  31 usd: 175
Jul 15 03:01:28 backup kernel: CPU    1: hi:  186, btch:  31 usd:  73
Jul 15 03:01:28 backup kernel: CPU    2: hi:  186, btch:  31 usd:  33
Jul 15 03:01:28 backup kernel: CPU    3: hi:  186, btch:  31 usd:  56
Jul 15 03:01:28 backup kernel: Active_anon:32502 active_file:111663 inactive_anon:8167
Jul 15 03:01:28 backup kernel:  inactive_file:1332510 unevictable:0 dirty:39449 writeback:1586 unstable:0
Jul 15 03:01:28 backup kernel:  free:10034 slab:546449 mapped:1841 pagetables:1189 bounce:0
Jul 15 03:01:28 backup kernel: DMA free:11704kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:10752kB pages_scanned:0 all_unreclaimable? yes
Jul 15 03:01:28 backup kernel: lowmem_reserve[]: 0 3767 8059 8059
Jul 15 03:01:28 backup kernel: DMA32 free:22052kB min:5364kB low:6704kB high:8044kB active_anon:19216kB inactive_anon:4032kB active_file:113380kB inactive_file:2196508kB unevictable:0kB present:3857440kB pages_scanned:0 all_unreclaimable? no
Jul 15 03:01:28 backup kernel: lowmem_reserve[]: 0 0 4292 4292
Jul 15 03:01:28 backup kernel: Normal free:6380kB min:6112kB low:7640kB high:9168kB active_anon:110792kB inactive_anon:28636kB active_file:333272kB inactive_file:3133532kB unevictable:0kB present:4395520kB pages_scanned:0 all_unreclaimable? no
Jul 15 03:01:28 backup kernel: lowmem_reserve[]: 0 0 0 0
Jul 15 03:01:28 backup kernel: DMA: 6*4kB 6*8kB 3*16kB 2*32kB 4*64kB 2*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 2*4096kB = 11704kB
Jul 15 03:01:28 backup kernel: DMA32: 5283*4kB 93*8kB 2*16kB 0*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22036kB
Jul 15 03:01:28 backup kernel: Normal: 1310*4kB 99*8kB 6*16kB 0*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6256kB
Jul 15 03:01:29 backup kernel: 1444268 total pagecache pages
Jul 15 03:01:29 backup kernel: 34 pages in swap cache
Jul 15 03:01:29 backup kernel: Swap cache stats: add 118, delete 84, find 0/2
Jul 15 03:01:29 backup kernel: Free swap  = 2104080kB
Jul 15 03:01:29 backup kernel: Total swap = 2104488kB


Jul 15 03:01:29 backup kernel: swapper: page allocation failure. order:1, mode:0x4020
Jul 15 03:01:29 backup kernel: Pid: 0, comm: swapper Not tainted 2.6.30.1 #4
Jul 15 03:01:29 backup kernel: Call Trace:
Jul 15 03:01:29 backup kernel:  <IRQ>  [<ffffffff8026919e>] ? __alloc_pages_internal+0x3df/0x3ff
Jul 15 03:01:29 backup kernel:  [<ffffffff802892f3>] ? __slab_alloc+0x175/0x4ba
Jul 15 03:01:29 backup kernel:  [<ffffffff803f2a90>] ? __netdev_alloc_skb+0x15/0x2f
Jul 15 03:01:29 backup kernel:  [<ffffffff803f2a90>] ? __netdev_alloc_skb+0x15/0x2f
Jul 15 03:01:29 backup kernel:  [<ffffffff80289c7d>] ? __kmalloc_track_caller+0x8f/0xb6
Jul 15 03:01:29 backup kernel:  [<ffffffff803f1ec2>] ? __alloc_skb+0x61/0x12f
Jul 15 03:01:29 backup kernel:  [<ffffffff803f2a90>] ? __netdev_alloc_skb+0x15/0x2f
Jul 15 03:01:29 backup kernel:  [<ffffffffa0049da0>] ? e1000_alloc_rx_buffers+0x8c/0x248 [e1000e]
Jul 15 03:01:29 backup kernel:  [<ffffffffa004a262>] ? e1000_clean_rx_irq+0x2a2/0x2db [e1000e]
Jul 15 03:01:29 backup kernel:  [<ffffffffa004b8dc>] ? e1000_clean+0x70/0x219 [e1000e]
Jul 15 03:01:29 backup kernel:  [<ffffffff803f6017>] ? net_rx_action+0x69/0x11f
Jul 15 03:01:29 backup kernel:  [<ffffffff802373eb>] ? __do_softirq+0x66/0xf7
Jul 15 03:01:29 backup kernel:  [<ffffffff8020bebc>] ? call_softirq+0x1c/0x28
Jul 15 03:01:29 backup kernel:  [<ffffffff8020d680>] ? do_softirq+0x2c/0x68
Jul 15 03:01:29 backup kernel:  [<ffffffff8020cf62>] ? do_IRQ+0xa9/0xbf
Jul 15 03:01:29 backup kernel:  [<ffffffff8020b793>] ? ret_from_intr+0x0/0xa
Jul 15 03:01:29 backup kernel:  <EOI>  [<ffffffff802116d8>] ? mwait_idle+0x6e/0x73
Jul 15 03:01:29 backup kernel:  [<ffffffff8020a1cb>] ? cpu_idle+0x40/0x7c
Jul 15 03:01:29 backup kernel:  [<ffffffff805a9bb0>] ? start_kernel+0x31e/0x32a
Jul 15 03:01:29 backup kernel:  [<ffffffff805a937e>] ? x86_64_start_kernel+0xe5/0xeb
Jul 15 03:01:29 backup kernel: DMA per-cpu:
Jul 15 03:01:29 backup kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 15 03:01:29 backup kernel: CPU    1: hi:    0, btch:   1 usd:   0
Jul 15 03:01:29 backup kernel: CPU    2: hi:    0, btch:   1 usd:   0
Jul 15 03:01:29 backup kernel: CPU    3: hi:    0, btch:   1 usd:   0
Jul 15 03:01:29 backup kernel: DMA32 per-cpu:
Jul 15 03:01:29 backup kernel: CPU    0: hi:  186, btch:  31 usd: 157
Jul 15 03:01:29 backup kernel: CPU    1: hi:  186, btch:  31 usd:  62
Jul 15 03:01:29 backup kernel: CPU    2: hi:  186, btch:  31 usd:  84
Jul 15 03:01:29 backup kernel: CPU    3: hi:  186, btch:  31 usd:  41
Jul 15 03:01:29 backup kernel: Normal per-cpu:
Jul 15 03:01:29 backup kernel: CPU    0: hi:  186, btch:  31 usd: 167
Jul 15 03:01:29 backup kernel: CPU    1: hi:  186, btch:  31 usd:  73
Jul 15 03:01:29 backup kernel: CPU    2: hi:  186, btch:  31 usd:  33
Jul 15 03:01:29 backup kernel: CPU    3: hi:  186, btch:  31 usd:  56
Jul 15 03:01:29 backup kernel: Active_anon:32502 active_file:111663 inactive_anon:8167
Jul 15 03:01:29 backup kernel:  inactive_file:1332510 unevictable:0 dirty:39449 writeback:1586 unstable:0
Jul 15 03:01:29 backup kernel:  free:10034 slab:546449 mapped:1841 pagetables:1189 bounce:0
Jul 15 03:01:29 backup kernel: DMA free:11704kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:10752kB pages_scanned:0 all_unreclaimable? yes
Jul 15 03:01:29 backup kernel: lowmem_reserve[]: 0 3767 8059 8059
Jul 15 03:01:29 backup kernel: DMA32 free:22052kB min:5364kB low:6704kB high:8044kB active_anon:19216kB inactive_anon:4032kB active_file:113380kB inactive_file:2196508kB unevictable:0kB present:3857440kB pages_scanned:0 all_unreclaimable? no
Jul 15 03:01:29 backup kernel: lowmem_reserve[]: 0 0 4292 4292
Jul 15 03:01:29 backup kernel: Normal free:6380kB min:6112kB low:7640kB high:9168kB active_anon:110792kB inactive_anon:28636kB active_file:333272kB inactive_file:3133532kB unevictable:0kB present:4395520kB pages_scanned:0 all_unreclaimable? no
Jul 15 03:01:29 backup kernel: lowmem_reserve[]: 0 0 0 0
Jul 15 03:01:29 backup kernel: DMA: 6*4kB 6*8kB 3*16kB 2*32kB 4*64kB 2*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 2*4096kB = 11704kB
Jul 15 03:01:29 backup kernel: DMA32: 5283*4kB 93*8kB 2*16kB 0*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22036kB
Jul 15 03:01:29 backup kernel: Normal: 1310*4kB 99*8kB 6*16kB 0*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6256kB
Jul 15 03:01:29 backup kernel: 1444268 total pagecache pages
Jul 15 03:01:29 backup kernel: 34 pages in swap cache
Jul 15 03:01:29 backup kernel: Swap cache stats: add 118, delete 84, find 0/2
Jul 15 03:01:29 backup kernel: Free swap  = 2104080kB
Jul 15 03:01:29 backup kernel: Total swap = 2104488kB


Jul 15 03:01:29 backup kernel: swapper: page allocation failure. order:1, mode:0x4020
Jul 15 03:01:29 backup kernel: Pid: 0, comm: swapper Not tainted 2.6.30.1 #4
Jul 15 03:01:29 backup kernel: Call Trace:
Jul 15 03:01:29 backup kernel:  <IRQ>  [<ffffffff8026919e>] ? __alloc_pages_internal+0x3df/0x3ff
Jul 15 03:01:29 backup kernel:  [<ffffffff802892f3>] ? __slab_alloc+0x175/0x4ba
Jul 15 03:01:29 backup kernel:  [<ffffffff803f2a90>] ? __netdev_alloc_skb+0x15/0x2f
Jul 15 03:01:29 backup kernel:  [<ffffffff803f2a90>] ? __netdev_alloc_skb+0x15/0x2f
Jul 15 03:01:29 backup kernel:  [<ffffffff80289c7d>] ? __kmalloc_track_caller+0x8f/0xb6
Jul 15 03:01:29 backup kernel:  [<ffffffff803f1ec2>] ? __alloc_skb+0x61/0x12f
Jul 15 03:01:29 backup kernel:  [<ffffffff803f2a90>] ? __netdev_alloc_skb+0x15/0x2f
Jul 15 03:01:29 backup kernel:  [<ffffffffa0049da0>] ? e1000_alloc_rx_buffers+0x8c/0x248 [e1000e]
Jul 15 03:01:29 backup kernel:  [<ffffffffa004a262>] ? e1000_clean_rx_irq+0x2a2/0x2db [e1000e]
Jul 15 03:01:29 backup kernel:  [<ffffffffa0048222>] ? e1000_clean_tx_irq+0xc7/0x2d9 [e1000e]
Jul 15 03:01:29 backup kernel:  [<ffffffffa004b8dc>] ? e1000_clean+0x70/0x219 [e1000e]
Jul 15 03:01:29 backup kernel:  [<ffffffff803f6017>] ? net_rx_action+0x69/0x11f
Jul 15 03:01:29 backup kernel:  [<ffffffff802373eb>] ? __do_softirq+0x66/0xf7
Jul 15 03:01:29 backup kernel:  [<ffffffff8020bebc>] ? call_softirq+0x1c/0x28
Jul 15 03:01:29 backup kernel:  [<ffffffff8020d680>] ? do_softirq+0x2c/0x68
Jul 15 03:01:29 backup kernel:  [<ffffffff8020cf62>] ? do_IRQ+0xa9/0xbf
Jul 15 03:01:29 backup kernel:  [<ffffffff8020b793>] ? ret_from_intr+0x0/0xa
Jul 15 03:01:29 backup kernel:  <EOI>  [<ffffffff802116d8>] ? mwait_idle+0x6e/0x73
Jul 15 03:01:29 backup kernel:  [<ffffffff802116d8>] ? mwait_idle+0x6e/0x73
Jul 15 03:01:29 backup kernel:  [<ffffffff8020a1cb>] ? cpu_idle+0x40/0x7c
Jul 15 03:01:29 backup kernel:  [<ffffffff805a9bb0>] ? start_kernel+0x31e/0x32a
Jul 15 03:01:29 backup kernel:  [<ffffffff805a937e>] ? x86_64_start_kernel+0xe5/0xeb
Jul 15 03:01:29 backup kernel: DMA per-cpu:
Jul 15 03:01:29 backup kernel: CPU    0: hi:    0, btch:   1 usd:   0
Jul 15 03:01:29 backup kernel: CPU    1: hi:    0, btch:   1 usd:   0
Jul 15 03:01:29 backup kernel: CPU    2: hi:    0, btch:   1 usd:   0
Jul 15 03:01:29 backup kernel: CPU    3: hi:    0, btch:   1 usd:   0
Jul 15 03:01:29 backup kernel: DMA32 per-cpu:
Jul 15 03:01:29 backup kernel: CPU    0: hi:  186, btch:  31 usd: 157
Jul 15 03:01:29 backup kernel: CPU    1: hi:  186, btch:  31 usd:  62
Jul 15 03:01:29 backup kernel: CPU    2: hi:  186, btch:  31 usd:  84
Jul 15 03:01:29 backup kernel: CPU    3: hi:  186, btch:  31 usd:  41
Jul 15 03:01:29 backup kernel: Normal per-cpu:
Jul 15 03:01:29 backup kernel: CPU    0: hi:  186, btch:  31 usd: 167
Jul 15 03:01:29 backup kernel: CPU    1: hi:  186, btch:  31 usd:  73
Jul 15 03:01:29 backup kernel: CPU    2: hi:  186, btch:  31 usd:  33
Jul 15 03:01:29 backup kernel: CPU    3: hi:  186, btch:  31 usd:  56
Jul 15 03:01:30 backup kernel: Active_anon:32502 active_file:111663 inactive_anon:8167
Jul 15 03:01:30 backup kernel:  inactive_file:1332510 unevictable:0 dirty:39449 writeback:1586 unstable:0
Jul 15 03:01:30 backup kernel:  free:10034 slab:546449 mapped:1841 pagetables:1189 bounce:0
Jul 15 03:01:30 backup kernel: DMA free:11704kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:10752kB pages_scanned:0 all_unreclaimable? yes
Jul 15 03:01:30 backup kernel: lowmem_reserve[]: 0 3767 8059 8059
Jul 15 03:01:30 backup kernel: DMA32 free:22052kB min:5364kB low:6704kB high:8044kB active_anon:19216kB inactive_anon:4032kB active_file:113380kB inactive_file:2196508kB unevictable:0kB present:3857440kB pages_scanned:0 all_unreclaimable? no
Jul 15 03:01:30 backup kernel: lowmem_reserve[]: 0 0 4292 4292
Jul 15 03:01:30 backup kernel: Normal free:6380kB min:6112kB low:7640kB high:9168kB active_anon:110792kB inactive_anon:28636kB active_file:333272kB inactive_file:3133532kB unevictable:0kB present:4395520kB pages_scanned:0 all_unreclaimable? no
Jul 15 03:01:30 backup kernel: lowmem_reserve[]: 0 0 0 0
Jul 15 03:01:30 backup kernel: DMA: 6*4kB 6*8kB 3*16kB 2*32kB 4*64kB 2*128kB 1*256kB 1*512kB 2*1024kB 0*2048kB 2*4096kB = 11704kB
Jul 15 03:01:30 backup kernel: DMA32: 5283*4kB 93*8kB 2*16kB 0*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22036kB
Jul 15 03:01:30 backup kernel: Normal: 1310*4kB 99*8kB 6*16kB 0*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6256kB
Jul 15 03:01:30 backup kernel: 1444268 total pagecache pages
Jul 15 03:01:30 backup kernel: 34 pages in swap cache
Jul 15 03:01:30 backup kernel: Swap cache stats: add 118, delete 84, find 0/2
Jul 15 03:01:30 backup kernel: Free swap  = 2104080kB
Jul 15 03:01:30 backup kernel: Total swap = 2104488kB



-- 
Regards,
Stephan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
