Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 87F4F6B0068
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 20:57:14 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so5634524wib.8
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 17:57:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120906090325.GO11266@suse.de>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
	<1346832673-12512-2-git-send-email-minchan@kernel.org>
	<20120905105611.GI11266@suse.de>
	<20120906053112.GA16231@bbox>
	<20120906082935.GN11266@suse.de>
	<20120906090325.GO11266@suse.de>
Date: Fri, 7 Sep 2012 09:57:12 +0900
Message-ID: <CAH9JG2VS62qU1FozAAhTmL0cgcsVBoXCg4X7kLVwciQps7iURg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

Hi Mel,

After apply your patch, It got the below message.
Please note that it's not the latest kernel. it's kernel v3.0.31 + CMA
+ your patch.
It seems it should not be active but it contains active field.

Thank you,
Kyungmin Park

[   79.160394] c1 BUG: Bad page state in process mediaserver  pfn:72b18
[   79.160424] c1 page:c1579300 count:0 mapcount:0 mapping:  (null) index:0x2
[   79.160454] c1 page flags: 0x20248(uptodate|active|arch_1|mappedtodisk)
[   79.160489] c1 Backtrace:
[   79.160512] c1 [<c005f1b0>] (dump_backtrace+0x0/0x114) from
[<c06516e0>] (dump_stack+0x20/0x24)
[   79.160550] c1  r7:00000000 r6:00000001 r5:c0ad75d0 r4:c1579300
[   79.160585] c1 [<c06516c0>] (dump_stack+0x0/0x24) from [<c014dd88>]
(bad_page+0xb4/0x114)
[   79.160625] c1 [<c014dcd4>] (bad_page+0x0/0x114) from [<c014f654>]
(free_pages_prepare+0x118/0x18c)
[   79.160664] c1  r7:00000000 r6:00000001 r5:c1579300 r4:c1579300
[   79.160700] c1 [<c014f53c>] (free_pages_prepare+0x0/0x18c) from [<c014f81c>]
(free_hot_cold_page+0x30/0x19c)
[   79.160742] c1  r9:ebf51be0 r8:00000001 r7:00000001 r6:c1579300 r5:c1579300
[   79.160777] c1 r4:ebf51c8c
[   79.160796] c1 [<c014f7ec>] (free_hot_cold_page+0x0/0x19c) from [<c014fbd4>]
(__pagevec_free+0x68/0xf4)
[   79.160842] c1 [<c014fb6c>] (__pagevec_free+0x0/0xf4) from [<c012e7a8>] (free
_page_list+0xc4/0xc8)
[   79.160885] c1 [<c012e6e4>] (free_page_list+0x0/0xc8) from [<c012ecb0>] (shri
nk_page_list+0x158/0x834)
[   79.160925] c1  r8:ebf51cac r7:ebf51d20 r6:c1579080 r5:ebf51cec r4:c1579098
[   79.160966] c1 [<c012eb58>] (shrink_page_list+0x0/0x834) from [<c012f488>] (r
eclaim_clean_pages_from_list+0xfc/0x128)
[   79.161016] c1 [<c012f38c>] (reclaim_clean_pages_from_list+0x0/0x128) from [<
c0150a0c>] (alloc_contig_range+0x20c/0x458)
[   79.161062] c1  r8:00072b00 r7:00072b20 r6:00072b24 r5:ebf51d78 r4:00000000
[   79.161103] c1 [<c0150800>] (alloc_contig_range+0x0/0x458) from [<c02e2e64>]
(__dma_alloc_from_contiguous+0xdc/0x170)
[   79.161153] c1 [<c02e2d88>] (__dma_alloc_from_contiguous+0x0/0x170)
from [<c02e2fd8>] (dma_alloc_from_contiguous+0xe0/0xf0)
[   79.161205] c1 [<c02e2ef8>] (dma_alloc_from_contiguous+0x0/0xf0) from [<c0064
ebc>] (__alloc_from_contiguous+0x40/0xc0)
[   79.161254] c1 [<c0064e7c>] (__alloc_from_contiguous+0x0/0xc0) from
[<c0065914>] (__dma_alloc+0x144/0x1a0)
[   79.161295] c1  r9:ebf50000 r8:c005b284 r7:000000d0 r6:00000000 r5:ebf51ed4
[   79.161331] c1 r4:ebf51ed4
[   79.161349] c1 [<c00657d0>] (__dma_alloc+0x0/0x1a0) from
[<c0065a10>] (dma_alloc_coherent+0x64/0x70)
[   79.161388] c1  r5:00024000 r4:ebf51ed4
[   79.161413] c1 [<c00659ac>] (dma_alloc_coherent+0x0/0x70) from
[<c007be48>] (secmem_ioctl+0x448/0x5dc)
[   79.161453] c1  r7:00000000 r6:ebf51ed0 r5:ebf50000 r4:417467f0
[   79.161488] c1 [<c007ba00>] (secmem_ioctl+0x0/0x5dc) from
[<c0171ab0>] (do_vfs_ioctl+0x90/0x5a8)
[   79.161526] c1  r7:00000018 r6:c0045306 r5:d1d63d80 r4:417467f0
[   79.161562] c1 [<c0171a20>] (do_vfs_ioctl+0x0/0x5a8) from [<c0172010>] (sys_i
octl+0x48/0x70)
[   79.161603] c1 [<c0171fc8>] (sys_ioctl+0x0/0x70) from [<c005b040>] (ret_fast_
syscall+0x0/0x30)
[   79.161640] c1  r7:00000036 r6:00000028 r5:00024000 r4:40e18750


