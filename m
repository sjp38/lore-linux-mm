Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9B56B0087
	for <linux-mm@kvack.org>; Fri, 29 May 2009 17:35:27 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200905291135.124267638@firstfloor.org>
In-Reply-To: <200905291135.124267638@firstfloor.org>
Subject: [PATCH] [14/16] HWPOISON: FOR TESTING: Enable memory failure code unconditionally
Message-Id: <20090529213540.540A81D028F@basil.firstfloor.org>
Date: Fri, 29 May 2009 23:35:40 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


Normally the memory-failure.c code is enabled by the architecture, but
for easier testing independent of architecture changes enable it unconditionally.

This should not be merged into mainline.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/Kconfig |    2 ++
 1 file changed, 2 insertions(+)

Index: linux/mm/Kconfig
===================================================================
--- linux.orig/mm/Kconfig	2009-05-29 23:32:11.000000000 +0200
+++ linux/mm/Kconfig	2009-05-29 23:33:28.000000000 +0200
@@ -228,6 +228,8 @@
 
 config MEMORY_FAILURE
 	bool
+	default y
+	depends on MMU
 
 config NOMMU_INITIAL_TRIM_EXCESS
 	int "Turn on mmap() excess space trimming before booting"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
