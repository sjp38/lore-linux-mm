Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id CDA866B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 16:15:46 -0400 (EDT)
Received: by wibhn6 with SMTP id hn6so4085329wib.8
        for <linux-mm@kvack.org>; Thu, 15 Mar 2012 13:15:45 -0700 (PDT)
Message-ID: <4F624DED.2060302@suse.cz>
Date: Thu, 15 Mar 2012 21:15:41 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: Too much free memory (not used for FS cache)
References: <4F624C88.6050503@suse.cz>
In-Reply-To: <4F624C88.6050503@suse.cz>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 03/15/2012 09:09 PM, Jiri Slaby wrote:
> Hi,
> 
> since today's -next (20120315), the MM/VFS system is very sluggish.
> Especially when committing, diffing and similar with git. I still have
> 2G of 6G of memory free. But with each commit I have to wait for git to
> fetch all data from disk.
> 
> I'm using ext4 on a raid for the partition with git kernel repository if
> that matters.
> 
> Any idea what that could be?

Please ignore this. It's not as easy as that. It doesn't wait for IO and
needs more investigation...

> nr_free_pages 555469
> nr_inactive_anon 16787
> nr_active_anon 414439
> nr_inactive_file 315585
> nr_active_file 137446
> nr_unevictable 0
> nr_mlock 0
> nr_anon_pages 277729
> nr_mapped 95971
> nr_file_pages 524644
> nr_dirty 11
> nr_writeback 0
> nr_slab_reclaimable 35548
> nr_slab_unreclaimable 7450
> nr_page_table_pages 11493
> nr_kernel_stack 464
> nr_unstable 0
> nr_bounce 0
> nr_vmscan_write 0
> nr_vmscan_immediate_reclaim 0
> nr_writeback_temp 0
> nr_isolated_anon 0
> nr_isolated_file 0
> nr_shmem 71614
> nr_dirtied 1165398
> nr_written 1147058
> nr_anon_transparent_hugepages 160
> nr_dirty_threshold 97608
> nr_dirty_background_threshold 48804
> pgpgin 2446144
> pgpgout 4844237
> pswpin 0
> pswpout 0
> pgalloc_dma 0
> pgalloc_dma32 21764611
> pgalloc_normal 38307626
> pgalloc_movable 0
> pgfree 60640227
> pgactivate 913299
> pgdeactivate 109336
> pgfault 51012433
> pgmajfault 8476
> pgrefill_dma 0
> pgrefill_dma32 79208
> pgrefill_normal 41244
> pgrefill_movable 0
> pgsteal_dma 0
> pgsteal_dma32 162966
> pgsteal_normal 185373
> pgsteal_movable 0
> pgscan_kswapd_dma 0
> pgscan_kswapd_dma32 162559
> pgscan_kswapd_normal 215360
> pgscan_kswapd_movable 0
> pgscan_direct_dma 0
> pgscan_direct_dma32 1624
> pgscan_direct_normal 3927
> pgscan_direct_movable 0
> pginodesteal 4
> slabs_scanned 102400
> kswapd_steal 342881
> kswapd_inodesteal 756
> kswapd_low_wmark_hit_quickly 0
> kswapd_high_wmark_hit_quickly 119
> kswapd_skip_congestion_wait 0
> pageoutrun 3493
> allocstall 5
> pgrotated 240
> compact_blocks_moved 432
> compact_pages_moved 10699
> compact_pagemigrate_failed 0
> compact_stall 14
> compact_fail 5
> compact_success 9
> htlb_buddy_alloc_success 0
> htlb_buddy_alloc_fail 0
> unevictable_pgs_culled 327
> unevictable_pgs_scanned 0
> unevictable_pgs_rescued 2618
> unevictable_pgs_mlocked 2618
> unevictable_pgs_munlocked 2618
> unevictable_pgs_cleared 0
> unevictable_pgs_stranded 0
> unevictable_pgs_mlockfreed 0
> thp_fault_alloc 13147
> thp_fault_fallback 0
> thp_collapse_alloc 3543
> thp_collapse_alloc_failed 0
> thp_split 183
> 
> thanks,


-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
