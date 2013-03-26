Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 948A46B010B
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 11:59:29 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id jh10so1050175pab.10
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 08:59:28 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v3, part4 15/39] mm/c6x: prepare for removing num_physpages and simplify mem_init()
Date: Tue, 26 Mar 2013 23:54:34 +0800
Message-Id: <1364313298-17336-16-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Aurelien Jacquiot <a-jacquiot@ti.com>, linux-c6x-dev@linux-c6x.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
Cc: linux-c6x-dev@linux-c6x.org
Cc: linux-kernel@vger.kernel.org
---
Hi all,
	Sorry for my mistake that my previous patch series has been screwed up.
So I regenerate a third version and also set up a git tree at:
	git://github.com/jiangliu/linux.git mem_init
	Any help to review and test are welcomed!

	Regards!
	Gerry
---
 arch/c6x/mm/init.c |   11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index 2c51474..066f75c 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -57,21 +57,12 @@ void __init paging_init(void)
 
 void __init mem_init(void)
 {
-	int codek, datak;
-	unsigned long tmp;
-	unsigned long len = memory_end - memory_start;
-
 	high_memory = (void *)(memory_end & PAGE_MASK);
 
 	/* this will put all memory onto the freelists */
 	free_all_bootmem();
 
-	codek = (_etext - _stext) >> 10;
-	datak = (_end - _sdata) >> 10;
-
-	tmp = nr_free_pages() << PAGE_SHIFT;
-	printk(KERN_INFO "Memory: %luk/%luk RAM (%dk kernel code, %dk data)\n",
-	       tmp >> 10, len >> 10, codek, datak);
+	mem_init_print_info(NULL);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
