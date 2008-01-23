Date: Wed, 23 Jan 2008 10:22:23 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Message-ID: <20080123102222.GA21455@csn.ul.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (23/01/08 11:04), KOSAKI Motohiro didst pronounce:
> Hi mel
> 
> > Hi 
> > 
> > > A fix[1] was merged to the x86.git tree that allowed NUMA kernels to boot
> > > on normal x86 machines (and not just NUMA-Q, Summit etc.). I took a look
> > > at the restrictions on setting NUMA on x86 to see if they could be lifted.
> > 
> > Interesting!
> > 
> > I will test tomorrow.
> 
> Hmm...
> It doesn't works on my machine.
> 
> panic at booting at __free_pages_ok() with blow call trace.
> 
> [<hex number>] free_all_bootmem_core
> [<hex number>] mem_init
> [<hex number>] alloc_large_system_hash
> [<hex number>] inode_init_early
> [<hex number>] start_kernel
> [<hex number>] unknown_bootoption
> 
> my machine spec
> 	CPU:   Pentium4 with HT
> 	MEM:   512M
> 
> I will try more investigate.
> but I have no time for a while, sorry ;-)
> 
> 
> BTW:
> when config sparse mem turn on instead discontig mem.
> panic at booting at get_pageblock_flags_group() with below call stack.
> 
> free_initrd
> 	free_init_pages
> 		free_hot_cold_page
> 

To rule it out, can you also try with the patch below applied please? It
should only make a difference on sparsemem so if discontigmem is still
crashing, there is likely another problem. Assuming it crashes, please
post the full dmesg output with loglevel=8 on the command line. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
