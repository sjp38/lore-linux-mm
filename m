Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DB64D6B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 22:26:57 -0400 (EDT)
Date: Thu, 6 Aug 2009 10:27:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] slqb: add declaration for kmem_cache_init_late()
Message-ID: <20090806022704.GA17337@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/slqb_def.h |    2 ++
 1 file changed, 2 insertions(+)

--- linux-mm.orig/include/linux/slqb_def.h	2009-07-20 20:10:20.000000000 +0800
+++ linux-mm/include/linux/slqb_def.h	2009-08-06 10:17:05.000000000 +0800
@@ -298,4 +298,6 @@ static __always_inline void *kmalloc_nod
 }
 #endif
 
+void __init kmem_cache_init_late(void);
+
 #endif /* _LINUX_SLQB_DEF_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
