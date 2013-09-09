Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 449446B0034
	for <linux-mm@kvack.org>; Sun,  8 Sep 2013 23:28:52 -0400 (EDT)
Message-ID: <522D4038.7010609@huawei.com>
Date: Mon, 9 Sep 2013 11:27:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] mm/hotplug: rename the function is_memblock_offlined_cb()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

Function is_memblock_offlined() return 1 means memory block is offlined,
but is_memblock_offlined_cb() return 1 means memory block is not offlined, 
this will confuse somebody, so rename the function.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Acked-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/memory_hotplug.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ca1dd3a..85f80b7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1657,7 +1657,7 @@ int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-static int is_memblock_offlined_cb(struct memory_block *mem, void *arg)
+static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
 {
 	int ret = !is_memblock_offlined(mem);
 
@@ -1794,7 +1794,7 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 	 * if this is not the case.
 	 */
 	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
-				is_memblock_offlined_cb);
+				check_memblock_offlined_cb);
 	if (ret) {
 		unlock_memory_hotplug();
 		BUG();
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
