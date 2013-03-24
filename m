Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 939F06B00F0
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 03:43:02 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id wp1so546772pac.19
        for <linux-mm@kvack.org>; Sun, 24 Mar 2013 00:43:01 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2, part4 38/39] mm/hotplug: prepare for removing num_physpages
Date: Sun, 24 Mar 2013 15:40:38 +0800
Message-Id: <1364110839-8172-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364110839-8172-1-git-send-email-jiang.liu@huawei.com>
References: <1364110839-8172-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Prepare for removing num_physpages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/memory_hotplug.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 97454b3..9b1b494 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -751,10 +751,6 @@ EXPORT_SYMBOL_GPL(restore_online_page_callback);
 
 void __online_page_set_limits(struct page *page)
 {
-	unsigned long pfn = page_to_pfn(page);
-
-	if (pfn >= num_physpages)
-		num_physpages = pfn + 1;
 }
 EXPORT_SYMBOL_GPL(__online_page_set_limits);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
