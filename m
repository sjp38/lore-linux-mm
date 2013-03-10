Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 46B2D6B0044
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 04:09:21 -0400 (EDT)
Received: by mail-da0-f48.google.com with SMTP id w4so485286dam.21
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:09:20 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part2 06/10] mm/MIPS: use free_highmem_page() to free highmem pages into buddy system
Date: Sun, 10 Mar 2013 16:01:06 +0800
Message-Id: <1362902470-25787-7-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, David Daney <david.daney@cavium.com>, Cong Wang <amwang@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-mips@linux-mips.org

Use helper function free_highmem_page() to free highmem pages into
the buddy system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: David Daney <david.daney@cavium.com>
Cc: Cong Wang <amwang@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-mips@linux-mips.org
Cc: linux-kernel@vger.kernel.org
---
 arch/mips/mm/init.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 60f7c61..3d0346d 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -393,12 +393,8 @@ void __init mem_init(void)
 			SetPageReserved(page);
 			continue;
 		}
-		ClearPageReserved(page);
-		init_page_count(page);
-		__free_page(page);
-		totalhigh_pages++;
+		free_highmem_page(page);
 	}
-	totalram_pages += totalhigh_pages;
 	num_physpages += totalhigh_pages;
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
