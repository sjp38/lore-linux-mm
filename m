Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id B58746B0036
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 01:50:35 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so1996722pbc.26
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 22:50:35 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id sg3si756449pbb.253.2013.12.12.22.50.33
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 22:50:34 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 1/6] mm/migrate: add comment about permanent failure path
Date: Fri, 13 Dec 2013 15:53:26 +0900
Message-Id: <1386917611-11319-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386917611-11319-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Let's add a comment about where the failed page goes to, which makes
code more readable.

Acked-by: Christoph Lameter <cl@linux.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/migrate.c b/mm/migrate.c
index 3747fcd..c6ac87a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1123,7 +1123,12 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 				nr_succeeded++;
 				break;
 			default:
-				/* Permanent failure */
+				/*
+				 * Permanent failure (-EBUSY, -ENOSYS, etc.):
+				 * unlike -EAGAIN case, the failed page is
+				 * removed from migration page list and not
+				 * retried in the next outer loop.
+				 */
 				nr_failed++;
 				break;
 			}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
