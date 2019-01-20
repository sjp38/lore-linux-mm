Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40D978E0002
	for <linux-mm@kvack.org>; Sat, 19 Jan 2019 21:43:12 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l76so10743768pfg.1
        for <linux-mm@kvack.org>; Sat, 19 Jan 2019 18:43:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 88sor12417000plb.63.2019.01.19.18.43.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 19 Jan 2019 18:43:11 -0800 (PST)
From: Changbin Du <changbin.du@gmail.com>
Subject: [PATCH] mm/page_owner: move config option to mm/Kconfig.debug
Date: Sun, 20 Jan 2019 10:42:54 +0800
Message-Id: <20190120024254.6270-1-changbin.du@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yamada.masahiro@socionext.com, mingo@kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Changbin Du <changbin.du@gmail.com>

Move the PAGE_OWNER option from submenu "Compile-time checks and compiler
options" to dedicated submenu "Memory Debugging".

Signed-off-by: Changbin Du <changbin.du@gmail.com>
---
 lib/Kconfig.debug | 17 -----------------
 mm/Kconfig.debug  | 17 +++++++++++++++++
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index d4df5b24d75e..e43cfdc86fd6 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -266,23 +266,6 @@ config UNUSED_SYMBOLS
 	  you really need it, and what the merge plan to the mainline kernel for
 	  your module is.
 
-config PAGE_OWNER
-	bool "Track page owner"
-	depends on DEBUG_KERNEL && STACKTRACE_SUPPORT
-	select DEBUG_FS
-	select STACKTRACE
-	select STACKDEPOT
-	select PAGE_EXTENSION
-	help
-	  This keeps track of what call chain is the owner of a page, may
-	  help to find bare alloc_page(s) leaks. Even if you include this
-	  feature on your build, it is disabled in default. You should pass
-	  "page_owner=on" to boot parameter in order to enable it. Eats
-	  a fair amount of memory if enabled. See tools/vm/page_owner_sort.c
-	  for user-space helper.
-
-	  If unsure, say N.
-
 config DEBUG_FS
 	bool "Debug Filesystem"
 	help
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 9a7b8b049d04..e3df921208c0 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -39,6 +39,23 @@ config DEBUG_PAGEALLOC_ENABLE_DEFAULT
 	  Enable debug page memory allocations by default? This value
 	  can be overridden by debug_pagealloc=off|on.
 
+config PAGE_OWNER
+	bool "Track page owner"
+	depends on DEBUG_KERNEL && STACKTRACE_SUPPORT
+	select DEBUG_FS
+	select STACKTRACE
+	select STACKDEPOT
+	select PAGE_EXTENSION
+	help
+	  This keeps track of what call chain is the owner of a page, may
+	  help to find bare alloc_page(s) leaks. Even if you include this
+	  feature on your build, it is disabled in default. You should pass
+	  "page_owner=on" to boot parameter in order to enable it. Eats
+	  a fair amount of memory if enabled. See tools/vm/page_owner_sort.c
+	  for user-space helper.
+
+	  If unsure, say N.
+
 config PAGE_POISONING
 	bool "Poison pages after freeing"
 	select PAGE_POISONING_NO_SANITY if HIBERNATION
-- 
2.17.1
