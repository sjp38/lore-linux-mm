Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A2D326B006E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:19:04 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id bg2so159709pad.18
        for <linux-mm@kvack.org>; Tue, 15 Jan 2013 07:19:03 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RESEND PATCH v3 3/3] mm: increase totalram_pages when free pages allocated by bootmem allocator
Date: Tue, 15 Jan 2013 23:18:17 +0800
Message-Id: <1358263097-11038-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1358263097-11038-1-git-send-email-jiang.liu@huawei.com>
References: <1358263097-11038-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Function put_page_bootmem() is used to free pages allocated by bootmem
allocator, so it should increase totalram_pages when freeing pages into
the buddy system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/memory_hotplug.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d04ed87..b52df74 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -124,6 +124,7 @@ void __ref put_page_bootmem(struct page *page)
 		mutex_lock(&ppb_lock);
 		__free_pages_bootmem(page, 0);
 		mutex_unlock(&ppb_lock);
+		totalram_pages++;
 	}
 
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
