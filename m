Date: Fri, 31 Aug 2007 22:00:57 +0100
Subject: Re: [Patch](memory hotplug) Tiny update for hot-add with sparsemem-vmemmap
Message-ID: <20070831210056.GA22879@skynet.ie>
References: <20070821125922.GG11329@skynet.ie> <20070822095447.05E5.Y-GOTO@jp.fujitsu.com> <20070830195531.8D7A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070830195531.8D7A.Y-GOTO@jp.fujitsu.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (30/08/07 20:04), Yasunori Goto didst pronounce:
> This is tiny update for Mel-san's comment about 
> memory hotplug with sparse-vmemmap.
> 
>   - Add __meminit to sparse_mem_map_populate()
>   - Add a comment.
> 
> This is for 2.6.23-rc3-mm1.
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> ---
>  mm/sparse-vmemmap.c |    2 +-
>  mm/sparse.c         |    1 +
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> Index: current/mm/sparse-vmemmap.c
> ===================================================================
> --- current.orig/mm/sparse-vmemmap.c	2007-08-23 16:19:10.000000000 +0900
> +++ current/mm/sparse-vmemmap.c	2007-08-30 19:25:16.000000000 +0900
> @@ -137,7 +137,7 @@ int __meminit vmemmap_populate_basepages
>  	return 0;
>  }
>  
> -struct page *sparse_mem_map_populate(unsigned long pnum, int nid)
> +struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid)

Looks good

>  {
>  	struct page *map = pfn_to_page(pnum * PAGES_PER_SECTION);
>  	int error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
> Index: current/mm/sparse.c
> ===================================================================
> --- current.orig/mm/sparse.c	2007-08-23 16:19:10.000000000 +0900
> +++ current/mm/sparse.c	2007-08-30 19:31:50.000000000 +0900
> @@ -326,6 +326,7 @@ void __init sparse_init(void)
>  static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
>  						 unsigned long nr_pages)
>  {
> +	/* This will make the necessary allocations eventually. */
>  	return sparse_mem_map_populate(pnum, nid);

Not the greatest comment but sufficient to tell the reader that
allocations happen ultimately and that is enough to avoid confusion.

>  }
>  static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
> 
> -- 
> Yasunori Goto 
> 

Thanks a lot.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
