Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 1AC176B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 07:45:34 -0500 (EST)
Date: Fri, 27 Jan 2012 10:44:06 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [resubmit] Re: [PATCH] tracing: adjust shrink_slab beginning
 trace event name
Message-ID: <20120127124405.GA2092@x61.redhat.com>
References: <20111223141619.GA19720@x61.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111223141619.GA19720@x61.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

While reviewing vmscan tracing events, I realized all functions which establish paired tracepoints (one at the beginning and another at the end of the function block) were following this naming pattern:
  <tracepoint-name>_begin
  <tarcepoint-name>_end

However, the 'beginning' tracing event for shrink_slab() did not follow the aforementioned naming pattern. This patch renames that trace event to adjust this naming inconsistency.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/trace/events/vmscan.h |    2 +-
 mm/vmscan.c                   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index f64560e..595a6f0 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -179,7 +179,7 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_re
        TP_ARGS(nr_reclaimed)
 );
 
-TRACE_EVENT(mm_shrink_slab_start,
+TRACE_EVENT(mm_shrink_slab_begin,
        TP_PROTO(struct shrinker *shr, struct shrink_control *sc,
                long nr_objects_to_shrink, unsigned long pgs_scanned,
                unsigned long lru_pgs, unsigned long cache_items,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c52b235..84f4fd2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -325,7 +325,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
                if (total_scan > max_pass * 2)
                        total_scan = max_pass * 2;
 
-               trace_mm_shrink_slab_start(shrinker, shrink, nr,
+               trace_mm_shrink_slab_begin(shrinker, shrink, nr,
                                        nr_pages_scanned, lru_pages,
                                        max_pass, delta, total_scan);
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
