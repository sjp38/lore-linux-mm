Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 34D6F5F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 08:56:03 -0500 (EST)
Date: Tue, 3 Feb 2009 14:55:59 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/2] slqb: fix small zero size alloc bug
Message-ID: <20090203135559.GA8723@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Fix a problem where SLQB did not correctly return ZERO_SIZE_PTR for a
zero sized allocation.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 include/linux/slqb_def.h |    2 +-
 mm/slqb.c                |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/slqb_def.h
===================================================================
--- linux-2.6.orig/include/linux/slqb_def.h
+++ linux-2.6/include/linux/slqb_def.h
@@ -237,7 +237,7 @@ static __always_inline struct kmem_cache
 
 	index = kmalloc_index(size);
 	if (unlikely(index == 0))
-		return NULL;
+		return ZERO_SIZE_PTR;
 
 	if (likely(!(flags & SLQB_DMA)))
 		return &kmalloc_caches[index];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
