Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9326B0295
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 08:45:39 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so19631059wmf.3
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 05:45:39 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id hp1si18503073wjb.225.2016.12.19.05.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 05:45:37 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id a20so18787823wme.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 05:45:37 -0800 (PST)
Date: Mon, 19 Dec 2016 14:45:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161219134534.GC5164@dhcp22.suse.cz>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216184655.GA5664@boerne.fritz.box>
 <20161217000203.GC23392@dhcp22.suse.cz>
 <20161217125950.GA3321@boerne.fritz.box>
 <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161217210646.GA11358@boerne.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Sat 17-12-16 22:06:47, Nils Holland wrote:
[...]
> Unfortunately, the reclaim trace messages stopped a while after the first
> OOM messages show up - most likely my "cat" had been killed at that
> point or became unresponsive. :-/

The later is more probable because I do not see the OOM killer to kill
any cat process and the first bash has been killed 10s after the first
OOM.

2016-12-17 21:36:56 192.168.17.23:6665 [ 1276.828639] Killed process 3894 (xz) total-vm:68640kB, anon-rss:65920kB, file-rss:1696kB, shmem-rss:0kB
2016-12-17 21:36:57 192.168.17.23:6665 [ 1277.598271] Killed process 3864 (sandbox) total-vm:2192kB, anon-rss:128kB, file-rss:1400kB, shmem-rss:0kB
2016-12-17 21:36:57 192.168.17.23:6665 [ 1278.222416] Killed process 3086 (emerge) total-vm:65064kB, anon-rss:52768kB, file-rss:7216kB, shmem-rss:0kB
2016-12-17 21:36:58 192.168.17.23:6665 [ 1278.846902] Killed process 2705 (NetworkManager) total-vm:104376kB, anon-rss:4172kB, file-rss:10516kB, shmem-rss:0kB
2016-12-17 21:36:59 192.168.17.23:6665 [ 1279.862150] Killed process 2823 (polkitd) total-vm:65536kB, anon-rss:2192kB, file-rss:8656kB, shmem-rss:0kB
2016-12-17 21:37:00 192.168.17.23:6665 [ 1280.496988] Killed process 3885 (ebuild.sh) total-vm:10640kB, anon-rss:3340kB, file-rss:2244kB, shmem-rss:0kB
2016-12-17 21:37:04 192.168.17.23:6665 [ 1285.126052] Killed process 2824 (wpa_supplicant) total-vm:8580kB, anon-rss:540kB, file-rss:5092kB, shmem-rss:0kB
2016-12-17 21:37:05 192.168.17.23:6665 [ 1286.124687] Killed process 2943 (bash) total-vm:7320kB, anon-rss:368kB, file-rss:3240kB, shmem-rss:0kB
2016-12-17 21:37:07 192.168.17.23:6665 [ 1287.974353] Killed process 2878 (sshd) total-vm:10524kB, anon-rss:700kB, file-rss:4908kB, shmem-rss:4kB
2016-12-17 21:37:16 192.168.17.23:6665 [ 1296.953350] Killed process 4048 (ebuild.sh) total-vm:10640kB, anon-rss:3352kB, file-rss:1892kB, shmem-rss:0kB
2016-12-17 21:37:24 192.168.17.23:6665 [ 1304.398944] Killed process 1980 (systemd-journal) total-vm:24640kB, anon-rss:332kB, file-rss:4608kB, shmem-rss:4kB
2016-12-17 21:37:25 192.168.17.23:6665 [ 1305.934472] Killed process 2918 ((sd-pam)) total-vm:9152kB, anon-rss:964kB, file-rss:1536kB, shmem-rss:0kB
2016-12-17 21:37:28 192.168.17.23:6665 [ 1308.878775] Killed process 2888 (systemd) total-vm:7856kB, anon-rss:528kB, file-rss:4388kB, shmem-rss:0kB
2016-12-17 21:37:34 192.168.17.23:6665 [ 1314.268177] Killed process 2711 (rsyslogd) total-vm:25200kB, anon-rss:1084kB, file-rss:2908kB, shmem-rss:0kB
2016-12-17 21:37:39 192.168.17.23:6665 [ 1319.634561] Killed process 2704 (systemd-logind) total-vm:5980kB, anon-rss:340kB, file-rss:3568kB, shmem-rss:0kB
2016-12-17 21:37:43 192.168.17.23:6665 [ 1323.488894] Killed process 3103 (htop) total-vm:7532kB, anon-rss:1024kB, file-rss:2872kB, shmem-rss:0kB
2016-12-17 21:38:42 192.168.17.23:6665 [ 1379.556282] Killed process 2701 (systemd-timesyn) total-vm:15480kB, anon-rss:356kB, file-rss:3292kB, shmem-rss:0kB
2016-12-17 21:39:05 192.168.17.23:6665 [ 1403.130435] Killed process 3082 (bash) total-vm:7324kB, anon-rss:380kB, file-rss:3324kB, shmem-rss:0kB
2016-12-17 21:39:17 192.168.17.23:6665 [ 1417.600367] Killed process 3077 (start_trace) total-vm:6948kB, anon-rss:184kB, file-rss:2524kB, shmem-rss:0kB
2016-12-17 21:39:24 192.168.17.23:6665 [ 1423.955452] Killed process 3073 (bash) total-vm:7324kB, anon-rss:380kB, file-rss:3284kB, shmem-rss:0kB
2016-12-17 21:39:27 192.168.17.23:6665 [ 1425.338670] Killed process 3099 (bash) total-vm:7324kB, anon-rss:376kB, file-rss:3176kB, shmem-rss:0kB
2016-12-17 21:39:27 192.168.17.23:6665 [ 1426.800677] Killed process 3070 (screen) total-vm:7440kB, anon-rss:960kB, file-rss:2360kB, shmem-rss:0kB
 
