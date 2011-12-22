Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id E7D946B004D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2011 14:07:58 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcg: clean up fault accounting fix
Date: Thu, 22 Dec 2011 20:07:54 +0100
Message-Id: <1324580874-8467-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Signed-off-by: Knucklehead <hannes@cmpxchg.org>
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bcba951..16add01 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -707,10 +707,10 @@ void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 		goto out;
 
 	switch (idx) {
-	case PGMAJFAULT:
+	case PGFAULT:
 		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT]);
 		break;
-	case PGFAULT:
+	case PGMAJFAULT:
 		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
 		break;
 	default:
-- 
1.7.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
