Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 2E8A96B0033
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 21:22:13 -0400 (EDT)
Message-ID: <521FF39E.3040700@huawei.com>
Date: Fri, 30 Aug 2013 09:21:34 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/4] mm/vmalloc: use NUMA_NO_NODE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Use more appropriate "if (node == NUMA_NO_NODE)" instead of "if (node < 0)"

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/vmalloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 13a5495..f5483f8 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1582,7 +1582,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		struct page *page;
 		gfp_t tmp_mask = gfp_mask | __GFP_NOWARN;
 
-		if (node < 0)
+		if (node == NUMA_NO_NODE)
 			page = alloc_page(tmp_mask);
 		else
 			page = alloc_pages_node(node, tmp_mask, order);
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
