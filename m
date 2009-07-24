Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CE3B26B004D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 23:31:23 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: [PATCH] trivial: improve help text for mm debug config options
Date: Fri, 24 Jul 2009 05:31:17 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200907240531.18676.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Jiri Kosina <trivial@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Improve the help text for PAGE_POISONING.
Also fix some typos and improve consistency within the file.

Signed-of-by: Frans Pop <elendil@planet.nl>

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index aa99fd1..af7cfb4 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -6,7 +6,7 @@ config DEBUG_PAGEALLOC
 	---help---
 	  Unmap pages from the kernel linear mapping after free_pages().
 	  This results in a large slowdown, but helps to find certain types
-	  of memory corruptions.
+	  of memory corruption.
 
 config WANT_PAGE_DEBUG_FLAGS
 	bool
@@ -17,11 +17,11 @@ config PAGE_POISONING
 	depends on !HIBERNATION
 	select DEBUG_PAGEALLOC
 	select WANT_PAGE_DEBUG_FLAGS
-	help
+	---help---
 	   Fill the pages with poison patterns after free_pages() and verify
 	   the patterns before alloc_pages(). This results in a large slowdown,
-	   but helps to find certain types of memory corruptions.
+	   but helps to find certain types of memory corruption.
 
-	   This option cannot enalbe with hibernation. Otherwise, it will get
-	   wrong messages for memory corruption because the free pages are not
-	   saved to the suspend image.
+	   This option cannot be enabled in combination with hibernation as
+	   that would result in incorrect warnings of memory corruption after
+	   a resume because free pages are not saved to the suspend image.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
