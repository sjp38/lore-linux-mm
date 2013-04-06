Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E4B2F6B015E
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 09:56:52 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id 10so2441456pdi.29
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 06:56:52 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 08/15] mm: fix some trivial typos in comments
Date: Sat,  6 Apr 2013 21:55:02 +0800
Message-Id: <1365256509-29024-9-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
References: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>

Fix some trivial typos in comments.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/memory_hotplug.c |    2 +-
 mm/page_alloc.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 57decb2..a5b8fde 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -309,7 +309,7 @@ static int __meminit move_pfn_range_left(struct zone *z1, struct zone *z2,
 	/* can't move pfns which are higher than @z2 */
 	if (end_pfn > zone_end_pfn(z2))
 		goto out_fail;
-	/* the move out part mast at the left most of @z2 */
+	/* the move out part must at the left most of @z2 */
 	if (start_pfn > z2->zone_start_pfn)
 		goto out_fail;
 	/* must included/overlap */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6bd697c..c3c3eda 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2863,7 +2863,7 @@ EXPORT_SYMBOL(free_pages_exact);
  * nr_free_zone_pages() counts the number of counts pages which are beyond the
  * high watermark within all zones at or below a given zone index.  For each
  * zone, the number of pages is calculated as:
- *     present_pages - high_pages
+ *     managed_pages - high_pages
  */
 static unsigned long nr_free_zone_pages(int offset)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
