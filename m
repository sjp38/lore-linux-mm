Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 11B046B0034
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 04:35:19 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 2/5] mm, page_alloc: introduce alloc_pages_exact_node_multiple()
Date: Wed,  3 Jul 2013 17:34:17 +0900
Message-Id: <1372840460-5571-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 8bfa87b..f8cde28 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -327,6 +327,16 @@ static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
+static inline struct page *alloc_pages_exact_node_multiple(int nid,
+		gfp_t gfp_mask, unsigned long *nr_pages, struct page **pages)
+{
+	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
+
+	return __alloc_pages_nodemask(gfp_mask, 0,
+				node_zonelist(nid, gfp_mask), NULL,
+				nr_pages, pages);
+}
+
 #ifdef CONFIG_NUMA
 extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
