Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id A950E6B004D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 22:00:25 -0500 (EST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH 1/6] memcg: fix unused variable warning
Date: Sat, 24 Dec 2011 05:00:14 +0200
Message-Id: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

From: "Kirill A. Shutemov" <kirill@shutemov.name>

mm/memcontrol.c: In function a??memcg_check_eventsa??:
mm/memcontrol.c:784:22: warning: unused variable a??do_numainfoa?? [-Wunused-variable]

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d643bd6..a5e92bd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -781,14 +781,15 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 	/* threshold event is triggered in finer grain than soft limit */
 	if (unlikely(mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_THRESH))) {
-		bool do_softlimit, do_numainfo;
+		bool do_softlimit;
 
-		do_softlimit = mem_cgroup_event_ratelimit(memcg,
-						MEM_CGROUP_TARGET_SOFTLIMIT);
 #if MAX_NUMNODES > 1
+		bool do_numainfo;
 		do_numainfo = mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_NUMAINFO);
 #endif
+		do_softlimit = mem_cgroup_event_ratelimit(memcg,
+						MEM_CGROUP_TARGET_SOFTLIMIT);
 		preempt_enable();
 
 		mem_cgroup_threshold(memcg);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
