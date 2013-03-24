Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A99CA6B00E8
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:42:30 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so2138597pde.3
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:42:29 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 34/39] mm/um: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:40:34 +0800
Message-Id: <1364110839-8172-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, user-mode-linux-devel@lists.sourceforge.net

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: user-mode-linux-devel@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org
---
 arch/um/kernel/mem.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index a7dc6c1..819008f 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -70,10 +70,8 @@ void __init mem_init(void)
 #ifdef CONFIG_HIGHMEM
 	setup_highmem(end_iomem, highmem);
 #endif
-	num_physpages = totalram_pages;
 	max_pfn = totalram_pages;
-	printk(KERN_INFO "Memory: %luk available\n",
-	       nr_free_pages() << (PAGE_SHIFT-10));
+	mem_init_print_info(NULL);
 	kmalloc_ok = 1;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
