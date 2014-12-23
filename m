Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3181B6B0032
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 23:49:39 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so7095639pdi.16
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 20:49:38 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id cu3si27697819pbc.108.2014.12.22.20.49.35
        for <linux-mm@kvack.org>;
        Mon, 22 Dec 2014 20:49:37 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] mm/debug_pagealloc: remove obsolete Kconfig options
Date: Tue, 23 Dec 2014 13:53:57 +0900
Message-Id: <1419310437-9193-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Bolle <pebolle@tiscali.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

These are obsolete since commit e30825f1869a ("mm/debug-pagealloc:
prepare boottime configurable on/off") is merged. Remove them.

Reported-by: Paul Bolle <pebolle@tiscali.nl>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/Kconfig.debug |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 56badfc..957d3da 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -14,7 +14,6 @@ config DEBUG_PAGEALLOC
 	depends on !KMEMCHECK
 	select PAGE_EXTENSION
 	select PAGE_POISONING if !ARCH_SUPPORTS_DEBUG_PAGEALLOC
-	select PAGE_GUARD if ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	---help---
 	  Unmap pages from the kernel linear mapping after free_pages().
 	  This results in a large slowdown, but helps to find certain types
@@ -27,13 +26,5 @@ config DEBUG_PAGEALLOC
 	  that would result in incorrect warnings of memory corruption after
 	  a resume because free pages are not saved to the suspend image.
 
-config WANT_PAGE_DEBUG_FLAGS
-	bool
-
 config PAGE_POISONING
 	bool
-	select WANT_PAGE_DEBUG_FLAGS
-
-config PAGE_GUARD
-	bool
-	select WANT_PAGE_DEBUG_FLAGS
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
