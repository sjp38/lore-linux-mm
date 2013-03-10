Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id DC2F56B005A
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 04:09:30 -0400 (EDT)
Received: by mail-da0-f50.google.com with SMTP id t1so135241dae.9
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:09:30 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part2 07/10] mm/PPC: use free_highmem_page() to free highmem pages into buddy system
Date: Sun, 10 Mar 2013 16:01:07 +0800
Message-Id: <1362902470-25787-8-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Alexander Graf <agraf@suse.de>, "Suzuki K. Poulose" <suzuki@in.ibm.com>, linuxppc-dev@lists.ozlabs.org

Use helper function free_highmem_page() to free highmem pages into
the buddy system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Graf <agraf@suse.de>
Cc: "Suzuki K. Poulose" <suzuki@in.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
---
 arch/powerpc/mm/mem.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index c756713..68f51d0 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -352,13 +352,9 @@ void __init mem_init(void)
 			struct page *page = pfn_to_page(pfn);
 			if (memblock_is_reserved(paddr))
 				continue;
-			ClearPageReserved(page);
-			init_page_count(page);
-			__free_page(page);
-			totalhigh_pages++;
+			free_higmem_page(page);
 			reservedpages--;
 		}
-		totalram_pages += totalhigh_pages;
 		printk(KERN_DEBUG "High memory: %luk\n",
 		       totalhigh_pages << (PAGE_SHIFT-10));
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
