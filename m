Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7797D6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 04:45:38 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1A9jZqi018950
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 18:45:36 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C8BE745DE53
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 18:45:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A387C45DE57
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 18:45:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A0A61DB8040
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 18:45:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B76121DB8064
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 18:45:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] memcg: remove mem_cgroup_calc_mapped_ratio()
Message-Id: <20090210184249.6FCD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 18:45:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Currently, mem_cgroup_calc_mapped_ratio() is unused at all.
it can be removed and KAMEZAWA-san suggested it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
---
 mm/memcontrol.c |   17 -----------------
 1 file changed, 17 deletions(-)

Index: b/mm/memcontrol.c
===================================================================
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -445,23 +445,6 @@ int task_in_mem_cgroup(struct task_struc
 	return ret;
 }
 
-/*
- * Calculate mapped_ratio under memory controller. This will be used in
- * vmscan.c for deteremining we have to reclaim mapped pages.
- */
-int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
-{
-	long total, rss;
-
-	/*
-	 * usage is recorded in bytes. But, here, we assume the number of
-	 * physical pages can be represented by "long" on any arch.
-	 */
-	total = (long) (mem->res.usage >> PAGE_SHIFT) + 1L;
-	rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
-	return (int)((rss * 100L) / total);
-}
-
 static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
 {
 	unsigned long active;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
