Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 213F46B0087
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 11:34:20 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4832223pad.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 08:34:19 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/4] bootmem: remove not implemented function call, bootmem_arch_preferred_node()
Date: Tue, 13 Nov 2012 01:31:52 +0900
Message-Id: <1352737915-30906-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

There is no implementation of bootmeme_arch_preferred_node() and
call for this function will makes compile-error.
So, remove it.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 434be4a..6f62c03e 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -589,19 +589,6 @@ static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
 {
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc(size, GFP_NOWAIT);
-
-#ifdef CONFIG_HAVE_ARCH_BOOTMEM
-	{
-		bootmem_data_t *p_bdata;
-
-		p_bdata = bootmem_arch_preferred_node(bdata, size, align,
-							goal, limit);
-		if (p_bdata)
-			return alloc_bootmem_bdata(p_bdata, size, align,
-							goal, limit);
-	}
-#endif
-	return NULL;
 }
 
 static void * __init alloc_bootmem_core(unsigned long size,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
