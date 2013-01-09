Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id BBFF46B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 05:00:08 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v6 11/15] memory-hotplug: Integrated __remove_section() of CONFIG_SPARSEMEM_VMEMMAP.
Date: Wed, 9 Jan 2013 17:32:35 +0800
Message-Id: <1357723959-5416-12-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Currently __remove_section for SPARSEMEM_VMEMMAP does nothing. But even if
we use SPARSEMEM_VMEMMAP, we can unregister the memory_section.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/memory_hotplug.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 674e791..b20c4c7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -430,16 +430,6 @@ static int __meminit __add_section(int nid, struct zone *zone,
 	return register_new_memory(nid, __pfn_to_section(phys_start_pfn));
 }
 
-#ifdef CONFIG_SPARSEMEM_VMEMMAP
-static int __remove_section(struct zone *zone, struct mem_section *ms)
-{
-	/*
-	 * XXX: Freeing memmap with vmemmap is not implement yet.
-	 *      This should be removed later.
-	 */
-	return -EBUSY;
-}
-#else
 static int __remove_section(struct zone *zone, struct mem_section *ms)
 {
 	int ret = -EINVAL;
@@ -454,7 +444,6 @@ static int __remove_section(struct zone *zone, struct mem_section *ms)
 	sparse_remove_one_section(zone, ms);
 	return 0;
 }
-#endif
 
 /*
  * Reasonably generic function for adding memory.  It is
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
