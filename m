Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 68F506B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:46:30 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mm: cma: alloc_contig_range: return early for err path
Date: Tue, 23 Oct 2012 14:45:57 +0800
Message-ID: <1350974757-27876-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, minchan@kernel.org, m.szyprowski@samsung.com, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>

If start_isolate_page_range() failed, unset_migratetype_isolate() has been
done inside it.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb90971..b0012ab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5825,7 +5825,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	ret = start_isolate_page_range(pfn_max_align_down(start),
 				       pfn_max_align_up(end), migratetype);
 	if (ret)
-		goto done;
+		return ret;
 
 	ret = __alloc_contig_migrate_range(&cc, start, end);
 	if (ret)
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
