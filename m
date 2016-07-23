Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF536B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 20:45:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y134so266089102pfg.1
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 17:45:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id b1si18671196pfc.187.2016.07.22.17.45.45
        for <linux-mm@kvack.org>;
        Fri, 22 Jul 2016 17:45:45 -0700 (PDT)
Date: Sat, 23 Jul 2016 08:45:15 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] mm: add per-zone lru list stat
Message-ID: <20160723004514.GA75542@bee>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-3-git-send-email-mgorman@techsingularity.net>
 <20160721071002.GA27554@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20160721071002.GA27554@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, fengguang.wu@intel.com

Hi Minchan,

We find duplicate /proc/vmstat lines showing up in linux-next, which
look related to this patch.

>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -921,6 +921,11 @@ int fragmentation_index(struct zone *zone, unsigned int order)
>>  const char * const vmstat_text[] = {
>>  	/* enum zone_stat_item countes */
>>  	"nr_free_pages",
>> +	"nr_inactive_anon",
>> +	"nr_active_anon",
>> +	"nr_inactive_file",
>> +	"nr_active_file",
>> +	"nr_unevictable",
>>  	"nr_mlock",
>>  	"nr_slab_reclaimable",
>>  	"nr_slab_unreclaimable",

In the below vmstat output, "nr_inactive_anon 2217" is shown twice.
So do the other entries added by the above chunk.

nr_free_pages 831238
nr_inactive_anon 2217
nr_active_anon 4386
nr_inactive_file 117467
nr_active_file 4602
nr_unevictable 0
nr_zone_write_pending 0
nr_mlock 0
nr_slab_reclaimable 8323
nr_slab_unreclaimable 4641
nr_page_table_pages 870
nr_kernel_stack 3776
nr_bounce 0
nr_zspages 0
numa_hit 201105
numa_miss 0
numa_foreign 0
numa_interleave 66970
numa_local 201105
numa_other 0
nr_free_cma 0
nr_inactive_anon 2217
nr_active_anon 4368
nr_inactive_file 117449
nr_active_file 4620
nr_unevictable 0
nr_isolated_anon 0
nr_isolated_file 0
nr_pages_scanned 0
workingset_refault 0
workingset_activate 0
workingset_nodereclaim 0
nr_anon_pages 4321
nr_mapped 3469
nr_file_pages 124348
nr_dirty 0
nr_writeback 0
nr_writeback_temp 0
nr_shmem 2279
nr_shmem_hugepages 0
nr_shmem_pmdmapped 0
...

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