On 9/6/12, Mel Gorman <mgorman@suse.de> wrote:
> On Thu, Sep 06, 2012 at 09:29:35AM +0100, Mel Gorman wrote:
>> On Thu, Sep 06, 2012 at 02:31:12PM +0900, Minchan Kim wrote:
>> > Hi Mel,
>> >
>> > On Wed, Sep 05, 2012 at 11:56:11AM +0100, Mel Gorman wrote:
>> > > On Wed, Sep 05, 2012 at 05:11:13PM +0900, Minchan Kim wrote:
>> > > > This patch introudes MIGRATE_DISCARD mode in migration.
>> > > > It drops *clean cache pages* instead of migration so that
>> > > > migration latency could be reduced by avoiding (memcpy + page
>> > > > remapping).
>> > > > It's useful for CMA because latency of migration is very important
>> > > > rather
>> > > > than eviction of background processes's workingset. In addition, it
>> > > > needs
>> > > > less free pages for migration targets so it could avoid memory
>> > > > reclaiming
>> > > > to get free pages, which is another factor increase latency.
>> > > >
>> > >
>> > > Bah, this was released while I was reviewing the older version. I did
>> > > not read this one as closely but I see the enum problems have gone
>> > > away
>> > > at least. I'd still prefer if CMA had an additional helper to discard
>> > > some pages with shrink_page_list() and migrate the remaining pages
>> > > with
>> > > migrate_pages(). That would remove the need to add a MIGRATE_DISCARD
>> > > migrate mode at all.
>> >
>> > I am not convinced with your point. What's the benefit on separating
>> > reclaim and migration? For just removing MIGRATE_DISCARD mode?
>>
>> Maintainability. There are reclaim functions and there are migration
>> functions. Your patch takes migrate_pages() and makes it partially a
>> reclaim function mixing up the responsibilities of migrate.c and
>> vmscan.c.
>>
>> > I don't think it's not bad because my implementation is very
>> > simple(maybe
>> > it's much simpler than separating reclaim and migration) and
>> > could be used by others like memory-hotplug in future.
>>
>> They could also have used the helper function from CMA that takes a list
>> of pages, reclaims some and migrates other.
>>
>
> I also do not accept that your approach is inherently simpler than what I
> proposed to you. This is not tested at all but it should be functionally
> similar to both your patches except that it keeps the responsibility for
> reclaim in vmscan.c
>
> Your diffstats are
>
> 8 files changed, 39 insertions(+), 36 deletions(-)
> 3 files changed, 46 insertions(+), 4 deletions(-)
>
> Mine is
>
>  3 files changed, 32 insertions(+), 5 deletions(-)
>
> Fewer files changed and fewer lines inserted.
>
> ---8<---
> mm: cma: Discard clean pages during contiguous allocation instead of
> migration
>
> This patch drops clean cache pages instead of migration during
> alloc_contig_range() to minimise allocation latency by reducing the amount
> of migration is necessary. It's useful for CMA because latency of migration
> is more important than evicting the background processes working set.
>
> Prototype-not-signed-off-but-feel-free-to-pick-up-and-test
> ---
>  mm/internal.h   |    1 +
>  mm/page_alloc.c |    2 ++
>  mm/vmscan.c     |   34 +++++++++++++++++++++++++++++-----
>  3 files changed, 32 insertions(+), 5 deletions(-)
>
> diff --git a/mm/internal.h b/mm/internal.h
> index b8c91b3..6d4bdf9 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -356,3 +356,4 @@ extern unsigned long vm_mmap_pgoff(struct file *,
> unsigned long,
>          unsigned long, unsigned long);
>
>  extern void set_pageblock_order(void);
> +unsigned long reclaim_clean_pages_from_list(struct list_head *page_list);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c66fb87..977bdb2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5670,6 +5670,8 @@ static int __alloc_contig_migrate_range(unsigned long
> start, unsigned long end)
>  			break;
>  		}
>
> +		reclaim_clean_pages_from_list(&cc.migratepages);
> +
>  		ret = migrate_pages(&cc.migratepages,
>  				    __alloc_contig_migrate_alloc,
>  				    0, false, MIGRATE_SYNC);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8d01243..ccf7bc2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -703,7 +703,7 @@ static unsigned long shrink_page_list(struct list_head
> *page_list,
>  			goto keep;
>
>  		VM_BUG_ON(PageActive(page));
> -		VM_BUG_ON(page_zone(page) != zone);
> +		VM_BUG_ON(zone && page_zone(page) != zone);
>
>  		sc->nr_scanned++;
>
> @@ -817,7 +817,9 @@ static unsigned long shrink_page_list(struct list_head
> *page_list,
>  				 * except we already have the page isolated
>  				 * and know it's dirty
>  				 */
> -				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
> +				if (zone)
> +					inc_zone_page_state(page,
> +							NR_VMSCAN_IMMEDIATE);
>  				SetPageReclaim(page);
>
>  				goto keep_locked;
> @@ -947,7 +949,7 @@ keep:
>  	 * back off and wait for congestion to clear because further reclaim
>  	 * will encounter the same problem
>  	 */
> -	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
> +	if (zone && nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
>  		zone_set_flag(zone, ZONE_CONGESTED);
>
>  	free_hot_cold_page_list(&free_pages, 1);
> @@ -955,11 +957,33 @@ keep:
>  	list_splice(&ret_pages, page_list);
>  	count_vm_events(PGACTIVATE, pgactivate);
>  	mem_cgroup_uncharge_end();
> -	*ret_nr_dirty += nr_dirty;
> -	*ret_nr_writeback += nr_writeback;
> +	if (ret_nr_dirty)
> +		*ret_nr_dirty += nr_dirty;
> +	if (ret_nr_writeback)
> +		*ret_nr_writeback += nr_writeback;
>  	return nr_reclaimed;
>  }
>
> +unsigned long reclaim_clean_pages_from_list(struct list_head *page_list)
> +{
> +	struct scan_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +		.priority = DEF_PRIORITY,
> +	};
> +	unsigned long ret;
> +	struct page *page, *next;
> +	LIST_HEAD(clean_pages);
> +
> +	list_for_each_entry_safe(page, next, page_list, lru) {
> +		if (page_is_file_cache(page) && !PageDirty(page))
> +			list_move(&page->lru, &clean_pages);
> +	}
> +
> +	ret = shrink_page_list(&clean_pages, NULL, &sc, NULL, NULL);
> +	list_splice(&clean_pages, page_list);
> +	return ret;
> +}
> +
>  /*
>   * Attempt to remove the specified page from its LRU.  Only take this page
>   * if it is of the appropriate PageActive status.  Pages which are being
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
