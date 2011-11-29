Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 195126B005A
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 05:52:39 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/7] mm: oom_kill: remove memcg argument from oom_kill_task()
Date: Tue, 29 Nov 2011 11:51:59 +0100
Message-Id: <1322563925-1667-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1322563925-1667-1-git-send-email-hannes@cmpxchg.org>
References: <1322563925-1667-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <jweiner@redhat.com>

The memcg argument of oom_kill_task() hasn't been used since 341aea2
'oom-kill: remove boost_dying_task_prio()'.  Kill it.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 471dedb..fd9e303 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -423,7 +423,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
-static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
+static int oom_kill_task(struct task_struct *p)
 {
 	struct task_struct *q;
 	struct mm_struct *mm;
@@ -522,7 +522,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		}
 	} while_each_thread(p, t);
 
-	return oom_kill_task(victim, mem);
+	return oom_kill_task(victim);
 }
 
 /*
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
