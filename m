Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id C01246B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 03:43:54 -0500 (EST)
Received: by dadv6 with SMTP id v6so3179097dad.14
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 00:43:54 -0800 (PST)
From: Geunsik Lim <geunsik.lim@gmail.com>
Subject: [PATCH] Handling of unused variable 'do-numainfo on compilation time
Date: Fri,  3 Feb 2012 17:43:47 +0900
Message-Id: <1328258627-2241-1-git-send-email-geunsik.lim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>

Actually, Usage of the variable 'do_numainfo'is not suitable for gcc compiler.
Declare the variable 'do_numainfo' if the number of NUMA nodes > 1.

Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
---
 mm/memcontrol.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 556859f..4e17ac5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -776,7 +776,10 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 	/* threshold event is triggered in finer grain than soft limit */
 	if (unlikely(mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_THRESH))) {
-		bool do_softlimit, do_numainfo;
+		bool do_softlimit;
+#if MAX_NUMNODES > 1
+                bool do_numainfo;
+#endif
 
 		do_softlimit = mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_SOFTLIMIT);
-- 
1.7.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
