Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D37F96B004F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 16:07:04 -0400 (EDT)
Subject: [PATCH] bootmem.c: Avoid c90 declaration warning
From: Joe Perches <joe@perches.com>
Content-Type: text/plain
Date: Thu, 18 Jun 2009 13:07:13 -0700
Message-Id: <1245355633.29927.16.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 282df0a..09d9c98 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -536,11 +536,13 @@ static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
 		return kzalloc(size, GFP_NOWAIT);
 
 #ifdef CONFIG_HAVE_ARCH_BOOTMEM
+	{
 	bootmem_data_t *p_bdata;
 
 	p_bdata = bootmem_arch_preferred_node(bdata, size, align, goal, limit);
 	if (p_bdata)
 		return alloc_bootmem_core(p_bdata, size, align, goal, limit);
+	}
 #endif
 	return NULL;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
