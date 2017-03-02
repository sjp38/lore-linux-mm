Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A38B06B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:39:31 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d18so82157269pgh.2
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:39:31 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r69si6626083pfk.242.2017.03.01.22.39.29
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 22:39:30 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 02/11] mm: remove unncessary ret in page_referenced
Date: Thu,  2 Mar 2017 15:39:16 +0900
Message-Id: <1488436765-32350-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1488436765-32350-1-git-send-email-minchan@kernel.org>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

Anyone doesn't use ret variable. Remove it.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/rmap.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index bb45712..8076347 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -805,7 +805,6 @@ int page_referenced(struct page *page,
 		    struct mem_cgroup *memcg,
 		    unsigned long *vm_flags)
 {
-	int ret;
 	int we_locked = 0;
 	struct page_referenced_arg pra = {
 		.mapcount = total_mapcount(page),
@@ -839,7 +838,7 @@ int page_referenced(struct page *page,
 		rwc.invalid_vma = invalid_page_referenced_vma;
 	}
 
-	ret = rmap_walk(page, &rwc);
+	rmap_walk(page, &rwc);
 	*vm_flags = pra.vm_flags;
 
 	if (we_locked)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
