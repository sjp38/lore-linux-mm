Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DAA2F6B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:02:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g8so9048946wmg.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:02:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u199si3493322wmu.140.2017.03.16.01.02.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 01:02:43 -0700 (PDT)
Date: Thu, 16 Mar 2017 09:02:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 02/15] mm: page_alloc: align arguments to parenthesis
Message-ID: <20170316080240.GB30501@dhcp22.suse.cz>
References: <cover.1489628477.git.joe@perches.com>
 <317ef9c31dba4c02905ad0222761b4337f081411.1489628477.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <317ef9c31dba4c02905ad0222761b4337f081411.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 15-03-17 18:59:59, Joe Perches wrote:
> whitespace changes only - git diff -w shows no difference

what is the point of this whitespace noise? Does it help readability?
To be honest I do not think so. Such a patch would make sense only if it
was a part of a larger series where other patches would actually do
something useful.

> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  mm/page_alloc.c | 552 ++++++++++++++++++++++++++++----------------------------
>  1 file changed, 276 insertions(+), 276 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 504749032400..79fc996892c6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -204,33 +204,33 @@ static void __free_pages_ok(struct page *page, unsigned int order);
>   */
>  int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES - 1] = {
>  #ifdef CONFIG_ZONE_DMA
> -	 256,
> +	256,
>  #endif
>  #ifdef CONFIG_ZONE_DMA32
> -	 256,
> +	256,
>  #endif
>  #ifdef CONFIG_HIGHMEM
> -	 32,
> +	32,
>  #endif
> -	 32,
> +	32,
>  };
>  
>  EXPORT_SYMBOL(totalram_pages);
>  
>  static char * const zone_names[MAX_NR_ZONES] = {
>  #ifdef CONFIG_ZONE_DMA
> -	 "DMA",
> +	"DMA",
>  #endif
>  #ifdef CONFIG_ZONE_DMA32
> -	 "DMA32",
> +	"DMA32",
>  #endif
> -	 "Normal",
> +	"Normal",
>  #ifdef CONFIG_HIGHMEM
> -	 "HighMem",
> +	"HighMem",
>  #endif
> -	 "Movable",
> +	"Movable",
>  #ifdef CONFIG_ZONE_DEVICE
> -	 "Device",
> +	"Device",
>  #endif
>  };
>  
> @@ -310,8 +310,8 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
>   * later in the boot cycle when it can be parallelised.
>   */
>  static inline bool update_defer_init(pg_data_t *pgdat,
> -				unsigned long pfn, unsigned long zone_end,
> -				unsigned long *nr_initialised)
> +				     unsigned long pfn, unsigned long zone_end,
> +				     unsigned long *nr_initialised)
>  {
>  	unsigned long max_initialise;
>  
> @@ -323,7 +323,7 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>  	 * two large system hashes that can take up 1GB for 0.25TB/node.
>  	 */
>  	max_initialise = max(2UL << (30 - PAGE_SHIFT),
> -		(pgdat->node_spanned_pages >> 8));
> +			     (pgdat->node_spanned_pages >> 8));
>  
>  	(*nr_initialised)++;
>  	if ((*nr_initialised > max_initialise) &&
> @@ -345,8 +345,8 @@ static inline bool early_page_uninitialised(unsigned long pfn)
>  }
>  
>  static inline bool update_defer_init(pg_data_t *pgdat,
> -				unsigned long pfn, unsigned long zone_end,
> -				unsigned long *nr_initialised)
> +				     unsigned long pfn, unsigned long zone_end,
> +				     unsigned long *nr_initialised)
>  {
>  	return true;
>  }
> @@ -354,7 +354,7 @@ static inline bool update_defer_init(pg_data_t *pgdat,
>  
>  /* Return a pointer to the bitmap storing bits affecting a block of pages */
>  static inline unsigned long *get_pageblock_bitmap(struct page *page,
> -							unsigned long pfn)
> +						  unsigned long pfn)
>  {
>  #ifdef CONFIG_SPARSEMEM
>  	return __pfn_to_section(pfn)->pageblock_flags;
> @@ -384,9 +384,9 @@ static inline int pfn_to_bitidx(struct page *page, unsigned long pfn)
>   * Return: pageblock_bits flags
>   */
>  static __always_inline unsigned long __get_pfnblock_flags_mask(struct page *page,
> -					unsigned long pfn,
> -					unsigned long end_bitidx,
> -					unsigned long mask)
> +							       unsigned long pfn,
> +							       unsigned long end_bitidx,
> +							       unsigned long mask)
>  {
>  	unsigned long *bitmap;
>  	unsigned long bitidx, word_bitidx;
> @@ -403,8 +403,8 @@ static __always_inline unsigned long __get_pfnblock_flags_mask(struct page *page
>  }
>  
>  unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
> -					unsigned long end_bitidx,
> -					unsigned long mask)
> +				      unsigned long end_bitidx,
> +				      unsigned long mask)
>  {
>  	return __get_pfnblock_flags_mask(page, pfn, end_bitidx, mask);
>  }
> @@ -423,9 +423,9 @@ static __always_inline int get_pfnblock_migratetype(struct page *page, unsigned
>   * @mask: mask of bits that the caller is interested in
>   */
>  void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
> -					unsigned long pfn,
> -					unsigned long end_bitidx,
> -					unsigned long mask)
> +			     unsigned long pfn,
> +			     unsigned long end_bitidx,
> +			     unsigned long mask)
>  {
>  	unsigned long *bitmap;
>  	unsigned long bitidx, word_bitidx;
> @@ -460,7 +460,7 @@ void set_pageblock_migratetype(struct page *page, int migratetype)
>  		migratetype = MIGRATE_UNMOVABLE;
>  
>  	set_pageblock_flags_group(page, (unsigned long)migratetype,
> -					PB_migrate, PB_migrate_end);
> +				  PB_migrate, PB_migrate_end);
>  }
>  
>  #ifdef CONFIG_DEBUG_VM
> @@ -481,8 +481,8 @@ static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
>  
>  	if (ret)
>  		pr_err("page 0x%lx outside node %d zone %s [ 0x%lx - 0x%lx ]\n",
> -			pfn, zone_to_nid(zone), zone->name,
> -			start_pfn, start_pfn + sp);
> +		       pfn, zone_to_nid(zone), zone->name,
> +		       start_pfn, start_pfn + sp);
>  
>  	return ret;
>  }
> @@ -516,7 +516,7 @@ static inline int bad_range(struct zone *zone, struct page *page)
>  #endif
>  
>  static void bad_page(struct page *page, const char *reason,
> -		unsigned long bad_flags)
> +		     unsigned long bad_flags)
>  {
>  	static unsigned long resume;
>  	static unsigned long nr_shown;
> @@ -533,7 +533,7 @@ static void bad_page(struct page *page, const char *reason,
>  		}
>  		if (nr_unshown) {
>  			pr_alert(
> -			      "BUG: Bad page state: %lu messages suppressed\n",
> +				"BUG: Bad page state: %lu messages suppressed\n",
>  				nr_unshown);
>  			nr_unshown = 0;
>  		}
> @@ -543,12 +543,12 @@ static void bad_page(struct page *page, const char *reason,
>  		resume = jiffies + 60 * HZ;
>  
>  	pr_alert("BUG: Bad page state in process %s  pfn:%05lx\n",
> -		current->comm, page_to_pfn(page));
> +		 current->comm, page_to_pfn(page));
>  	__dump_page(page, reason);
>  	bad_flags &= page->flags;
>  	if (bad_flags)
>  		pr_alert("bad because of flags: %#lx(%pGp)\n",
> -						bad_flags, &bad_flags);
> +			 bad_flags, &bad_flags);
>  	dump_page_owner(page);
>  
>  	print_modules();
> @@ -599,7 +599,7 @@ void prep_compound_page(struct page *page, unsigned int order)
>  #ifdef CONFIG_DEBUG_PAGEALLOC
>  unsigned int _debug_guardpage_minorder;
>  bool _debug_pagealloc_enabled __read_mostly
> -			= IS_ENABLED(CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT);
> += IS_ENABLED(CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT);
>  EXPORT_SYMBOL(_debug_pagealloc_enabled);
>  bool _debug_guardpage_enabled __read_mostly;
>  
> @@ -654,7 +654,7 @@ static int __init debug_guardpage_minorder_setup(char *buf)
>  early_param("debug_guardpage_minorder", debug_guardpage_minorder_setup);
>  
>  static inline bool set_page_guard(struct zone *zone, struct page *page,
> -				unsigned int order, int migratetype)
> +				  unsigned int order, int migratetype)
>  {
>  	struct page_ext *page_ext;
>  
> @@ -679,7 +679,7 @@ static inline bool set_page_guard(struct zone *zone, struct page *page,
>  }
>  
>  static inline void clear_page_guard(struct zone *zone, struct page *page,
> -				unsigned int order, int migratetype)
> +				    unsigned int order, int migratetype)
>  {
>  	struct page_ext *page_ext;
>  
> @@ -699,9 +699,9 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
>  #else
>  struct page_ext_operations debug_guardpage_ops;
>  static inline bool set_page_guard(struct zone *zone, struct page *page,
> -			unsigned int order, int migratetype) { return false; }
> +				  unsigned int order, int migratetype) { return false; }
>  static inline void clear_page_guard(struct zone *zone, struct page *page,
> -				unsigned int order, int migratetype) {}
> +				    unsigned int order, int migratetype) {}
>  #endif
>  
>  static inline void set_page_order(struct page *page, unsigned int order)
> @@ -732,7 +732,7 @@ static inline void rmv_page_order(struct page *page)
>   * For recording page's order, we use page_private(page).
>   */
>  static inline int page_is_buddy(struct page *page, struct page *buddy,
> -							unsigned int order)
> +				unsigned int order)
>  {
>  	if (page_is_guard(buddy) && page_order(buddy) == order) {
>  		if (page_zone_id(page) != page_zone_id(buddy))
> @@ -785,9 +785,9 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>   */
>  
>  static inline void __free_one_page(struct page *page,
> -		unsigned long pfn,
> -		struct zone *zone, unsigned int order,
> -		int migratetype)
> +				   unsigned long pfn,
> +				   struct zone *zone, unsigned int order,
> +				   int migratetype)
>  {
>  	unsigned long combined_pfn;
>  	unsigned long uninitialized_var(buddy_pfn);
> @@ -848,8 +848,8 @@ static inline void __free_one_page(struct page *page,
>  			buddy_mt = get_pageblock_migratetype(buddy);
>  
>  			if (migratetype != buddy_mt
> -					&& (is_migrate_isolate(migratetype) ||
> -						is_migrate_isolate(buddy_mt)))
> +			    && (is_migrate_isolate(migratetype) ||
> +				is_migrate_isolate(buddy_mt)))
>  				goto done_merging;
>  		}
>  		max_order++;
> @@ -876,7 +876,7 @@ static inline void __free_one_page(struct page *page,
>  		if (pfn_valid_within(buddy_pfn) &&
>  		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
>  			list_add_tail(&page->lru,
> -				&zone->free_area[order].free_list[migratetype]);
> +				      &zone->free_area[order].free_list[migratetype]);
>  			goto out;
>  		}
>  	}
> @@ -892,17 +892,17 @@ static inline void __free_one_page(struct page *page,
>   * check if necessary.
>   */
>  static inline bool page_expected_state(struct page *page,
> -					unsigned long check_flags)
> +				       unsigned long check_flags)
>  {
>  	if (unlikely(atomic_read(&page->_mapcount) != -1))
>  		return false;
>  
>  	if (unlikely((unsigned long)page->mapping |
> -			page_ref_count(page) |
> +		     page_ref_count(page) |
>  #ifdef CONFIG_MEMCG
> -			(unsigned long)page->mem_cgroup |
> +		     (unsigned long)page->mem_cgroup |
>  #endif
> -			(page->flags & check_flags)))
> +		     (page->flags & check_flags)))
>  		return false;
>  
>  	return true;
> @@ -994,7 +994,7 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
>  }
>  
>  static __always_inline bool free_pages_prepare(struct page *page,
> -					unsigned int order, bool check_free)
> +					       unsigned int order, bool check_free)
>  {
>  	int bad = 0;
>  
> @@ -1042,7 +1042,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
>  		debug_check_no_locks_freed(page_address(page),
>  					   PAGE_SIZE << order);
>  		debug_check_no_obj_freed(page_address(page),
> -					   PAGE_SIZE << order);
> +					 PAGE_SIZE << order);
>  	}
>  	arch_free_page(page, order);
>  	kernel_poison_pages(page, 1 << order, 0);
> @@ -1086,7 +1086,7 @@ static bool bulkfree_pcp_prepare(struct page *page)
>   * pinned" detection logic.
>   */
>  static void free_pcppages_bulk(struct zone *zone, int count,
> -					struct per_cpu_pages *pcp)
> +			       struct per_cpu_pages *pcp)
>  {
>  	int migratetype = 0;
>  	int batch_free = 0;
> @@ -1142,16 +1142,16 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  }
>  
>  static void free_one_page(struct zone *zone,
> -				struct page *page, unsigned long pfn,
> -				unsigned int order,
> -				int migratetype)
> +			  struct page *page, unsigned long pfn,
> +			  unsigned int order,
> +			  int migratetype)
>  {
>  	unsigned long flags;
>  
>  	spin_lock_irqsave(&zone->lock, flags);
>  	__count_vm_events(PGFREE, 1 << order);
>  	if (unlikely(has_isolate_pageblock(zone) ||
> -		is_migrate_isolate(migratetype))) {
> +		     is_migrate_isolate(migratetype))) {
>  		migratetype = get_pfnblock_migratetype(page, pfn);
>  	}
>  	__free_one_page(page, pfn, zone, order, migratetype);
> @@ -1159,7 +1159,7 @@ static void free_one_page(struct zone *zone,
>  }
>  
>  static void __meminit __init_single_page(struct page *page, unsigned long pfn,
> -				unsigned long zone, int nid)
> +					 unsigned long zone, int nid)
>  {
>  	set_page_links(page, zone, nid, pfn);
>  	init_page_count(page);
> @@ -1263,7 +1263,7 @@ static void __init __free_pages_boot_core(struct page *page, unsigned int order)
>  	__free_pages(page, order);
>  }
>  
> -#if defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) || \
> +#if defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) ||	\
>  	defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
>  
>  static struct mminit_pfnnid_cache early_pfnnid_cache __meminitdata;
> @@ -1285,7 +1285,7 @@ int __meminit early_pfn_to_nid(unsigned long pfn)
>  
>  #ifdef CONFIG_NODES_SPAN_OTHER_NODES
>  static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
> -					struct mminit_pfnnid_cache *state)
> +						struct mminit_pfnnid_cache *state)
>  {
>  	int nid;
>  
> @@ -1308,7 +1308,7 @@ static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
>  	return true;
>  }
>  static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
> -					struct mminit_pfnnid_cache *state)
> +						struct mminit_pfnnid_cache *state)
>  {
>  	return true;
>  }
> @@ -1316,7 +1316,7 @@ static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
>  
>  
>  void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
> -							unsigned int order)
> +				 unsigned int order)
>  {
>  	if (early_page_uninitialised(pfn))
>  		return;
> @@ -1373,8 +1373,8 @@ void set_zone_contiguous(struct zone *zone)
>  
>  	block_end_pfn = ALIGN(block_start_pfn + 1, pageblock_nr_pages);
>  	for (; block_start_pfn < zone_end_pfn(zone);
> -			block_start_pfn = block_end_pfn,
> -			 block_end_pfn += pageblock_nr_pages) {
> +	     block_start_pfn = block_end_pfn,
> +		     block_end_pfn += pageblock_nr_pages) {
>  
>  		block_end_pfn = min(block_end_pfn, zone_end_pfn(zone));
>  
> @@ -1394,7 +1394,7 @@ void clear_zone_contiguous(struct zone *zone)
>  
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>  static void __init deferred_free_range(struct page *page,
> -					unsigned long pfn, int nr_pages)
> +				       unsigned long pfn, int nr_pages)
>  {
>  	int i;
>  
> @@ -1501,7 +1501,7 @@ static int __init deferred_init_memmap(void *data)
>  			} else {
>  				nr_pages += nr_to_free;
>  				deferred_free_range(free_base_page,
> -						free_base_pfn, nr_to_free);
> +						    free_base_pfn, nr_to_free);
>  				free_base_page = NULL;
>  				free_base_pfn = nr_to_free = 0;
>  
> @@ -1524,11 +1524,11 @@ static int __init deferred_init_memmap(void *data)
>  
>  			/* Where possible, batch up pages for a single free */
>  			continue;
> -free_range:
> +		free_range:
>  			/* Free the current block of pages to allocator */
>  			nr_pages += nr_to_free;
>  			deferred_free_range(free_base_page, free_base_pfn,
> -								nr_to_free);
> +					    nr_to_free);
>  			free_base_page = NULL;
>  			free_base_pfn = nr_to_free = 0;
>  		}
> @@ -1543,7 +1543,7 @@ static int __init deferred_init_memmap(void *data)
>  	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
>  
>  	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
> -					jiffies_to_msecs(jiffies - start));
> +		jiffies_to_msecs(jiffies - start));
>  
>  	pgdat_init_report_one_done();
>  	return 0;
> @@ -1620,8 +1620,8 @@ void __init init_cma_reserved_pageblock(struct page *page)
>   * -- nyc
>   */
>  static inline void expand(struct zone *zone, struct page *page,
> -	int low, int high, struct free_area *area,
> -	int migratetype)
> +			  int low, int high, struct free_area *area,
> +			  int migratetype)
>  {
>  	unsigned long size = 1 << high;
>  
> @@ -1681,7 +1681,7 @@ static void check_new_page_bad(struct page *page)
>  static inline int check_new_page(struct page *page)
>  {
>  	if (likely(page_expected_state(page,
> -				PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON)))
> +				       PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON)))
>  		return 0;
>  
>  	check_new_page_bad(page);
> @@ -1729,7 +1729,7 @@ static bool check_new_pages(struct page *page, unsigned int order)
>  }
>  
>  inline void post_alloc_hook(struct page *page, unsigned int order,
> -				gfp_t gfp_flags)
> +			    gfp_t gfp_flags)
>  {
>  	set_page_private(page, 0);
>  	set_page_refcounted(page);
> @@ -1742,7 +1742,7 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
>  }
>  
>  static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
> -							unsigned int alloc_flags)
> +			  unsigned int alloc_flags)
>  {
>  	int i;
>  	bool poisoned = true;
> @@ -1780,7 +1780,7 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
>   */
>  static inline
>  struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
> -						int migratetype)
> +				int migratetype)
>  {
>  	unsigned int current_order;
>  	struct free_area *area;
> @@ -1790,7 +1790,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
>  	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
>  		area = &(zone->free_area[current_order]);
>  		page = list_first_entry_or_null(&area->free_list[migratetype],
> -							struct page, lru);
> +						struct page, lru);
>  		if (!page)
>  			continue;
>  		list_del(&page->lru);
> @@ -1823,13 +1823,13 @@ static int fallbacks[MIGRATE_TYPES][4] = {
>  
>  #ifdef CONFIG_CMA
>  static struct page *__rmqueue_cma_fallback(struct zone *zone,
> -					unsigned int order)
> +					   unsigned int order)
>  {
>  	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
>  }
>  #else
>  static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
> -					unsigned int order) { return NULL; }
> +						  unsigned int order) { return NULL; }
>  #endif
>  
>  /*
> @@ -1875,7 +1875,7 @@ static int move_freepages(struct zone *zone,
>  			 * isolating, as that would be expensive.
>  			 */
>  			if (num_movable &&
> -					(PageLRU(page) || __PageMovable(page)))
> +			    (PageLRU(page) || __PageMovable(page)))
>  				(*num_movable)++;
>  
>  			page++;
> @@ -1893,7 +1893,7 @@ static int move_freepages(struct zone *zone,
>  }
>  
>  int move_freepages_block(struct zone *zone, struct page *page,
> -				int migratetype, int *num_movable)
> +			 int migratetype, int *num_movable)
>  {
>  	unsigned long start_pfn, end_pfn;
>  	struct page *start_page, *end_page;
> @@ -1911,11 +1911,11 @@ int move_freepages_block(struct zone *zone, struct page *page,
>  		return 0;
>  
>  	return move_freepages(zone, start_page, end_page, migratetype,
> -								num_movable);
> +			      num_movable);
>  }
>  
>  static void change_pageblock_range(struct page *pageblock_page,
> -					int start_order, int migratetype)
> +				   int start_order, int migratetype)
>  {
>  	int nr_pageblocks = 1 << (start_order - pageblock_order);
>  
> @@ -1950,9 +1950,9 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
>  		return true;
>  
>  	if (order >= pageblock_order / 2 ||
> -		start_mt == MIGRATE_RECLAIMABLE ||
> -		start_mt == MIGRATE_UNMOVABLE ||
> -		page_group_by_mobility_disabled)
> +	    start_mt == MIGRATE_RECLAIMABLE ||
> +	    start_mt == MIGRATE_UNMOVABLE ||
> +	    page_group_by_mobility_disabled)
>  		return true;
>  
>  	return false;
> @@ -1967,7 +1967,7 @@ static bool can_steal_fallback(unsigned int order, int start_mt)
>   * itself, so pages freed in the future will be put on the correct free list.
>   */
>  static void steal_suitable_fallback(struct zone *zone, struct page *page,
> -					int start_type, bool whole_block)
> +				    int start_type, bool whole_block)
>  {
>  	unsigned int current_order = page_order(page);
>  	struct free_area *area;
> @@ -1994,7 +1994,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  		goto single_page;
>  
>  	free_pages = move_freepages_block(zone, page, start_type,
> -						&movable_pages);
> +					  &movable_pages);
>  	/*
>  	 * Determine how many pages are compatible with our allocation.
>  	 * For movable allocation, it's the number of movable pages which
> @@ -2012,7 +2012,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  		 */
>  		if (old_block_type == MIGRATE_MOVABLE)
>  			alike_pages = pageblock_nr_pages
> -						- (free_pages + movable_pages);
> +				- (free_pages + movable_pages);
>  		else
>  			alike_pages = 0;
>  	}
> @@ -2022,7 +2022,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>  	 * comparable migratability as our allocation, claim the whole block.
>  	 */
>  	if (free_pages + alike_pages >= (1 << (pageblock_order - 1)) ||
> -			page_group_by_mobility_disabled)
> +	    page_group_by_mobility_disabled)
>  		set_pageblock_migratetype(page, start_type);
>  
>  	return;
> @@ -2039,7 +2039,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>   * fragmentation due to mixed migratetype pages in one pageblock.
>   */
>  int find_suitable_fallback(struct free_area *area, unsigned int order,
> -			int migratetype, bool only_stealable, bool *can_steal)
> +			   int migratetype, bool only_stealable, bool *can_steal)
>  {
>  	int i;
>  	int fallback_mt;
> @@ -2074,7 +2074,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
>   * there are no empty page blocks that contain a page with a suitable order
>   */
>  static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
> -				unsigned int alloc_order)
> +					 unsigned int alloc_order)
>  {
>  	int mt;
>  	unsigned long max_managed, flags;
> @@ -2116,7 +2116,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
>   * pageblock is exhausted.
>   */
>  static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
> -						bool force)
> +					   bool force)
>  {
>  	struct zonelist *zonelist = ac->zonelist;
>  	unsigned long flags;
> @@ -2127,13 +2127,13 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
>  	bool ret;
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
> -								ac->nodemask) {
> +					ac->nodemask) {
>  		/*
>  		 * Preserve at least one pageblock unless memory pressure
>  		 * is really high.
>  		 */
>  		if (!force && zone->nr_reserved_highatomic <=
> -					pageblock_nr_pages)
> +		    pageblock_nr_pages)
>  			continue;
>  
>  		spin_lock_irqsave(&zone->lock, flags);
> @@ -2141,8 +2141,8 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
>  			struct free_area *area = &(zone->free_area[order]);
>  
>  			page = list_first_entry_or_null(
> -					&area->free_list[MIGRATE_HIGHATOMIC],
> -					struct page, lru);
> +				&area->free_list[MIGRATE_HIGHATOMIC],
> +				struct page, lru);
>  			if (!page)
>  				continue;
>  
> @@ -2162,8 +2162,8 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
>  				 * underflows.
>  				 */
>  				zone->nr_reserved_highatomic -= min(
> -						pageblock_nr_pages,
> -						zone->nr_reserved_highatomic);
> +					pageblock_nr_pages,
> +					zone->nr_reserved_highatomic);
>  			}
>  
>  			/*
> @@ -2177,7 +2177,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
>  			 */
>  			set_pageblock_migratetype(page, ac->migratetype);
>  			ret = move_freepages_block(zone, page, ac->migratetype,
> -									NULL);
> +						   NULL);
>  			if (ret) {
>  				spin_unlock_irqrestore(&zone->lock, flags);
>  				return ret;
> @@ -2206,22 +2206,22 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>  
>  	/* Find the largest possible block of pages in the other list */
>  	for (current_order = MAX_ORDER - 1;
> -				current_order >= order && current_order <= MAX_ORDER - 1;
> -				--current_order) {
> +	     current_order >= order && current_order <= MAX_ORDER - 1;
> +	     --current_order) {
>  		area = &(zone->free_area[current_order]);
>  		fallback_mt = find_suitable_fallback(area, current_order,
> -				start_migratetype, false, &can_steal);
> +						     start_migratetype, false, &can_steal);
>  		if (fallback_mt == -1)
>  			continue;
>  
>  		page = list_first_entry(&area->free_list[fallback_mt],
> -						struct page, lru);
> +					struct page, lru);
>  
>  		steal_suitable_fallback(zone, page, start_migratetype,
> -								can_steal);
> +					can_steal);
>  
>  		trace_mm_page_alloc_extfrag(page, order, current_order,
> -			start_migratetype, fallback_mt);
> +					    start_migratetype, fallback_mt);
>  
>  		return true;
>  	}
> @@ -2234,7 +2234,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
>   * Call me with the zone->lock already held.
>   */
>  static struct page *__rmqueue(struct zone *zone, unsigned int order,
> -				int migratetype)
> +			      int migratetype)
>  {
>  	struct page *page;
>  
> @@ -2508,7 +2508,7 @@ void mark_free_pages(struct zone *zone)
>  
>  	for_each_migratetype_order(order, t) {
>  		list_for_each_entry(page,
> -				&zone->free_area[order].free_list[t], lru) {
> +				    &zone->free_area[order].free_list[t], lru) {
>  			unsigned long i;
>  
>  			pfn = page_to_pfn(page);
> @@ -2692,8 +2692,8 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
>  
>  /* Remove page from the per-cpu list, caller must protect the list */
>  static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
> -			bool cold, struct per_cpu_pages *pcp,
> -			struct list_head *list)
> +				      bool cold, struct per_cpu_pages *pcp,
> +				      struct list_head *list)
>  {
>  	struct page *page;
>  
> @@ -2702,8 +2702,8 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
>  	do {
>  		if (list_empty(list)) {
>  			pcp->count += rmqueue_bulk(zone, 0,
> -					pcp->batch, list,
> -					migratetype, cold);
> +						   pcp->batch, list,
> +						   migratetype, cold);
>  			if (unlikely(list_empty(list)))
>  				return NULL;
>  		}
> @@ -2722,8 +2722,8 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
>  
>  /* Lock and remove page from the per-cpu list */
>  static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> -			struct zone *zone, unsigned int order,
> -			gfp_t gfp_flags, int migratetype)
> +				    struct zone *zone, unsigned int order,
> +				    gfp_t gfp_flags, int migratetype)
>  {
>  	struct per_cpu_pages *pcp;
>  	struct list_head *list;
> @@ -2747,16 +2747,16 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>   */
>  static inline
>  struct page *rmqueue(struct zone *preferred_zone,
> -			struct zone *zone, unsigned int order,
> -			gfp_t gfp_flags, unsigned int alloc_flags,
> -			int migratetype)
> +		     struct zone *zone, unsigned int order,
> +		     gfp_t gfp_flags, unsigned int alloc_flags,
> +		     int migratetype)
>  {
>  	unsigned long flags;
>  	struct page *page;
>  
>  	if (likely(order == 0) && !in_interrupt()) {
>  		page = rmqueue_pcplist(preferred_zone, zone, order,
> -				gfp_flags, migratetype);
> +				       gfp_flags, migratetype);
>  		goto out;
>  	}
>  
> @@ -2826,7 +2826,7 @@ static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>  	if (fail_page_alloc.ignore_gfp_highmem && (gfp_mask & __GFP_HIGHMEM))
>  		return false;
>  	if (fail_page_alloc.ignore_gfp_reclaim &&
> -			(gfp_mask & __GFP_DIRECT_RECLAIM))
> +	    (gfp_mask & __GFP_DIRECT_RECLAIM))
>  		return false;
>  
>  	return should_fail(&fail_page_alloc.attr, 1 << order);
> @@ -2845,10 +2845,10 @@ static int __init fail_page_alloc_debugfs(void)
>  		return PTR_ERR(dir);
>  
>  	if (!debugfs_create_bool("ignore-gfp-wait", mode, dir,
> -				&fail_page_alloc.ignore_gfp_reclaim))
> +				 &fail_page_alloc.ignore_gfp_reclaim))
>  		goto fail;
>  	if (!debugfs_create_bool("ignore-gfp-highmem", mode, dir,
> -				&fail_page_alloc.ignore_gfp_highmem))
> +				 &fail_page_alloc.ignore_gfp_highmem))
>  		goto fail;
>  	if (!debugfs_create_u32("min-order", mode, dir,
>  				&fail_page_alloc.min_order))
> @@ -2949,14 +2949,14 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
>  }
>  
>  bool zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
> -		      int classzone_idx, unsigned int alloc_flags)
> +		       int classzone_idx, unsigned int alloc_flags)
>  {
>  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> -					zone_page_state(z, NR_FREE_PAGES));
> +				   zone_page_state(z, NR_FREE_PAGES));
>  }
>  
>  static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
> -		unsigned long mark, int classzone_idx, unsigned int alloc_flags)
> +				       unsigned long mark, int classzone_idx, unsigned int alloc_flags)
>  {
>  	long free_pages = zone_page_state(z, NR_FREE_PAGES);
>  	long cma_pages = 0;
> @@ -2978,11 +2978,11 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
>  		return true;
>  
>  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> -					free_pages);
> +				   free_pages);
>  }
>  
>  bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
> -			unsigned long mark, int classzone_idx)
> +			    unsigned long mark, int classzone_idx)
>  {
>  	long free_pages = zone_page_state(z, NR_FREE_PAGES);
>  
> @@ -2990,14 +2990,14 @@ bool zone_watermark_ok_safe(struct zone *z, unsigned int order,
>  		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
>  
>  	return __zone_watermark_ok(z, order, mark, classzone_idx, 0,
> -								free_pages);
> +				   free_pages);
>  }
>  
>  #ifdef CONFIG_NUMA
>  static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>  {
>  	return node_distance(zone_to_nid(local_zone), zone_to_nid(zone)) <=
> -				RECLAIM_DISTANCE;
> +		RECLAIM_DISTANCE;
>  }
>  #else	/* CONFIG_NUMA */
>  static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
> @@ -3012,7 +3012,7 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>   */
>  static struct page *
>  get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> -						const struct alloc_context *ac)
> +		       const struct alloc_context *ac)
>  {
>  	struct zoneref *z = ac->preferred_zoneref;
>  	struct zone *zone;
> @@ -3023,14 +3023,14 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
>  	 */
>  	for_next_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
> -								ac->nodemask) {
> +					ac->nodemask) {
>  		struct page *page;
>  		unsigned long mark;
>  
>  		if (cpusets_enabled() &&
> -			(alloc_flags & ALLOC_CPUSET) &&
> -			!__cpuset_zone_allowed(zone, gfp_mask))
> -				continue;
> +		    (alloc_flags & ALLOC_CPUSET) &&
> +		    !__cpuset_zone_allowed(zone, gfp_mask))
> +			continue;
>  		/*
>  		 * When allocating a page cache page for writing, we
>  		 * want to get it from a node that is within its dirty
> @@ -3062,7 +3062,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  
>  		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
>  		if (!zone_watermark_fast(zone, order, mark,
> -				       ac_classzone_idx(ac), alloc_flags)) {
> +					 ac_classzone_idx(ac), alloc_flags)) {
>  			int ret;
>  
>  			/* Checked here to keep the fast path fast */
> @@ -3085,16 +3085,16 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  			default:
>  				/* did we reclaim enough */
>  				if (zone_watermark_ok(zone, order, mark,
> -						ac_classzone_idx(ac), alloc_flags))
> +						      ac_classzone_idx(ac), alloc_flags))
>  					goto try_this_zone;
>  
>  				continue;
>  			}
>  		}
>  
> -try_this_zone:
> +	try_this_zone:
>  		page = rmqueue(ac->preferred_zoneref->zone, zone, order,
> -				gfp_mask, alloc_flags, ac->migratetype);
> +			       gfp_mask, alloc_flags, ac->migratetype);
>  		if (page) {
>  			prep_new_page(page, order, gfp_mask, alloc_flags);
>  
> @@ -3188,21 +3188,21 @@ __alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order,
>  	struct page *page;
>  
>  	page = get_page_from_freelist(gfp_mask, order,
> -			alloc_flags | ALLOC_CPUSET, ac);
> +				      alloc_flags | ALLOC_CPUSET, ac);
>  	/*
>  	 * fallback to ignore cpuset restriction if our nodes
>  	 * are depleted
>  	 */
>  	if (!page)
>  		page = get_page_from_freelist(gfp_mask, order,
> -				alloc_flags, ac);
> +					      alloc_flags, ac);
>  
>  	return page;
>  }
>  
>  static inline struct page *
>  __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> -	const struct alloc_context *ac, unsigned long *did_some_progress)
> +		      const struct alloc_context *ac, unsigned long *did_some_progress)
>  {
>  	struct oom_control oc = {
>  		.zonelist = ac->zonelist,
> @@ -3231,7 +3231,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	 * we're still under heavy pressure.
>  	 */
>  	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
> -					ALLOC_WMARK_HIGH | ALLOC_CPUSET, ac);
> +				      ALLOC_WMARK_HIGH | ALLOC_CPUSET, ac);
>  	if (page)
>  		goto out;
>  
> @@ -3270,7 +3270,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  		 */
>  		if (gfp_mask & __GFP_NOFAIL)
>  			page = __alloc_pages_cpuset_fallback(gfp_mask, order,
> -					ALLOC_NO_WATERMARKS, ac);
> +							     ALLOC_NO_WATERMARKS, ac);
>  	}
>  out:
>  	mutex_unlock(&oom_lock);
> @@ -3287,8 +3287,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  /* Try memory compaction for high-order allocations before reclaim */
>  static struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> -		unsigned int alloc_flags, const struct alloc_context *ac,
> -		enum compact_priority prio, enum compact_result *compact_result)
> +			     unsigned int alloc_flags, const struct alloc_context *ac,
> +			     enum compact_priority prio, enum compact_result *compact_result)
>  {
>  	struct page *page;
>  
> @@ -3297,7 +3297,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  
>  	current->flags |= PF_MEMALLOC;
>  	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> -									prio);
> +					       prio);
>  	current->flags &= ~PF_MEMALLOC;
>  
>  	if (*compact_result <= COMPACT_INACTIVE)
> @@ -3389,7 +3389,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  	 */
>  check_priority:
>  	min_priority = (order > PAGE_ALLOC_COSTLY_ORDER) ?
> -			MIN_COMPACT_COSTLY_PRIORITY : MIN_COMPACT_PRIORITY;
> +		MIN_COMPACT_COSTLY_PRIORITY : MIN_COMPACT_PRIORITY;
>  
>  	if (*compact_priority > min_priority) {
>  		(*compact_priority)--;
> @@ -3403,8 +3403,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  #else
>  static inline struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> -		unsigned int alloc_flags, const struct alloc_context *ac,
> -		enum compact_priority prio, enum compact_result *compact_result)
> +			     unsigned int alloc_flags, const struct alloc_context *ac,
> +			     enum compact_priority prio, enum compact_result *compact_result)
>  {
>  	*compact_result = COMPACT_SKIPPED;
>  	return NULL;
> @@ -3431,7 +3431,7 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
>  	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
>  					ac->nodemask) {
>  		if (zone_watermark_ok(zone, 0, min_wmark_pages(zone),
> -					ac_classzone_idx(ac), alloc_flags))
> +				      ac_classzone_idx(ac), alloc_flags))
>  			return true;
>  	}
>  	return false;
> @@ -3441,7 +3441,7 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
>  /* Perform direct synchronous page reclaim */
>  static int
>  __perform_reclaim(gfp_t gfp_mask, unsigned int order,
> -					const struct alloc_context *ac)
> +		  const struct alloc_context *ac)
>  {
>  	struct reclaim_state reclaim_state;
>  	int progress;
> @@ -3456,7 +3456,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
>  	current->reclaim_state = &reclaim_state;
>  
>  	progress = try_to_free_pages(ac->zonelist, order, gfp_mask,
> -								ac->nodemask);
> +				     ac->nodemask);
>  
>  	current->reclaim_state = NULL;
>  	lockdep_clear_current_reclaim_state();
> @@ -3470,8 +3470,8 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
>  /* The really slow allocator path where we enter direct reclaim */
>  static inline struct page *
>  __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> -		unsigned int alloc_flags, const struct alloc_context *ac,
> -		unsigned long *did_some_progress)
> +			     unsigned int alloc_flags, const struct alloc_context *ac,
> +			     unsigned long *did_some_progress)
>  {
>  	struct page *page = NULL;
>  	bool drained = false;
> @@ -3560,8 +3560,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
>  		return true;
>  	if (!in_interrupt() &&
> -			((current->flags & PF_MEMALLOC) ||
> -			 unlikely(test_thread_flag(TIF_MEMDIE))))
> +	    ((current->flags & PF_MEMALLOC) ||
> +	     unlikely(test_thread_flag(TIF_MEMDIE))))
>  		return true;
>  
>  	return false;
> @@ -3625,9 +3625,9 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		 * reclaimable pages?
>  		 */
>  		wmark = __zone_watermark_ok(zone, order, min_wmark,
> -				ac_classzone_idx(ac), alloc_flags, available);
> +					    ac_classzone_idx(ac), alloc_flags, available);
>  		trace_reclaim_retry_zone(z, order, reclaimable,
> -				available, min_wmark, *no_progress_loops, wmark);
> +					 available, min_wmark, *no_progress_loops, wmark);
>  		if (wmark) {
>  			/*
>  			 * If we didn't make any progress and have a lot of
> @@ -3639,7 +3639,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  				unsigned long write_pending;
>  
>  				write_pending = zone_page_state_snapshot(zone,
> -							NR_ZONE_WRITE_PENDING);
> +									 NR_ZONE_WRITE_PENDING);
>  
>  				if (2 * write_pending > reclaimable) {
>  					congestion_wait(BLK_RW_ASYNC, HZ / 10);
> @@ -3670,7 +3670,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  
>  static inline struct page *
>  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> -						struct alloc_context *ac)
> +		       struct alloc_context *ac)
>  {
>  	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
>  	const bool costly_order = order > PAGE_ALLOC_COSTLY_ORDER;
> @@ -3701,7 +3701,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * callers that are not in atomic context.
>  	 */
>  	if (WARN_ON_ONCE((gfp_mask & (__GFP_ATOMIC | __GFP_DIRECT_RECLAIM)) ==
> -				(__GFP_ATOMIC | __GFP_DIRECT_RECLAIM)))
> +			 (__GFP_ATOMIC | __GFP_DIRECT_RECLAIM)))
>  		gfp_mask &= ~__GFP_ATOMIC;
>  
>  retry_cpuset:
> @@ -3724,7 +3724,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * could end up iterating over non-eligible zones endlessly.
>  	 */
>  	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> -					ac->high_zoneidx, ac->nodemask);
> +						     ac->high_zoneidx, ac->nodemask);
>  	if (!ac->preferred_zoneref->zone)
>  		goto nopage;
>  
> @@ -3749,13 +3749,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * watermarks, as the ALLOC_NO_WATERMARKS attempt didn't yet happen.
>  	 */
>  	if (can_direct_reclaim &&
> -			(costly_order ||
> -			   (order > 0 && ac->migratetype != MIGRATE_MOVABLE))
> -			&& !gfp_pfmemalloc_allowed(gfp_mask)) {
> +	    (costly_order ||
> +	     (order > 0 && ac->migratetype != MIGRATE_MOVABLE))
> +	    && !gfp_pfmemalloc_allowed(gfp_mask)) {
>  		page = __alloc_pages_direct_compact(gfp_mask, order,
> -						alloc_flags, ac,
> -						INIT_COMPACT_PRIORITY,
> -						&compact_result);
> +						    alloc_flags, ac,
> +						    INIT_COMPACT_PRIORITY,
> +						    &compact_result);
>  		if (page)
>  			goto got_pg;
>  
> @@ -3800,7 +3800,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (!(alloc_flags & ALLOC_CPUSET) || (alloc_flags & ALLOC_NO_WATERMARKS)) {
>  		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
>  		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> -					ac->high_zoneidx, ac->nodemask);
> +							     ac->high_zoneidx, ac->nodemask);
>  	}
>  
>  	/* Attempt with potentially adjusted zonelist and alloc_flags */
> @@ -3815,8 +3815,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	/* Make sure we know about allocations which stall for too long */
>  	if (time_after(jiffies, alloc_start + stall_timeout)) {
>  		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
> -			"page allocation stalls for %ums, order:%u",
> -			jiffies_to_msecs(jiffies - alloc_start), order);
> +			   "page allocation stalls for %ums, order:%u",
> +			   jiffies_to_msecs(jiffies - alloc_start), order);
>  		stall_timeout += 10 * HZ;
>  	}
>  
> @@ -3826,13 +3826,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  
>  	/* Try direct reclaim and then allocating */
>  	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
> -							&did_some_progress);
> +					    &did_some_progress);
>  	if (page)
>  		goto got_pg;
>  
>  	/* Try direct compaction and then allocating */
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
> -					compact_priority, &compact_result);
> +					    compact_priority, &compact_result);
>  	if (page)
>  		goto got_pg;
>  
> @@ -3858,9 +3858,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * of free memory (see __compaction_suitable)
>  	 */
>  	if (did_some_progress > 0 &&
> -			should_compact_retry(ac, order, alloc_flags,
> -				compact_result, &compact_priority,
> -				&compaction_retries))
> +	    should_compact_retry(ac, order, alloc_flags,
> +				 compact_result, &compact_priority,
> +				 &compaction_retries))
>  		goto retry;
>  
>  	/*
> @@ -3938,15 +3938,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	}
>  fail:
>  	warn_alloc(gfp_mask, ac->nodemask,
> -			"page allocation failure: order:%u", order);
> +		   "page allocation failure: order:%u", order);
>  got_pg:
>  	return page;
>  }
>  
>  static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
> -		struct zonelist *zonelist, nodemask_t *nodemask,
> -		struct alloc_context *ac, gfp_t *alloc_mask,
> -		unsigned int *alloc_flags)
> +				       struct zonelist *zonelist, nodemask_t *nodemask,
> +				       struct alloc_context *ac, gfp_t *alloc_mask,
> +				       unsigned int *alloc_flags)
>  {
>  	ac->high_zoneidx = gfp_zone(gfp_mask);
>  	ac->zonelist = zonelist;
> @@ -3976,7 +3976,7 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
>  
>  /* Determine whether to spread dirty pages and what the first usable zone */
>  static inline void finalise_ac(gfp_t gfp_mask,
> -		unsigned int order, struct alloc_context *ac)
> +			       unsigned int order, struct alloc_context *ac)
>  {
>  	/* Dirty zone balancing only done in the fast path */
>  	ac->spread_dirty_pages = (gfp_mask & __GFP_WRITE);
> @@ -3987,7 +3987,7 @@ static inline void finalise_ac(gfp_t gfp_mask,
>  	 * may get reset for allocations that ignore memory policies.
>  	 */
>  	ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> -					ac->high_zoneidx, ac->nodemask);
> +						     ac->high_zoneidx, ac->nodemask);
>  }
>  
>  /*
> @@ -3995,7 +3995,7 @@ static inline void finalise_ac(gfp_t gfp_mask,
>   */
>  struct page *
>  __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> -			struct zonelist *zonelist, nodemask_t *nodemask)
> +		       struct zonelist *zonelist, nodemask_t *nodemask)
>  {
>  	struct page *page;
>  	unsigned int alloc_flags = ALLOC_WMARK_LOW;
> @@ -4114,7 +4114,7 @@ static struct page *__page_frag_cache_refill(struct page_frag_cache *nc,
>  
>  #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
>  	gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
> -		    __GFP_NOMEMALLOC;
> +		__GFP_NOMEMALLOC;
>  	page = alloc_pages_node(NUMA_NO_NODE, gfp_mask,
>  				PAGE_FRAG_CACHE_MAX_ORDER);
>  	nc->size = page ? PAGE_FRAG_CACHE_MAX_SIZE : PAGE_SIZE;
> @@ -4150,7 +4150,7 @@ void *page_frag_alloc(struct page_frag_cache *nc,
>  	int offset;
>  
>  	if (unlikely(!nc->va)) {
> -refill:
> +	refill:
>  		page = __page_frag_cache_refill(nc, gfp_mask);
>  		if (!page)
>  			return NULL;
> @@ -4209,7 +4209,7 @@ void page_frag_free(void *addr)
>  EXPORT_SYMBOL(page_frag_free);
>  
>  static void *make_alloc_exact(unsigned long addr, unsigned int order,
> -		size_t size)
> +			      size_t size)
>  {
>  	if (addr) {
>  		unsigned long alloc_end = addr + (PAGE_SIZE << order);
> @@ -4378,7 +4378,7 @@ long si_mem_available(void)
>  	 * and cannot be freed. Cap this estimate at the low watermark.
>  	 */
>  	available += global_page_state(NR_SLAB_RECLAIMABLE) -
> -		     min(global_page_state(NR_SLAB_RECLAIMABLE) / 2, wmark_low);
> +		min(global_page_state(NR_SLAB_RECLAIMABLE) / 2, wmark_low);
>  
>  	if (available < 0)
>  		available = 0;
> @@ -4714,7 +4714,7 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
>  		zone = pgdat->node_zones + zone_type;
>  		if (managed_zone(zone)) {
>  			zoneref_set_zone(zone,
> -				&zonelist->_zonerefs[nr_zones++]);
> +					 &zonelist->_zonerefs[nr_zones++]);
>  			check_highest_zone(zone_type);
>  		}
>  	} while (zone_type);
> @@ -4792,8 +4792,8 @@ early_param("numa_zonelist_order", setup_numa_zonelist_order);
>   * sysctl handler for numa_zonelist_order
>   */
>  int numa_zonelist_order_handler(struct ctl_table *table, int write,
> -		void __user *buffer, size_t *length,
> -		loff_t *ppos)
> +				void __user *buffer, size_t *length,
> +				loff_t *ppos)
>  {
>  	char saved_string[NUMA_ZONELIST_ORDER_LEN];
>  	int ret;
> @@ -4952,7 +4952,7 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
>  			z = &NODE_DATA(node)->node_zones[zone_type];
>  			if (managed_zone(z)) {
>  				zoneref_set_zone(z,
> -					&zonelist->_zonerefs[pos++]);
> +						 &zonelist->_zonerefs[pos++]);
>  				check_highest_zone(zone_type);
>  			}
>  		}
> @@ -5056,8 +5056,8 @@ int local_memory_node(int node)
>  	struct zoneref *z;
>  
>  	z = first_zones_zonelist(node_zonelist(node, GFP_KERNEL),
> -				   gfp_zone(GFP_KERNEL),
> -				   NULL);
> +				 gfp_zone(GFP_KERNEL),
> +				 NULL);
>  	return z->zone->node;
>  }
>  #endif
> @@ -5248,7 +5248,7 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
>   * done. Non-atomic initialization, single-pass.
>   */
>  void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> -		unsigned long start_pfn, enum memmap_context context)
> +				unsigned long start_pfn, enum memmap_context context)
>  {
>  	struct vmem_altmap *altmap = to_vmem_altmap(__pfn_to_phys(start_pfn));
>  	unsigned long end_pfn = start_pfn + size;
> @@ -5315,7 +5315,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  		}
>  #endif
>  
> -not_early:
> +	not_early:
>  		/*
>  		 * Mark the block movable so that blocks are reserved for
>  		 * movable at startup. This will force kernel allocations
> @@ -5349,7 +5349,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
>  }
>  
>  #ifndef __HAVE_ARCH_MEMMAP_INIT
> -#define memmap_init(size, nid, zone, start_pfn) \
> +#define memmap_init(size, nid, zone, start_pfn)				\
>  	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
>  #endif
>  
> @@ -5417,13 +5417,13 @@ static int zone_batchsize(struct zone *zone)
>   * exist).
>   */
>  static void pageset_update(struct per_cpu_pages *pcp, unsigned long high,
> -		unsigned long batch)
> +			   unsigned long batch)
>  {
> -       /* start with a fail safe value for batch */
> +	/* start with a fail safe value for batch */
>  	pcp->batch = 1;
>  	smp_wmb();
>  
> -       /* Update high, then batch, in order */
> +	/* Update high, then batch, in order */
>  	pcp->high = high;
>  	smp_wmb();
>  
> @@ -5460,7 +5460,7 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
>   * to the value high for the pageset p.
>   */
>  static void pageset_set_high(struct per_cpu_pageset *p,
> -				unsigned long high)
> +			     unsigned long high)
>  {
>  	unsigned long batch = max(1UL, high / 4);
>  	if ((high / 4) > (PAGE_SHIFT * 8))
> @@ -5474,8 +5474,8 @@ static void pageset_set_high_and_batch(struct zone *zone,
>  {
>  	if (percpu_pagelist_fraction)
>  		pageset_set_high(pcp,
> -			(zone->managed_pages /
> -				percpu_pagelist_fraction));
> +				 (zone->managed_pages /
> +				  percpu_pagelist_fraction));
>  	else
>  		pageset_set_batch(pcp, zone_batchsize(zone));
>  }
> @@ -5510,7 +5510,7 @@ void __init setup_per_cpu_pageset(void)
>  
>  	for_each_online_pgdat(pgdat)
>  		pgdat->per_cpu_nodestats =
> -			alloc_percpu(struct per_cpu_nodestat);
> +		alloc_percpu(struct per_cpu_nodestat);
>  }
>  
>  static __meminit void zone_pcp_init(struct zone *zone)
> @@ -5538,10 +5538,10 @@ int __meminit init_currently_empty_zone(struct zone *zone,
>  	zone->zone_start_pfn = zone_start_pfn;
>  
>  	mminit_dprintk(MMINIT_TRACE, "memmap_init",
> -			"Initialising map node %d zone %lu pfns %lu -> %lu\n",
> -			pgdat->node_id,
> -			(unsigned long)zone_idx(zone),
> -			zone_start_pfn, (zone_start_pfn + size));
> +		       "Initialising map node %d zone %lu pfns %lu -> %lu\n",
> +		       pgdat->node_id,
> +		       (unsigned long)zone_idx(zone),
> +		       zone_start_pfn, (zone_start_pfn + size));
>  
>  	zone_init_free_lists(zone);
>  	zone->initialized = 1;
> @@ -5556,7 +5556,7 @@ int __meminit init_currently_empty_zone(struct zone *zone,
>   * Required by SPARSEMEM. Given a PFN, return what node the PFN is on.
>   */
>  int __meminit __early_pfn_to_nid(unsigned long pfn,
> -					struct mminit_pfnnid_cache *state)
> +				 struct mminit_pfnnid_cache *state)
>  {
>  	unsigned long start_pfn, end_pfn;
>  	int nid;
> @@ -5595,8 +5595,8 @@ void __init free_bootmem_with_active_regions(int nid, unsigned long max_low_pfn)
>  
>  		if (start_pfn < end_pfn)
>  			memblock_free_early_nid(PFN_PHYS(start_pfn),
> -					(end_pfn - start_pfn) << PAGE_SHIFT,
> -					this_nid);
> +						(end_pfn - start_pfn) << PAGE_SHIFT,
> +						this_nid);
>  	}
>  }
>  
> @@ -5628,7 +5628,7 @@ void __init sparse_memory_present_with_active_regions(int nid)
>   * PFNs will be 0.
>   */
>  void __meminit get_pfn_range_for_nid(unsigned int nid,
> -			unsigned long *start_pfn, unsigned long *end_pfn)
> +				     unsigned long *start_pfn, unsigned long *end_pfn)
>  {
>  	unsigned long this_start_pfn, this_end_pfn;
>  	int i;
> @@ -5658,7 +5658,7 @@ static void __init find_usable_zone_for_movable(void)
>  			continue;
>  
>  		if (arch_zone_highest_possible_pfn[zone_index] >
> -				arch_zone_lowest_possible_pfn[zone_index])
> +		    arch_zone_lowest_possible_pfn[zone_index])
>  			break;
>  	}
>  
> @@ -5677,11 +5677,11 @@ static void __init find_usable_zone_for_movable(void)
>   * zones within a node are in order of monotonic increases memory addresses
>   */
>  static void __meminit adjust_zone_range_for_zone_movable(int nid,
> -					unsigned long zone_type,
> -					unsigned long node_start_pfn,
> -					unsigned long node_end_pfn,
> -					unsigned long *zone_start_pfn,
> -					unsigned long *zone_end_pfn)
> +							 unsigned long zone_type,
> +							 unsigned long node_start_pfn,
> +							 unsigned long node_end_pfn,
> +							 unsigned long *zone_start_pfn,
> +							 unsigned long *zone_end_pfn)
>  {
>  	/* Only adjust if ZONE_MOVABLE is on this node */
>  	if (zone_movable_pfn[nid]) {
> @@ -5689,15 +5689,15 @@ static void __meminit adjust_zone_range_for_zone_movable(int nid,
>  		if (zone_type == ZONE_MOVABLE) {
>  			*zone_start_pfn = zone_movable_pfn[nid];
>  			*zone_end_pfn = min(node_end_pfn,
> -				arch_zone_highest_possible_pfn[movable_zone]);
> +					    arch_zone_highest_possible_pfn[movable_zone]);
>  
> -		/* Adjust for ZONE_MOVABLE starting within this range */
> +			/* Adjust for ZONE_MOVABLE starting within this range */
>  		} else if (!mirrored_kernelcore &&
> -			*zone_start_pfn < zone_movable_pfn[nid] &&
> -			*zone_end_pfn > zone_movable_pfn[nid]) {
> +			   *zone_start_pfn < zone_movable_pfn[nid] &&
> +			   *zone_end_pfn > zone_movable_pfn[nid]) {
>  			*zone_end_pfn = zone_movable_pfn[nid];
>  
> -		/* Check if this whole range is within ZONE_MOVABLE */
> +			/* Check if this whole range is within ZONE_MOVABLE */
>  		} else if (*zone_start_pfn >= zone_movable_pfn[nid])
>  			*zone_start_pfn = *zone_end_pfn;
>  	}
> @@ -5708,12 +5708,12 @@ static void __meminit adjust_zone_range_for_zone_movable(int nid,
>   * present_pages = zone_spanned_pages_in_node() - zone_absent_pages_in_node()
>   */
>  static unsigned long __meminit zone_spanned_pages_in_node(int nid,
> -					unsigned long zone_type,
> -					unsigned long node_start_pfn,
> -					unsigned long node_end_pfn,
> -					unsigned long *zone_start_pfn,
> -					unsigned long *zone_end_pfn,
> -					unsigned long *ignored)
> +							  unsigned long zone_type,
> +							  unsigned long node_start_pfn,
> +							  unsigned long node_end_pfn,
> +							  unsigned long *zone_start_pfn,
> +							  unsigned long *zone_end_pfn,
> +							  unsigned long *ignored)
>  {
>  	/* When hotadd a new node from cpu_up(), the node should be empty */
>  	if (!node_start_pfn && !node_end_pfn)
> @@ -5723,8 +5723,8 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
>  	*zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
>  	*zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
>  	adjust_zone_range_for_zone_movable(nid, zone_type,
> -				node_start_pfn, node_end_pfn,
> -				zone_start_pfn, zone_end_pfn);
> +					   node_start_pfn, node_end_pfn,
> +					   zone_start_pfn, zone_end_pfn);
>  
>  	/* Check that this node has pages within the zone's required range */
>  	if (*zone_end_pfn < node_start_pfn || *zone_start_pfn > node_end_pfn)
> @@ -5743,8 +5743,8 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
>   * then all holes in the requested range will be accounted for.
>   */
>  unsigned long __meminit __absent_pages_in_range(int nid,
> -				unsigned long range_start_pfn,
> -				unsigned long range_end_pfn)
> +						unsigned long range_start_pfn,
> +						unsigned long range_end_pfn)
>  {
>  	unsigned long nr_absent = range_end_pfn - range_start_pfn;
>  	unsigned long start_pfn, end_pfn;
> @@ -5766,17 +5766,17 @@ unsigned long __meminit __absent_pages_in_range(int nid,
>   * It returns the number of pages frames in memory holes within a range.
>   */
>  unsigned long __init absent_pages_in_range(unsigned long start_pfn,
> -							unsigned long end_pfn)
> +					   unsigned long end_pfn)
>  {
>  	return __absent_pages_in_range(MAX_NUMNODES, start_pfn, end_pfn);
>  }
>  
>  /* Return the number of page frames in holes in a zone on a node */
>  static unsigned long __meminit zone_absent_pages_in_node(int nid,
> -					unsigned long zone_type,
> -					unsigned long node_start_pfn,
> -					unsigned long node_end_pfn,
> -					unsigned long *ignored)
> +							 unsigned long zone_type,
> +							 unsigned long node_start_pfn,
> +							 unsigned long node_end_pfn,
> +							 unsigned long *ignored)
>  {
>  	unsigned long zone_low = arch_zone_lowest_possible_pfn[zone_type];
>  	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
> @@ -5791,8 +5791,8 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
>  	zone_end_pfn = clamp(node_end_pfn, zone_low, zone_high);
>  
>  	adjust_zone_range_for_zone_movable(nid, zone_type,
> -			node_start_pfn, node_end_pfn,
> -			&zone_start_pfn, &zone_end_pfn);
> +					   node_start_pfn, node_end_pfn,
> +					   &zone_start_pfn, &zone_end_pfn);
>  
>  	/* If this node has no page within this zone, return 0. */
>  	if (zone_start_pfn == zone_end_pfn)
> @@ -5830,12 +5830,12 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
>  
>  #else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>  static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
> -					unsigned long zone_type,
> -					unsigned long node_start_pfn,
> -					unsigned long node_end_pfn,
> -					unsigned long *zone_start_pfn,
> -					unsigned long *zone_end_pfn,
> -					unsigned long *zones_size)
> +								 unsigned long zone_type,
> +								 unsigned long node_start_pfn,
> +								 unsigned long node_end_pfn,
> +								 unsigned long *zone_start_pfn,
> +								 unsigned long *zone_end_pfn,
> +								 unsigned long *zones_size)
>  {
>  	unsigned int zone;
>  
> @@ -5849,10 +5849,10 @@ static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
>  }
>  
>  static inline unsigned long __meminit zone_absent_pages_in_node(int nid,
> -						unsigned long zone_type,
> -						unsigned long node_start_pfn,
> -						unsigned long node_end_pfn,
> -						unsigned long *zholes_size)
> +								unsigned long zone_type,
> +								unsigned long node_start_pfn,
> +								unsigned long node_end_pfn,
> +								unsigned long *zholes_size)
>  {
>  	if (!zholes_size)
>  		return 0;
> @@ -5883,8 +5883,8 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
>  						  &zone_end_pfn,
>  						  zones_size);
>  		real_size = size - zone_absent_pages_in_node(pgdat->node_id, i,
> -						  node_start_pfn, node_end_pfn,
> -						  zholes_size);
> +							     node_start_pfn, node_end_pfn,
> +							     zholes_size);
>  		if (size)
>  			zone->zone_start_pfn = zone_start_pfn;
>  		else
> @@ -6143,7 +6143,7 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
>  }
>  
>  void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
> -		unsigned long node_start_pfn, unsigned long *zholes_size)
> +				      unsigned long node_start_pfn, unsigned long *zholes_size)
>  {
>  	pg_data_t *pgdat = NODE_DATA(nid);
>  	unsigned long start_pfn = 0;
> @@ -6428,12 +6428,12 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  			if (start_pfn < usable_startpfn) {
>  				unsigned long kernel_pages;
>  				kernel_pages = min(end_pfn, usable_startpfn)
> -								- start_pfn;
> +					- start_pfn;
>  
>  				kernelcore_remaining -= min(kernel_pages,
> -							kernelcore_remaining);
> +							    kernelcore_remaining);
>  				required_kernelcore -= min(kernel_pages,
> -							required_kernelcore);
> +							   required_kernelcore);
>  
>  				/* Continue if range is now fully accounted */
>  				if (end_pfn <= usable_startpfn) {
> @@ -6466,7 +6466,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  			 * satisfied
>  			 */
>  			required_kernelcore -= min(required_kernelcore,
> -								size_pages);
> +						   size_pages);
>  			kernelcore_remaining -= size_pages;
>  			if (!kernelcore_remaining)
>  				break;
> @@ -6534,9 +6534,9 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  
>  	/* Record where the zone boundaries are */
>  	memset(arch_zone_lowest_possible_pfn, 0,
> -				sizeof(arch_zone_lowest_possible_pfn));
> +	       sizeof(arch_zone_lowest_possible_pfn));
>  	memset(arch_zone_highest_possible_pfn, 0,
> -				sizeof(arch_zone_highest_possible_pfn));
> +	       sizeof(arch_zone_highest_possible_pfn));
>  
>  	start_pfn = find_min_pfn_with_active_regions();
>  
> @@ -6562,14 +6562,14 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  			continue;
>  		pr_info("  %-8s ", zone_names[i]);
>  		if (arch_zone_lowest_possible_pfn[i] ==
> -				arch_zone_highest_possible_pfn[i])
> +		    arch_zone_highest_possible_pfn[i])
>  			pr_cont("empty\n");
>  		else
>  			pr_cont("[mem %#018Lx-%#018Lx]\n",
>  				(u64)arch_zone_lowest_possible_pfn[i]
> -					<< PAGE_SHIFT,
> +				<< PAGE_SHIFT,
>  				((u64)arch_zone_highest_possible_pfn[i]
> -					<< PAGE_SHIFT) - 1);
> +				 << PAGE_SHIFT) - 1);
>  	}
>  
>  	/* Print out the PFNs ZONE_MOVABLE begins at in each node */
> @@ -6577,7 +6577,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  	for (i = 0; i < MAX_NUMNODES; i++) {
>  		if (zone_movable_pfn[i])
>  			pr_info("  Node %d: %#018Lx\n", i,
> -			       (u64)zone_movable_pfn[i] << PAGE_SHIFT);
> +				(u64)zone_movable_pfn[i] << PAGE_SHIFT);
>  	}
>  
>  	/* Print out the early node map */
> @@ -6593,7 +6593,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>  	for_each_online_node(nid) {
>  		pg_data_t *pgdat = NODE_DATA(nid);
>  		free_area_init_node(nid, NULL,
> -				find_min_pfn_for_node(nid), NULL);
> +				    find_min_pfn_for_node(nid), NULL);
>  
>  		/* Any memory on that node */
>  		if (pgdat->node_present_pages)
> @@ -6711,14 +6711,14 @@ void __init mem_init_print_info(const char *str)
>  	 *    please refer to arch/tile/kernel/vmlinux.lds.S.
>  	 * 3) .rodata.* may be embedded into .text or .data sections.
>  	 */
> -#define adj_init_size(start, end, size, pos, adj) \
> -	do { \
> -		if (start <= pos && pos < end && size > adj) \
> -			size -= adj; \
> +#define adj_init_size(start, end, size, pos, adj)		\
> +	do {							\
> +		if (start <= pos && pos < end && size > adj)	\
> +			size -= adj;				\
>  	} while (0)
>  
>  	adj_init_size(__init_begin, __init_end, init_data_size,
> -		     _sinittext, init_code_size);
> +		      _sinittext, init_code_size);
>  	adj_init_size(_stext, _etext, codesize, _sinittext, init_code_size);
>  	adj_init_size(_sdata, _edata, datasize, __init_begin, init_data_size);
>  	adj_init_size(_stext, _etext, codesize, __start_rodata, rosize);
> @@ -6762,7 +6762,7 @@ void __init set_dma_reserve(unsigned long new_dma_reserve)
>  void __init free_area_init(unsigned long *zones_size)
>  {
>  	free_area_init_node(0, zones_size,
> -			__pa(PAGE_OFFSET) >> PAGE_SHIFT, NULL);
> +			    __pa(PAGE_OFFSET) >> PAGE_SHIFT, NULL);
>  }
>  
>  static int page_alloc_cpu_dead(unsigned int cpu)
> @@ -6992,7 +6992,7 @@ int __meminit init_per_zone_wmark_min(void)
>  			min_free_kbytes = 65536;
>  	} else {
>  		pr_warn("min_free_kbytes is not updated to %d because user defined value %d is preferred\n",
> -				new_min_free_kbytes, user_min_free_kbytes);
> +			new_min_free_kbytes, user_min_free_kbytes);
>  	}
>  	setup_per_zone_wmarks();
>  	refresh_zone_stat_thresholds();
> @@ -7013,7 +7013,7 @@ core_initcall(init_per_zone_wmark_min)
>   *	changes.
>   */
>  int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
> -	void __user *buffer, size_t *length, loff_t *ppos)
> +				   void __user *buffer, size_t *length, loff_t *ppos)
>  {
>  	int rc;
>  
> @@ -7029,7 +7029,7 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
>  }
>  
>  int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
> -	void __user *buffer, size_t *length, loff_t *ppos)
> +					  void __user *buffer, size_t *length, loff_t *ppos)
>  {
>  	int rc;
>  
> @@ -7054,12 +7054,12 @@ static void setup_min_unmapped_ratio(void)
>  
>  	for_each_zone(zone)
>  		zone->zone_pgdat->min_unmapped_pages += (zone->managed_pages *
> -				sysctl_min_unmapped_ratio) / 100;
> +							 sysctl_min_unmapped_ratio) / 100;
>  }
>  
>  
>  int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
> -	void __user *buffer, size_t *length, loff_t *ppos)
> +					     void __user *buffer, size_t *length, loff_t *ppos)
>  {
>  	int rc;
>  
> @@ -7082,11 +7082,11 @@ static void setup_min_slab_ratio(void)
>  
>  	for_each_zone(zone)
>  		zone->zone_pgdat->min_slab_pages += (zone->managed_pages *
> -				sysctl_min_slab_ratio) / 100;
> +						     sysctl_min_slab_ratio) / 100;
>  }
>  
>  int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
> -	void __user *buffer, size_t *length, loff_t *ppos)
> +					 void __user *buffer, size_t *length, loff_t *ppos)
>  {
>  	int rc;
>  
> @@ -7110,7 +7110,7 @@ int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
>   * if in function of the boot time zone sizes.
>   */
>  int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *table, int write,
> -	void __user *buffer, size_t *length, loff_t *ppos)
> +					void __user *buffer, size_t *length, loff_t *ppos)
>  {
>  	proc_dointvec_minmax(table, write, buffer, length, ppos);
>  	setup_per_zone_lowmem_reserve();
> @@ -7123,7 +7123,7 @@ int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *table, int write,
>   * pagelist can have before it gets flushed back to buddy allocator.
>   */
>  int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
> -	void __user *buffer, size_t *length, loff_t *ppos)
> +					    void __user *buffer, size_t *length, loff_t *ppos)
>  {
>  	struct zone *zone;
>  	int old_percpu_pagelist_fraction;
> @@ -7153,7 +7153,7 @@ int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
>  
>  		for_each_possible_cpu(cpu)
>  			pageset_set_high_and_batch(zone,
> -					per_cpu_ptr(zone->pageset, cpu));
> +						   per_cpu_ptr(zone->pageset, cpu));
>  	}
>  out:
>  	mutex_unlock(&pcp_batch_high_lock);
> @@ -7461,7 +7461,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>  		}
>  
>  		nr_reclaimed = reclaim_clean_pages_from_list(cc->zone,
> -							&cc->migratepages);
> +							     &cc->migratepages);
>  		cc->nr_migratepages -= nr_reclaimed;
>  
>  		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
> @@ -7645,7 +7645,7 @@ void __meminit zone_pcp_update(struct zone *zone)
>  	mutex_lock(&pcp_batch_high_lock);
>  	for_each_possible_cpu(cpu)
>  		pageset_set_high_and_batch(zone,
> -				per_cpu_ptr(zone->pageset, cpu));
> +					   per_cpu_ptr(zone->pageset, cpu));
>  	mutex_unlock(&pcp_batch_high_lock);
>  }
>  #endif
> -- 
> 2.10.0.rc2.1.g053435c
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
