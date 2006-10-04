Date: Wed, 4 Oct 2006 11:26:31 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v2] page_alloc: fix kernel-doc and func. declaration
In-Reply-To: <20061003161725.05155ce2.rdunlap@xenotime.net>
Message-ID: <Pine.LNX.4.64.0610041115270.21730@skynet.skynet.ie>
References: <20061003141445.0c502d45.rdunlap@xenotime.net>
 <Pine.LNX.4.64.0610031435590.22775@schroedinger.engr.sgi.com>
 <20061003154949.7953c6f9.rdunlap@xenotime.net>
 <Pine.LNX.4.64.0610031605300.23654@schroedinger.engr.sgi.com>
 <20061003161725.05155ce2.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Oct 2006, Randy Dunlap wrote:

> On Tue, 3 Oct 2006 16:05:47 -0700 (PDT) Christoph Lameter wrote:
>
>> On Tue, 3 Oct 2006, Randy Dunlap wrote:
>>
>>>> Hmmm. With the optional ZONE_DMA patch this becomes a reservation in the
>>>> first zone, which may be ZONE_NORMAL.
>>>
>>> I didn't change any of that wording.  Do you want to change it?
>>> do you want me to make that change?  or what?
>>
>> Just say it reserves from the first zone.
>
> Please check this.
>
> ---
> From: Randy Dunlap <rdunlap@xenotime.net>
>
> Fix kernel-doc and function declaration (missing "void") in
> mm/page_alloc.c.
> Add mm/page_alloc.c to kernel-api.tmpl in DocBook.
>
> mm/page_alloc.c:2589:38: warning: non-ANSI function declaration of function 'remove_all_active_ranges'
>

These issues are my fault. Thanks for the clean-up.

> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> ---
> Documentation/DocBook/kernel-api.tmpl |    1
> mm/page_alloc.c                       |   50 +++++++++++++++++-----------------
> 2 files changed, 26 insertions(+), 25 deletions(-)
>
> --- linux-2618-g19.orig/mm/page_alloc.c
> +++ linux-2618-g19/mm/page_alloc.c
> @@ -2050,8 +2050,8 @@ int __init early_pfn_to_nid(unsigned lon
>
> /**
>  * free_bootmem_with_active_regions - Call free_bootmem_node for each active range
> - * @nid: The node to free memory on. If MAX_NUMNODES, all nodes are freed
> - * @max_low_pfn: The highest PFN that till be passed to free_bootmem_node
> + * @nid: The node to free memory on. If MAX_NUMNODES, all nodes are freed.
> + * @max_low_pfn: The highest PFN that will be passed to free_bootmem_node

Should @max_low_pfn have a '.' at the end?

>  *
>  * If an architecture guarantees that all ranges registered with
>  * add_active_ranges() contain no holes and may be freed, this
> @@ -2081,11 +2081,11 @@ void __init free_bootmem_with_active_reg
>
> /**
>  * sparse_memory_present_with_active_regions - Call memory_present for each active range
> - * @nid: The node to call memory_present for. If MAX_NUMNODES, all nodes will be used
> + * @nid: The node to call memory_present for. If MAX_NUMNODES, all nodes will be used.
>  *
>  * If an architecture guarantees that all ranges registered with
>  * add_active_ranges() contain no holes and may be freed, this
> - * this function may be used instead of calling memory_present() manually.
> + * function may be used instead of calling memory_present() manually.

Looks fine.

>  */
> void __init sparse_memory_present_with_active_regions(int nid)
> {
> @@ -2155,14 +2155,14 @@ static void __init account_node_boundary
>
> /**
>  * get_pfn_range_for_nid - Return the start and end page frames for a node
> - * @nid: The nid to return the range for. If MAX_NUMNODES, the min and max PFN are returned
> - * @start_pfn: Passed by reference. On return, it will have the node start_pfn
> - * @end_pfn: Passed by reference. On return, it will have the node end_pfn
> + * @nid: The nid to return the range for. If MAX_NUMNODES, the min and max PFN are returned.
> + * @start_pfn: Passed by reference. On return, it will have the node start_pfn.
> + * @end_pfn: Passed by reference. On return, it will have the node end_pfn.
>  *
>  * It returns the start and end page frame of a node based on information
>  * provided by an arch calling add_active_range(). If called for a node
>  * with no available memory, a warning is printed and the start and end
> - * PFNs will be 0
> + * PFNs will be 0.
>  */
> void __init get_pfn_range_for_nid(unsigned int nid,
> 			unsigned long *start_pfn, unsigned long *end_pfn)
> @@ -2215,7 +2215,7 @@ unsigned long __init zone_spanned_pages_
>
> /*
>  * Return the number of holes in a range on a node. If nid is MAX_NUMNODES,
> - * then all holes in the requested range will be accounted for
> + * then all holes in the requested range will be accounted for.
>  */
> unsigned long __init __absent_pages_in_range(int nid,
> 				unsigned long range_start_pfn,
> @@ -2268,7 +2268,7 @@ unsigned long __init __absent_pages_in_r
>  * @start_pfn: The start PFN to start searching for holes
>  * @end_pfn: The end PFN to stop searching for holes
>  *
> - * It returns the number of pages frames in memory holes within a range
> + * It returns the number of pages frames in memory holes within a range.
>  */
> unsigned long __init absent_pages_in_range(unsigned long start_pfn,
> 							unsigned long end_pfn)
> @@ -2582,11 +2582,12 @@ void __init shrink_active_range(unsigned
>
> /**
>  * remove_all_active_ranges - Remove all currently registered regions
> + *

For future reference, I am going to assume the newline is required between 
the arguement list and the long description.

>  * During discovery, it may be found that a table like SRAT is invalid
>  * and an alternative discovery method must be used. This function removes
>  * all currently registered regions.
>  */
> -void __init remove_all_active_ranges()
> +void __init remove_all_active_ranges(void)

Looks good.

> {
> 	memset(early_node_map, 0, sizeof(early_node_map));
> 	nr_nodemap_entries = 0;
> @@ -2636,7 +2637,7 @@ unsigned long __init find_min_pfn_for_no
>  * find_min_pfn_with_active_regions - Find the minimum PFN registered
>  *
>  * It returns the minimum PFN based on information provided via
> - * add_active_range()
> + * add_active_range().
>  */
> unsigned long __init find_min_pfn_with_active_regions(void)
> {
> @@ -2647,7 +2648,7 @@ unsigned long __init find_min_pfn_with_a
>  * find_max_pfn_with_active_regions - Find the maximum PFN registered
>  *
>  * It returns the maximum PFN based on information provided via
> - * add_active_range()
> + * add_active_range().
>  */
> unsigned long __init find_max_pfn_with_active_regions(void)
> {
> @@ -2662,10 +2663,7 @@ unsigned long __init find_max_pfn_with_a
>
> /**
>  * free_area_init_nodes - Initialise all pg_data_t and zone data
> - * @arch_max_dma_pfn: The maximum PFN usable for ZONE_DMA
> - * @arch_max_dma32_pfn: The maximum PFN usable for ZONE_DMA32
> - * @arch_max_low_pfn: The maximum PFN usable for ZONE_NORMAL
> - * @arch_max_high_pfn: The maximum PFN usable for ZONE_HIGHMEM
> + * @max_zone_pfn: an array of max PFNs for each zone
>  *

This is correct.

>  * This will call free_area_init_node() for each active node in the system.
>  * Using the page ranges provided by add_active_range(), the size of each
> @@ -2723,14 +2721,15 @@ void __init free_area_init_nodes(unsigne
> #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
>
> /**
> - * set_dma_reserve - Account the specified number of pages reserved in ZONE_DMA
> - * @new_dma_reserve - The number of pages to mark reserved
> + * set_dma_reserve - set the specified number of pages reserved in the first zone
> + * @new_dma_reserve: The number of pages to mark reserved
>  *

Looks ok other than 'set' having a small 's'

>  * The per-cpu batchsize and zone watermarks are determined by present_pages.
>  * In the DMA zone, a significant percentage may be consumed by kernel image
>  * and other unfreeable allocations which can skew the watermarks badly. This
> - * function may optionally be used to account for unfreeable pages in
> - * ZONE_DMA. The effect will be lower watermarks and smaller per-cpu batchsize
> + * function may optionally be used to account for unfreeable pages in the
> + * first zone (e.g., ZONE_DMA). The effect will be lower watermarks and
> + * smaller per-cpu batchsize.
>  */

Looks ok.

> void __init set_dma_reserve(unsigned long new_dma_reserve)
> {
> @@ -2843,10 +2842,11 @@ static void setup_per_zone_lowmem_reserv
> 	calculate_totalreserve_pages();
> }
>
> -/*
> - * setup_per_zone_pages_min - called when min_free_kbytes changes.  Ensures
> - *	that the pages_{min,low,high} values for each zone are set correctly
> - *	with respect to min_free_kbytes.
> +/**
> + * setup_per_zone_pages_min - called when min_free_kbytes changes.
> + *
> + * Ensures that the pages_{min,low,high} values for each zone are set correctly
> + * with respect to min_free_kbytes.
>  */

Looks ok.

> void setup_per_zone_pages_min(void)
> {
> --- linux-2618-g19.orig/Documentation/DocBook/kernel-api.tmpl
> +++ linux-2618-g19/Documentation/DocBook/kernel-api.tmpl
> @@ -158,6 +158,7 @@ X!Ilib/string.c
> !Emm/filemap.c
> !Emm/memory.c
> !Emm/vmalloc.c
> +!Imm/page_alloc.c
> !Emm/mempool.c
> !Emm/page-writeback.c
> !Emm/truncate.c
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
