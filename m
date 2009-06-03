Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2063B5F0001
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:47:19 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <20090603846.816684333@firstfloor.org>
In-Reply-To: <20090603846.816684333@firstfloor.org>
Subject: [PATCH] [14/16] HWPOISON: FOR TESTING: Enable memory failure code unconditionally
Message-Id: <20090603184649.7D5581D0282@basil.firstfloor.org>
Date: Wed,  3 Jun 2009 20:46:49 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
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
--- linux.orig/mm/Kconfig	2009-06-03 20:30:32.000000000 +0200
+++ linux/mm/Kconfig	2009-06-03 20:39:48.000000000 +0200
@@ -222,6 +222,8 @@
 
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