> In the end, the machine didn't completely panic, but after nothing new
> showed up being logged via the network, I walked up to the
> machine and found it in a state where I couldn't really log in to it
> anymore, but all that worked was, as always, a magic SysRequest reboot.
> 
> The complete log, from machine boot right up to the point where it
> wouldn't really do anything anymore, is up again on my web server (~42
> MB, 928 KB packed):
> 
> http://ftp.tisys.org/pub/misc/teela_2016-12-17.log.xz

$ xzgrep invoked teela_2016-12-17.log.xz | sed 's@.*gfp_mask=0x[0-9a-f]*(\(.*\)), .*@\1@' | sort | uniq -c
      2 GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK
      1 GFP_KERNEL|__GFP_NOTRACK
      6 GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_NOTRACK
      1 GFP_KERNEL|__GFP_NOWARN|__GFP_REPEAT|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_NOTRACK
      2 GFP_KERNEL|__GFP_REPEAT|__GFP_NOTRACK
      2 GFP_TEMPORARY
      5 GFP_TEMPORARY|__GFP_NOTRACK
      3 GFP_USER|__GFP_COLD

so all of them are lowmem requests which is in line with your previous
report. This basically means that only zone Normal is usable as I've
already mentioned before. In general lowmem problems are inherent to the
32b kernels but in this case we still have a _lot of_ page cache to
reclaim so we shouldn't really blow up. 

Normal free:41260kB min:41368kB low:51708kB high:62048kB active_anon:0kB inactive_anon:0kB active_file:532676kB inactive_file:100kB unevictable:0kB writepending:124kB present:897016kB managed:836248kB mlocked:0kB slab_reclaimable:157428kB slab_unreclaimable:68940kB kernel_stack:1160kB pagetables:1336kB bounce:0kB free_pcp:484kB local_pcp:240kB free_cma:0kB

and this looks very similar to your previous report as well. No
anonymous pages and the whole file LRU sitting in the active list so
there is nothing imediatelly reclaimable. This is very weird because
we should rotate the active list to the inactive if the later is low
which it obviously is here and this seems to be the case in other cases
as well (inactive_is_low.sh is a simple and dirty script to subtract
Highmem active/inactive counters from the node ones).

$ xzgrep -f zones teela_2016-12-17.log.xz | sh inactive_is_low.sh
total_active 1094600 active 541424 total_inactive 1117512 inactive 104 ratio 1 low 1
total_active 1094744 active 541568 total_inactive 1117524 inactive 116 ratio 1 low 1
total_active 1094864 active 541564 total_inactive 1117512 inactive 108 ratio 1 low 1
total_active 1095188 active 541564 total_inactive 1117220 inactive 116 ratio 1 low 1
total_active 1097520 active 541596 total_inactive 1115048 inactive 120 ratio 1 low 1
total_active 1097836 active 541612 total_inactive 1114764 inactive 136 ratio 1 low 1
total_active 1098692 active 542384 total_inactive 1114688 inactive 100 ratio 1 low 1
total_active 1098964 active 542504 total_inactive 1114480 inactive 24 ratio 1 low 1
total_active 1099108 active 542620 total_inactive 1114544 inactive 92 ratio 1 low 1
total_active 1099180 active 542548 total_inactive 1114564 inactive 236 ratio 1 low 1
[...]

