Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 493C66B0136
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 12:04:14 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kp14so1423933pab.22
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 09:04:13 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v3, part4 38/39] mm/hotplug: prepare for removing num_physpages
Date: Tue, 26 Mar 2013 23:54:57 +0800
Message-Id: <1364313298-17336-39-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
References: <1364313298-17336-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Prepare for removing num_physpages.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org
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
