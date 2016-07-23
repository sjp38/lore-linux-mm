Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0096B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 21:24:55 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id r71so282808568ioi.3
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 18:24:55 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id k125si10067134ita.83.2016.07.22.18.24.53
        for <linux-mm@kvack.org>;
        Fri, 22 Jul 2016 18:24:54 -0700 (PDT)
Date: Sat, 23 Jul 2016 10:25:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/5] mm: add per-zone lru list stat
Message-ID: <20160723012519.GA24214@bbox>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-3-git-send-email-mgorman@techsingularity.net>
 <20160721071002.GA27554@js1304-P5Q-DELUXE>
 <20160723004514.GA75542@bee>
MIME-Version: 1.0
In-Reply-To: <20160723004514.GA75542@bee>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Fengguang,

On Sat, Jul 23, 2016 at 08:45:15AM +0800, Fengguang Wu wrote:
> Hi Minchan,
> 
> We find duplicate /proc/vmstat lines showing up in linux-next, which
> look related to this patch.
> 
> >>--- a/mm/vmstat.c
> >>+++ b/mm/vmstat.c
> >>@@ -921,6 +921,11 @@ int fragmentation_index(struct zone *zone, unsigned int order)
> >> const char * const vmstat_text[] = {
> >> 	/* enum zone_stat_item countes */
> >> 	"nr_free_pages",
> >>+	"nr_inactive_anon",
> >>+	"nr_active_anon",
> >>+	"nr_inactive_file",
> >>+	"nr_active_file",
> >>+	"nr_unevictable",
> >> 	"nr_mlock",
> >> 	"nr_slab_reclaimable",
> >> 	"nr_slab_unreclaimable",
> 
> In the below vmstat output, "nr_inactive_anon 2217" is shown twice.
> So do the other entries added by the above chunk.
> 
> nr_free_pages 831238
> nr_inactive_anon 2217
> nr_active_anon 4386
> nr_inactive_file 117467
> nr_active_file 4602
> nr_unevictable 0
> nr_zone_write_pending 0
> nr_mlock 0
> nr_slab_reclaimable 8323
> nr_slab_unreclaimable 4641
> nr_page_table_pages 870
> nr_kernel_stack 3776
> nr_bounce 0
> nr_zspages 0
> numa_hit 201105
> numa_miss 0
> numa_foreign 0
> numa_interleave 66970
> numa_local 201105
> numa_other 0
> nr_free_cma 0
> nr_inactive_anon 2217
> nr_active_anon 4368
> nr_inactive_file 117449
> nr_active_file 4620
> nr_unevictable 0
> nr_isolated_anon 0
> nr_isolated_file 0
> nr_pages_scanned 0
> workingset_refault 0
> workingset_activate 0
> workingset_nodereclaim 0
> nr_anon_pages 4321
> nr_mapped 3469
> nr_file_pages 124348
> nr_dirty 0
> nr_writeback 0
> nr_writeback_temp 0
> nr_shmem 2279
> nr_shmem_hugepages 0
> nr_shmem_pmdmapped 0

Thanks for catching that.
We need a decision to maintain LRU stat both per-zone and per-node.

Mel, do you want to keep the LRU stat in per-node in addition?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
