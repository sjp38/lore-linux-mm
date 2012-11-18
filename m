Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 1A2BC6B004D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 11:09:53 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3069609pad.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 08:09:52 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFT PATCH v1 3/5] mm: set zone->present_pages to number of existing pages in the zone
Date: Mon, 19 Nov 2012 00:07:28 +0800
Message-Id: <1353254850-27336-4-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1353254850-27336-1-git-send-email-jiang.liu@huawei.com>
References: <20121115112454.e582a033.akpm@linux-foundation.org>
 <1353254850-27336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now all users using "number of pages managed by the buddy system" have
been converted to use zone->managed_pages, so set zone->present_pages
to what it really should be:
	present_pages = spanned_pages - absent_pages;

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fe1cf48..5b327d7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4494,7 +4494,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		nr_all_pages += freesize;
 
 		zone->spanned_pages = size;
-		zone->present_pages = freesize;
+		zone->present_pages = realsize;
 		/*
 		 * Set an approximate value for lowmem here, it will be adjusted
 		 * when the bootmem allocator frees pages into the buddy system.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