Unfortunatelly shrink_active_list doesn't have any tracepoint so we do
not know whether we managed to rotate those pages. If they are referenced
quickly enough we might just keep refaulting them... Could you try to apply
the followin diff on top what you have currently. It should add some more
tracepoint data which might tell us more. We can reduce the amount of
tracing data by enabling only mm_vmscan_lru_isolate,
mm_vmscan_lru_shrink_inactive and mm_vmscan_lru_shrink_active.
---
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index bfe53d95c25b..2ba3e6dea6ef 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -519,7 +519,7 @@ void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_cold_page(struct page *page, bool cold);
-extern void free_hot_cold_page_list(struct list_head *list, bool cold);
+extern int free_hot_cold_page_list(struct list_head *list, bool cold);
 
 struct page_frag_cache;
 extern void __page_frag_drain(struct page *page, unsigned int order,
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c88fd0934e7e..7966915cf663 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -365,14 +365,27 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 
 	TP_PROTO(int nid,
 		unsigned long nr_scanned, unsigned long nr_reclaimed,
+		unsigned long nr_dirty, unsigned long nr_writeback,
+		unsigned long nr_congested, unsigned long nr_immediate,
+		unsigned long nr_activate, unsigned long nr_ref_keep,
+		unsigned long nr_unmap_fail,
 		int priority, int file),
 
-	TP_ARGS(nid, nr_scanned, nr_reclaimed, priority, file),
+	TP_ARGS(nid, nr_scanned, nr_reclaimed, nr_dirty, nr_writeback,
+		nr_congested, nr_immediate, nr_activate, nr_ref_keep,
+		nr_unmap_fail, priority, file),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
 		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_reclaimed)
+		__field(unsigned long, nr_dirty)
+		__field(unsigned long, nr_writeback)
+		__field(unsigned long, nr_congested)
+		__field(unsigned long, nr_immediate)
+		__field(unsigned long, nr_activate)
+		__field(unsigned long, nr_ref_keep)
+		__field(unsigned long, nr_unmap_fail)
 		__field(int, priority)
 		__field(int, reclaim_flags)
 	),
@@ -381,17 +394,63 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		__entry->nid = nid;
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_reclaimed = nr_reclaimed;
+		__entry->nr_dirty = nr_dirty;
+		__entry->nr_writeback = nr_writeback;
+		__entry->nr_congested = nr_congested;
+		__entry->nr_immediate = nr_immediate;
+		__entry->nr_activate = nr_activate;
+		__entry->nr_ref_keep = nr_ref_keep;
 		__entry->priority = priority;
 		__entry->reclaim_flags = trace_shrink_flags(file);
 	),
 
-	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
+	TP_printk("nid=%d nr_scanned=%ld nr_reclaimed=%ld nr_dirty=%ld nr_writeback=%ld nr_congested=%ld nr_immediate=%ld nr_activate=%ld nr_ref_keep=%ld nr_unmap_fail=%ld priority=%d flags=%s",
 		__entry->nid,
 		__entry->nr_scanned, __entry->nr_reclaimed,
-		__entry->priority,
+		__entry->nr_dirty, __entry->nr_writeback,
+		__entry->nr_congested, __entry->nr_immediate,
+		__entry->nr_activate, __entry->nr_ref_keep,
+		__entry->nr_unmap_fail, __entry->priority,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
+TRACE_EVENT(mm_vmscan_lru_shrink_active,
+
+	TP_PROTO(int nid, unsigned long nr_scanned, unsigned long nr_freed,
+		unsigned long nr_unevictable, unsigned long nr_deactivated,
+		unsigned long nr_rotated, int priority, int file),
+
+	TP_ARGS(nid, nr_scanned, nr_freed, nr_unevictable, nr_deactivated, nr_rotated, priority, file),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(unsigned long, nr_scanned)
+		__field(unsigned long, nr_freed)
+		__field(unsigned long, nr_unevictable)
+		__field(unsigned long, nr_deactivated)
+		__field(unsigned long, nr_rotated)
+		__field(int, priority)
+		__field(int, reclaim_flags)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->nr_scanned = nr_scanned;
+		__entry->nr_freed = nr_freed;
+		__entry->nr_unevictable = nr_unevictable;
+		__entry->nr_deactivated = nr_deactivated;
+		__entry->nr_rotated = nr_rotated;
+		__entry->priority = priority;
+		__entry->reclaim_flags = trace_shrink_flags(file);
+	),
+
+	TP_printk("nid=%d nr_scanned=%ld nr_freed=%ld nr_unevictable=%ld nr_deactivated=%ld nr_rotated=%ld priority=%d flags=%s",
+		__entry->nid,
+		__entry->nr_scanned, __entry->nr_freed, __entry->nr_unevictable,
+		__entry->nr_deactivated, __entry->nr_rotated,
+		__entry->priority,
+		show_reclaim_flags(__entry->reclaim_flags))
+);
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e701be6b930a..a8a103a5f7f0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2490,14 +2490,18 @@ void free_hot_cold_page(struct page *page, bool cold)
 /*
  * Free a list of 0-order pages
  */
