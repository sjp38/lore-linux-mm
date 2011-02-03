Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 31DF58D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:11:19 -0500 (EST)
Date: Thu, 3 Feb 2011 15:11:10 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] memcg: remove impossible conditional when committing
Message-ID: <20110203141110.GF2286@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

No callsite ever passes a NULL pointer for a struct mem_cgroup * to
the committing function.  There is no need to check for it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 031ff07..a145c9e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2092,10 +2092,6 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
 {
 	int nr_pages = page_size >> PAGE_SHIFT;
 
-	/* try_charge() can return NULL to *memcg, taking care of it. */
-	if (!mem)
-		return;
-
 	lock_page_cgroup(pc);
 	if (unlikely(PageCgroupUsed(pc))) {
 		unlock_page_cgroup(pc);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
