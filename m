Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD18E6B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 10:28:46 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so41637142lbb.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:28:46 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id s82si1149667wmd.19.2016.06.22.07.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 07:28:45 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id c82so1686561wme.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:28:45 -0700 (PDT)
Date: Wed, 22 Jun 2016 16:28:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 17/27] mm: Rename NR_ANON_PAGES to NR_ANON_MAPPED
Message-ID: <20160622142844.GD7527@dhcp22.suse.cz>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-18-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466518566-30034-18-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 21-06-16 15:15:56, Mel Gorman wrote:
> NR_FILE_PAGES  is the number of        file pages.
> NR_FILE_MAPPED is the number of mapped file pages.
> NR_ANON_PAGES  is the number of mapped anon pages.
> 
> This is unhelpful naming as it's easy to confuse NR_FILE_MAPPED and NR_ANON_PAGES for
> mapped pages. This patch renames NR_ANON_PAGES so we have
> 
> NR_FILE_PAGES  is the number of        file pages.
> NR_FILE_MAPPED is the number of mapped file pages.
> NR_ANON_MAPPED is the number of mapped anon pages.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/base/node.c    | 2 +-
>  fs/proc/meminfo.c      | 2 +-
>  include/linux/mmzone.h | 2 +-
>  mm/migrate.c           | 2 +-
>  mm/rmap.c              | 8 ++++----
>  5 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 66aed68a0fdc..897b6bcb36be 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -120,7 +120,7 @@ static ssize_t node_read_meminfo(struct device *dev,
>  		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK)),
>  		       nid, K(sum_zone_node_page_state(nid, NR_FILE_PAGES)),
>  		       nid, K(node_page_state(pgdat, NR_FILE_MAPPED)),
> -		       nid, K(node_page_state(pgdat, NR_ANON_PAGES)),
> +		       nid, K(node_page_state(pgdat, NR_ANON_MAPPED)),
>  		       nid, K(i.sharedram),
>  		       nid, sum_zone_node_page_state(nid, NR_KERNEL_STACK) *
>  				THREAD_SIZE / 1024,
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 54e039682ec9..076afb43fc56 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -138,7 +138,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  		K(i.freeswap),
>  		K(global_page_state(NR_FILE_DIRTY)),
>  		K(global_page_state(NR_WRITEBACK)),
> -		K(global_node_page_state(NR_ANON_PAGES)),
> +		K(global_node_page_state(NR_ANON_MAPPED)),
>  		K(global_node_page_state(NR_FILE_MAPPED)),
>  		K(i.sharedram),
>  		K(global_page_state(NR_SLAB_RECLAIMABLE) +
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 8fafbd5fe74a..6b1fea6cde9a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -159,7 +159,7 @@ enum node_stat_item {
>  	WORKINGSET_REFAULT,
>  	WORKINGSET_ACTIVATE,
>  	WORKINGSET_NODERECLAIM,
> -	NR_ANON_PAGES,	/* Mapped anonymous pages */
> +	NR_ANON_MAPPED,	/* Mapped anonymous pages */
>  	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
>  			   only modified from process context */
>  	NR_VM_NODE_STAT_ITEMS
> diff --git a/mm/migrate.c b/mm/migrate.c
> index ffd86850564c..1582c07205c6 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -501,7 +501,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	 * new page and drop references to the old page.
>  	 *
>  	 * Note that anonymous pages are accounted for
> -	 * via NR_FILE_PAGES and NR_ANON_PAGES if they
> +	 * via NR_FILE_PAGES and NR_ANON_MAPPED if they
>  	 * are mapped to swap space.
>  	 */
>  	if (newzone != oldzone) {
> diff --git a/mm/rmap.c b/mm/rmap.c
> index dea2d115d68f..1c1455d2d39d 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1219,7 +1219,7 @@ void do_page_add_anon_rmap(struct page *page,
>  			__inc_zone_page_state(page,
>  					      NR_ANON_TRANSPARENT_HUGEPAGES);
>  		}
> -		__mod_node_page_state(page_pgdat(page), NR_ANON_PAGES, nr);
> +		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, nr);
>  	}
>  	if (unlikely(PageKsm(page)))
>  		return;
> @@ -1263,7 +1263,7 @@ void page_add_new_anon_rmap(struct page *page,
>  		/* increment count (starts at -1) */
>  		atomic_set(&page->_mapcount, 0);
>  	}
> -	__mod_node_page_state(page_pgdat(page), NR_ANON_PAGES, nr);
> +	__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, nr);
>  	__page_set_anon_rmap(page, vma, address, 1);
>  }
>  
> @@ -1345,7 +1345,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
>  		clear_page_mlock(page);
>  
>  	if (nr) {
> -		__mod_node_page_state(page_pgdat(page), NR_ANON_PAGES, -nr);
> +		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
>  		deferred_split_huge_page(page);
>  	}
>  }
> @@ -1377,7 +1377,7 @@ void page_remove_rmap(struct page *page, bool compound)
>  	 * these counters are not modified in interrupt context, and
>  	 * pte lock(a spinlock) is held, which implies preemption disabled.
>  	 */
> -	__dec_node_page_state(page, NR_ANON_PAGES);
> +	__dec_node_page_state(page, NR_ANON_MAPPED);
>  
>  	if (unlikely(PageMlocked(page)))
>  		clear_page_mlock(page);
> -- 
> 2.6.4
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
