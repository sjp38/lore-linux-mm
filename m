Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id B099D6B0098
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:33:48 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id xa12so2650492pbc.36
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:33:47 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 29/29] mm,kexec: use common help functions to free reserved pages
Date: Sun, 10 Mar 2013 14:27:12 +0800
Message-Id: <1362896833-21104-30-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>

Use common help functions to free reserved pages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Eric Biederman <ebiederm@xmission.com>
---
 kernel/kexec.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/kernel/kexec.c b/kernel/kexec.c
index bddd3d7..be95397 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -1118,12 +1118,8 @@ void __weak crash_free_reserved_phys_range(unsigned long begin,
 {
 	unsigned long addr;
 
-	for (addr = begin; addr < end; addr += PAGE_SIZE) {
-		ClearPageReserved(pfn_to_page(addr >> PAGE_SHIFT));
-		init_page_count(pfn_to_page(addr >> PAGE_SHIFT));
-		free_page((unsigned long)__va(addr));
-		totalram_pages++;
-	}
+	for (addr = begin; addr < end; addr += PAGE_SIZE)
+		free_reserved_page(pfn_to_page(addr >> PAGE_SHIFT));
 }
 
 int crash_shrink_memory(unsigned long new_size)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