-void free_hot_cold_page_list(struct list_head *list, bool cold)
+int free_hot_cold_page_list(struct list_head *list, bool cold)
 {
 	struct page *page, *next;
+	int ret = 0;
 
 	list_for_each_entry_safe(page, next, list, lru) {
 		trace_mm_page_free_batched(page, cold);
 		free_hot_cold_page(page, cold);
+		ret++;
 	}
+
+	return ret;
 }
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4ea6b610f20e..4d7febde9e72 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -902,6 +902,17 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
+struct reclaim_stat {
+	unsigned nr_dirty;
+	unsigned nr_unqueued_dirty;
+	unsigned nr_congested;
+	unsigned nr_writeback;
+	unsigned nr_immediate;
+	unsigned nr_activate;
+	unsigned nr_ref_keep;
+	unsigned nr_unmap_fail;
+};
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -909,22 +920,21 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct pglist_data *pgdat,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
-				      unsigned long *ret_nr_dirty,
-				      unsigned long *ret_nr_unqueued_dirty,
-				      unsigned long *ret_nr_congested,
-				      unsigned long *ret_nr_writeback,
-				      unsigned long *ret_nr_immediate,
+				      struct reclaim_stat *stat,
 				      bool force_reclaim)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
-	unsigned long nr_unqueued_dirty = 0;
-	unsigned long nr_dirty = 0;
-	unsigned long nr_congested = 0;
-	unsigned long nr_reclaimed = 0;
-	unsigned long nr_writeback = 0;
-	unsigned long nr_immediate = 0;
+	unsigned nr_unqueued_dirty = 0;
+	unsigned nr_dirty = 0;
+	unsigned nr_congested = 0;
+	unsigned nr_reclaimed = 0;
+	unsigned nr_writeback = 0;
+	unsigned nr_immediate = 0;
+	unsigned nr_activate = 0;
+	unsigned nr_ref_keep = 0;
+	unsigned nr_unmap_fail = 0;
 
 	cond_resched();
 
@@ -1063,6 +1073,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
 		case PAGEREF_KEEP:
+			nr_ref_keep++;
 			goto keep_locked;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
@@ -1100,6 +1111,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
 				(ttu_flags | TTU_BATCH_FLUSH))) {
 			case SWAP_FAIL:
+				nr_unmap_fail++;
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
@@ -1252,6 +1264,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		VM_BUG_ON_PAGE(PageActive(page), page);
 		SetPageActive(page);
 		pgactivate++;
+		nr_activate++;
 keep_locked:
 		unlock_page(page);
 keep:
@@ -1266,11 +1279,16 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
 
-	*ret_nr_dirty += nr_dirty;
-	*ret_nr_congested += nr_congested;
-	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
-	*ret_nr_writeback += nr_writeback;
-	*ret_nr_immediate += nr_immediate;
+	if (stat) {
+		stat->nr_dirty = nr_dirty;
+		stat->nr_congested = nr_congested;
+		stat->nr_unqueued_dirty = nr_unqueued_dirty;
+		stat->nr_writeback = nr_writeback;
+		stat->nr_immediate = nr_immediate;
+		stat->nr_activate = nr_activate;
+		stat->nr_ref_keep = nr_ref_keep;
+		stat->nr_unmap_fail = nr_unmap_fail;
+	}
 	return nr_reclaimed;
 }
 
@@ -1282,7 +1300,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
 	};
-	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
+	unsigned long ret;
 	struct page *page, *next;
 	LIST_HEAD(clean_pages);
 
@@ -1295,8 +1313,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	}
 
 	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
