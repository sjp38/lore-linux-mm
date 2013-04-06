Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 9B6CD6B0187
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 10:43:24 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id wz12so2461871pbc.31
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 07:43:23 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 10/41] mm/hotplug: prepare for removing num_physpages
Date: Sat,  6 Apr 2013 22:32:09 +0800
Message-Id: <1365258760-30821-11-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

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
index f3b12d70..91a73a6 100644
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
