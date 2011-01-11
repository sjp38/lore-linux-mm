Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 46C326B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 20:36:47 -0500 (EST)
Date: Mon, 10 Jan 2011 20:36:43 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1378144890.40011.1294709803962.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <alpine.DEB.2.00.1101101602520.16216@chino.kir.corp.google.com>
Subject: Re: known oom issues on numa in -mm tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> sysrq+m would be interesting to see the state of memory when you
> suspect we're oom.
SysRq : Show Memory
Mem-Info:
Node 0 DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
CPU    2: hi:    0, btch:   1 usd:   0
CPU    3: hi:    0, btch:   1 usd:   0
CPU    4: hi:    0, btch:   1 usd:   0
CPU    5: hi:    0, btch:   1 usd:   0
CPU    6: hi:    0, btch:   1 usd:   0
CPU    7: hi:    0, btch:   1 usd:   0
Node 0 DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:   0
CPU    4: hi:  186, btch:  31 usd:   0
CPU    5: hi:  186, btch:  31 usd:   0
CPU    6: hi:  186, btch:  31 usd:   0
CPU    7: hi:  186, btch:  31 usd:   0
Node 0 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:   0
CPU    4: hi:  186, btch:  31 usd:  28
CPU    5: hi:  186, btch:  31 usd:   0
CPU    6: hi:  186, btch:  31 usd:   0
CPU    7: hi:  186, btch:  31 usd:   0
Node 1 Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:   0
CPU    2: hi:  186, btch:  31 usd:   0
CPU    3: hi:  186, btch:  31 usd:   0
CPU    4: hi:  186, btch:  31 usd:   0
CPU    5: hi:  186, btch:  31 usd:   0
CPU    6: hi:  186, btch:  31 usd:   0
CPU    7: hi:  186, btch:  31 usd:   0
active_anon:1994685 inactive_anon:1533 isolated_anon:0
 active_file:1004 inactive_file:3424 isolated_file:0
 unevictable:0 dirty:3 writeback:0 unstable:0
 free:1707554 slab_reclaimable:14808 slab_unreclaimable:97380
 mapped:856 shmem:51 pagetables:4746 bounce:0
Node 0 DMA free:15888kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15664kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 3255 8053 8053
Node 0 DMA32 free:2201196kB min:3276kB low:4092kB high:4912kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3333976kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 4797 4797
Node 0 Normal free:4605172kB min:4828kB low:6032kB high:7240kB active_anon:10688kB inactive_anon:6100kB active_file:3964kB inactive_file:13696kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:4912640kB mlocked:0kB dirty:12kB writeback:0kB mapped:3416kB shmem:204kB slab_reclaimable:22992kB slab_unreclaimable:169848kB kernel_stack:960kB pagetables:1784kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 1 Normal free:7960kB min:8136kB low:10168kB high:12204kB active_anon:7968052kB inactive_anon:32kB active_file:52kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:8273920kB mlocked:0kB dirty:0kB writeback:0kB mapped:8kB shmem:0kB slab_reclaimable:36240kB slab_unreclaimable:219672kB kernel_stack:224kB pagetables:17200kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 0*4kB 0*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15888kB
Node 0 DMA32: 11*4kB 12*8kB 8*16kB 7*32kB 6*64kB 8*128kB 9*256kB 3*512kB 4*1024kB 2*2048kB 534*4096kB = 2201196kB
Node 0 Normal: 1487*4kB 916*8kB 533*16kB 348*32kB 192*64kB 136*128kB 104*256kB 54*512kB 25*1024kB 7*2048kB 1086*4096kB = 4605100kB
Node 1 Normal: 955*4kB 11*8kB 5*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 8084kB
4484 total pagecache pages
0 pages in swap cache
Swap cache stats: add 2446987, delete 2446987, find 397/515
Free swap  = 0kB
Total swap = 0kB
4194288 pages RAM
355106 pages reserved
4066 pages shared
2059455 pages non-shared

> > oom02 R running task 0 2057 2053 0x00000088
> >  0000000000000282 ffffffffffffff10 ffffffff81098272 0000000000000010
> >  0000000000000202 ffff8802159d7a18 0000000000000018 ffffffff81098252
> >  01ff8802159d7a28 0000000000000000 0000000000000000 ffffffff810ffd60
> > Call Trace:
> >  [<ffffffff81098272>] ? smp_call_function_many+0x1b2/0x210
> >  [<ffffffff81098252>] ? smp_call_function_many+0x192/0x210
> >  [<ffffffff810ffd60>] ? drain_local_pages+0x0/0x20
> >  [<ffffffff810982f2>] ? smp_call_function+0x22/0x30
> >  [<ffffffff81067df4>] ? on_each_cpu+0x24/0x50
> >  [<ffffffff810fdbec>] ? drain_all_pages+0x1c/0x20
> 
> This suggests we're in the direct reclaim path and not currently
> considered to be in the hopeless situation of oom.
The question here is why it was taking so long (can't oom after tens' of
minutes) even swap devices disabled. As you can also see from the above
sysrq-m output, the test did exhaust the Node 1 Normal zone.

Thanks.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
