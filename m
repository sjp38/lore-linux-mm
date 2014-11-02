Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 21F3D6B010C
	for <linux-mm@kvack.org>; Sat,  1 Nov 2014 23:14:29 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id z12so8795763wgg.23
        for <linux-mm@kvack.org>; Sat, 01 Nov 2014 20:14:28 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dj10si3544794wib.59.2014.11.01.20.14.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Nov 2014 20:14:28 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: remove stale page_cgroup_lock comment
Date: Sat,  1 Nov 2014 23:14:20 -0400
Message-Id: <1414898060-4658-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

There is no cgroup-specific page lock anymore.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 38f0647a2f12..d20928597a07 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2467,10 +2467,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 	int isolated;
 
 	VM_BUG_ON_PAGE(pc->mem_cgroup, page);
-	/*
-	 * we don't need page_cgroup_lock about tail pages, becase they are not
-	 * accessed by any other context at this point.
-	 */
 
 	/*
 	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
