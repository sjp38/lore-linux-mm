Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 68DE88D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:27:12 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/5] memcg: no uncharged pages reach page_cgroup_zoneinfo
Date: Thu,  3 Feb 2011 15:26:02 +0100
Message-Id: <1296743166-9412-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

All callsites check PCG_USED before passing pc->mem_cgroup, so the
latter is never NULL.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e071d7e..85b4b5a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -370,9 +370,6 @@ page_cgroup_zoneinfo(struct page_cgroup *pc)
 	int nid = page_cgroup_nid(pc);
 	int zid = page_cgroup_zid(pc);
 
-	if (!mem)
-		return NULL;
-
 	return mem_cgroup_zoneinfo(mem, nid, zid);
 }
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
