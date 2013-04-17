Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 89A9F6B006C
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 03:16:29 -0400 (EDT)
From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH] mm: fix build warning about kernel_physical_mapping_remove()
Date: Wed, 17 Apr 2013 15:15:58 +0800
Message-ID: <1366182958-21892-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Yijing Wang <wangyijing@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

If CONFIG_MEMORY_HOTREMOVE is not set, a build warning about
"warning: a??kernel_physical_mapping_removea?? defined but not used"
report.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>
---
 arch/x86/mm/init_64.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 474e28f..dafdeb2 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1019,6 +1019,7 @@ void __ref vmemmap_free(struct page *memmap, unsigned long nr_pages)
 	remove_pagetable(start, end, false);
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
 static void __meminit
 kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 {
@@ -1028,7 +1029,6 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	remove_pagetable(start, end, true);
 }
 
-#ifdef CONFIG_MEMORY_HOTREMOVE
 int __ref arch_remove_memory(u64 start, u64 size)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
