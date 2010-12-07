Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D8ED56B0092
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 10:09:59 -0500 (EST)
Received: by pwi6 with SMTP id 6so20398pwi.14
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 07:09:54 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] memcg: Remove unnecessary return
Date: Wed,  8 Dec 2010 00:09:40 +0900
Message-Id: <1291734580-19515-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/memcontrol.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f9435be..55f57e3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -821,7 +821,6 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
 		return;
 	VM_BUG_ON(list_empty(&pc->lru));
 	list_del_init(&pc->lru);
-	return;
 }
 
 void mem_cgroup_del_lru(struct page *page)
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
