Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id AC2556B00D2
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:34:41 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id wy12so3656185pbc.21
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:34:40 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 34/39] mm/um: prepare for removing num_physpages and simplify mem_init()
Date: Sun, 24 Mar 2013 15:25:25 +0800
Message-Id: <1364109934-7851-60-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
References: <1364109934-7851-1-git-send-email-jiang.liu@huawei.com>
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
