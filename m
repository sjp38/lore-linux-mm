Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id EE5176B002E
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 10:02:13 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so4554371pbc.10
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 07:02:12 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v1 23/33] mm/um: use common help functions to free reserved pages
Date: Tue,  5 Mar 2013 22:55:06 +0800
Message-Id: <1362495317-32682-24-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jeff Dike <jdike@addtoit.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Jeff Dike <jdike@addtoit.com>
---
 arch/um/kernel/mem.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 5abcbfb..d5ac802 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -254,15 +254,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	if (start < end)
-		printk(KERN_INFO "Freeing initrd memory: %ldk freed\n",
-		       (end - start) >> 10);
-	for (; start < end; start += PAGE_SIZE) {
-		ClearPageReserved(virt_to_page(start));
-		init_page_count(virt_to_page(start));
-		free_page(start);
-		totalram_pages++;
-	}
+	free_reserved_area(start, end, 0, "initrd");
 }
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
