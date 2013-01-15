Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 8772B6B0069
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:18:53 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rq13so99471pbb.7
        for <linux-mm@kvack.org>; Tue, 15 Jan 2013 07:18:52 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RESEND PATCH v3 2/3] mm: set zone->present_pages to number of existing pages in the zone
Date: Tue, 15 Jan 2013 23:18:16 +0800
Message-Id: <1358263097-11038-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1358263097-11038-1-git-send-email-jiang.liu@huawei.com>
References: <1358263097-11038-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now all users of "number of pages managed by the buddy system" have been
converted to use zone->managed_pages, so set zone->present_pages to what
it should be:
	present_pages = spanned_pages - absent_pages;

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fed01fd..595e655 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4565,7 +4565,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
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
