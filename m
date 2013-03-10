Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id A0DCB6B0068
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 04:09:12 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id rr4so2677937pbb.13
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:09:11 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part2 05/10] mm/microblaze: use free_highmem_page() to free highmem pages into buddy system
Date: Sun, 10 Mar 2013 16:01:05 +0800
Message-Id: <1362902470-25787-6-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Simek <monstr@monstr.eu>, microblaze-uclinux@itee.uq.edu.au

Use helper function free_highmem_page() to free highmem pages into
the buddy system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Michal Simek <monstr@monstr.eu>
Cc: microblaze-uclinux@itee.uq.edu.au
Cc: linux-kernel@vger.kernel.org
---
 arch/microblaze/mm/init.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 9be5302..4ec137d 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -82,13 +82,9 @@ static unsigned long highmem_setup(void)
 		/* FIXME not sure about */
 		if (memblock_is_reserved(pfn << PAGE_SHIFT))
 			continue;
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
+		free_highmem_page(page);
 		reservedpages++;
 	}
-	totalram_pages += totalhigh_pages;
 	pr_info("High memory: %luk\n",
 					totalhigh_pages << (PAGE_SHIFT-10));
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
