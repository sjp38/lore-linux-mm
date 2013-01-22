Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 2B0026B0012
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:47:15 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix 2/4] Bug fix: Fix the doc format.
Date: Tue, 22 Jan 2013 19:46:19 +0800
Message-Id: <1358855181-6160-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358855181-6160-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358855181-6160-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/page_alloc.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 00037a3..cd6f8a6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4372,7 +4372,7 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 }
 
 /**
- * sanitize_zone_movable_limit - Sanitize the zone_movable_limit array.
+ * sanitize_zone_movable_limit() - Sanitize the zone_movable_limit array.
  *
  * zone_movable_limit is initialized as 0. This function will try to get
  * the first ZONE_MOVABLE pfn of each node from movablecore_map, and
@@ -5173,9 +5173,9 @@ early_param("kernelcore", cmdline_parse_kernelcore);
 early_param("movablecore", cmdline_parse_movablecore);
 
 /**
- * insert_movablecore_map - Insert a memory range in to movablecore_map.map.
- * @start_pfn: start pfn of the range
- * @end_pfn: end pfn of the range
+ * insert_movablecore_map() - Insert a memory range in to movablecore_map.map.
+ * @start_pfn:	start pfn of the range
+ * @end_pfn:	end pfn of the range
  *
  * This function will also merge the overlapped ranges, and sort the array
  * by start_pfn in monotonic increasing order.
@@ -5236,9 +5236,9 @@ static void __init insert_movablecore_map(unsigned long start_pfn,
 }
 
 /**
- * movablecore_map_add_region - Add a memory range into movablecore_map.
- * @start: physical start address of range
- * @end: physical end address of range
+ * movablecore_map_add_region() - Add a memory range into movablecore_map.
+ * @start:	physical start address of range
+ * @end:	physical end address of range
  *
  * This function transform the physical address into pfn, and then add the
  * range into movablecore_map by calling insert_movablecore_map().
@@ -5265,8 +5265,13 @@ static void __init movablecore_map_add_region(u64 start, u64 size)
 }
 
 /*
- * movablecore_map=nn[KMG]@ss[KMG] sets the region of memory to be used as
- * movable memory.
+ * cmdline_parse_movablecore_map() - Parse boot option movablecore_map.
+ * @p:	The boot option of the following format:
+ * 	movablecore_map=nn[KMG]@ss[KMG]
+ *
+ * This option sets the memory range [ss, ss+nn) to be used as movable memory.
+ *
+ * Return: 0 on success or -EINVAL on failure.
  */
 static int __init cmdline_parse_movablecore_map(char *p)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
