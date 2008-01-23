Date: Wed, 23 Jan 2008 11:04:13 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
In-Reply-To: <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

Hi mel

> Hi 
> 
> > A fix[1] was merged to the x86.git tree that allowed NUMA kernels to boot
> > on normal x86 machines (and not just NUMA-Q, Summit etc.). I took a look
> > at the restrictions on setting NUMA on x86 to see if they could be lifted.
> 
> Interesting!
> 
> I will test tomorrow.

Hmm...
It doesn't works on my machine.

panic at booting at __free_pages_ok() with blow call trace.

[<hex number>] free_all_bootmem_core
[<hex number>] mem_init
[<hex number>] alloc_large_system_hash
[<hex number>] inode_init_early
[<hex number>] start_kernel
[<hex number>] unknown_bootoption

my machine spec
	CPU:   Pentium4 with HT
	MEM:   512M

I will try more investigate.
but I have no time for a while, sorry ;-)


BTW:
when config sparse mem turn on instead discontig mem.
panic at booting at get_pageblock_flags_group() with below call stack.

free_initrd
	free_init_pages
		free_hot_cold_page



- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
