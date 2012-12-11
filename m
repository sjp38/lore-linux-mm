Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 68F556B0087
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 03:12:36 -0500 (EST)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH] mm/bootmem.c: remove unused wrapper function reserve_bootmem_generic()
Date: Tue, 11 Dec 2012 16:12:03 +0800
Message-Id: <1355213523-15698-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, yinghai@kernel.org, hpa@zytor.com
Cc: davem@davemloft.net, hannes@cmpxchg.org, eric.dumazet@gmail.com, tj@kernel.org, shangw@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lin Feng <linfeng@cn.fujitsu.com>

Wrapper fucntion reserve_bootmem_generic() currently have no caller,
so clean it up.

Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 include/linux/bootmem.h |    3 ---
 mm/bootmem.c            |    6 ------
 2 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 6d6795d..bfc742c 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -137,9 +137,6 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 #define alloc_bootmem_low_pages_node(pgdat, x) \
 	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
 
-extern int reserve_bootmem_generic(unsigned long addr, unsigned long size,
-				   int flags);
-
 #ifdef CONFIG_HAVE_ARCH_ALLOC_REMAP
 extern void *alloc_remap(int nid, unsigned long size);
 #else
diff --git a/mm/bootmem.c b/mm/bootmem.c
index f468185..2812730 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -439,12 +439,6 @@ int __init reserve_bootmem(unsigned long addr, unsigned long size,
 	return mark_bootmem(start, end, 1, flags);
 }
 
-int __weak __init reserve_bootmem_generic(unsigned long phys, unsigned long len,
-				   int flags)
-{
-	return reserve_bootmem(phys, len, flags);
-}
-
 static unsigned long __init align_idx(struct bootmem_data *bdata,
 				      unsigned long idx, unsigned long step)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