-			TTU_UNMAP|TTU_IGNORE_ACCESS,
-			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
+			TTU_UNMAP|TTU_IGNORE_ACCESS, NULL, true);
 	list_splice(&clean_pages, page_list);
 	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -1696,11 +1713,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
-	unsigned long nr_dirty = 0;
-	unsigned long nr_congested = 0;
-	unsigned long nr_unqueued_dirty = 0;
-	unsigned long nr_writeback = 0;
-	unsigned long nr_immediate = 0;
+	struct reclaim_stat stat = {};
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
@@ -1745,9 +1758,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		return 0;
 
 	nr_reclaimed = shrink_page_list(&page_list, pgdat, sc, TTU_UNMAP,
-				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
-				&nr_writeback, &nr_immediate,
-				false);
+				&stat, false);
 
 	spin_lock_irq(&pgdat->lru_lock);
 
@@ -1781,7 +1792,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * of pages under pages flagged for immediate reclaim and stall if any
 	 * are encountered in the nr_immediate check below.
 	 */
-	if (nr_writeback && nr_writeback == nr_taken)
+	if (stat.nr_writeback && stat.nr_writeback == nr_taken)
 		set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
 	/*
@@ -1793,7 +1804,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * Tag a zone as congested if all the dirty pages scanned were
 		 * backed by a congested BDI and wait_iff_congested will stall.
 		 */
-		if (nr_dirty && nr_dirty == nr_congested)
+		if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
 			set_bit(PGDAT_CONGESTED, &pgdat->flags);
 
 		/*
@@ -1802,7 +1813,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * the pgdat PGDAT_DIRTY and kswapd will start writing pages from
 		 * reclaim context.
 		 */
-		if (nr_unqueued_dirty == nr_taken)
+		if (stat.nr_unqueued_dirty == nr_taken)
 			set_bit(PGDAT_DIRTY, &pgdat->flags);
 
 		/*
@@ -1811,7 +1822,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if (nr_immediate && current_may_throttle())
+		if (stat.nr_immediate && current_may_throttle())
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 
@@ -1826,6 +1837,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
 			nr_scanned, nr_reclaimed,
+			stat.nr_dirty,  stat.nr_writeback,
+			stat.nr_congested, stat.nr_immediate,
+			stat.nr_activate, stat.nr_ref_keep, stat.nr_unmap_fail,
 			sc->priority, file);
 	return nr_reclaimed;
 }
@@ -1846,9 +1860,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
  *
  * The downside is that we have to touch page->_refcount against each page.
  * But we had to alter page->flags anyway.
+ *
+ * Returns the number of pages moved to the given lru.
  */
 
-static void move_active_pages_to_lru(struct lruvec *lruvec,
+static int move_active_pages_to_lru(struct lruvec *lruvec,
 				     struct list_head *list,
 				     struct list_head *pages_to_free,
 				     enum lru_list lru)
@@ -1857,6 +1873,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 	unsigned long pgmoved = 0;
 	struct page *page;
 	int nr_pages;
+	int nr_moved = 0;
 
 	while (!list_empty(list)) {
 		page = lru_to_page(list);
@@ -1882,11 +1899,15 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 				spin_lock_irq(&pgdat->lru_lock);
 			} else
 				list_add(&page->lru, pages_to_free);
+		} else {
+			nr_moved++;
 		}
 	}
 
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
+
+	return nr_moved;
 }
 
 static void shrink_active_list(unsigned long nr_to_scan,
@@ -1902,7 +1923,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	LIST_HEAD(l_inactive);
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
-	unsigned long nr_rotated = 0;
+	unsigned long nr_rotated = 0, nr_unevictable = 0;
+	unsigned long nr_freed, nr_deactivate, nr_activate;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
@@ -1935,6 +1957,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 
 		if (unlikely(!page_evictable(page))) {
 			putback_lru_page(page);
+			nr_unevictable++;
 			continue;
 		}
 
@@ -1980,13 +2003,16 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	 */
 	reclaim_stat->recent_rotated[file] += nr_rotated;
 
-	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
-	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
+	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
+	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
 	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&pgdat->lru_lock);
 
 	mem_cgroup_uncharge_list(&l_hold);
-	free_hot_cold_page_list(&l_hold, true);
+	nr_freed = free_hot_cold_page_list(&l_hold, true);
+	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_scanned, nr_freed,
+			nr_unevictable, nr_deactivate, nr_rotated,
+			sc->priority, file);
 }
 
 /*
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
