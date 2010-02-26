Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C3D9B6B007D
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:04 -0500 (EST)
Message-Id: <20100226200858.760087912@redhat.com>
Date: Fri, 26 Feb 2010 21:04:34 +0100
From: aarcange@redhat.com
Subject: [patch 01/35] define MADV_HUGEPAGE
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=madv_hugepage_define
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Define MADV_HUGEPAGE.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/alpha/include/asm/mman.h     |    2 ++
 arch/mips/include/asm/mman.h      |    2 ++
 arch/parisc/include/asm/mman.h    |    2 ++
 arch/xtensa/include/asm/mman.h    |    2 ++
 include/asm-generic/mman-common.h |    2 +-
 5 files changed, 9 insertions(+), 1 deletion(-)

--- a/arch/alpha/include/asm/mman.h
+++ b/arch/alpha/include/asm/mman.h
@@ -53,6 +53,8 @@
 #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
 #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
 
+#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- a/arch/mips/include/asm/mman.h
+++ b/arch/mips/include/asm/mman.h
@@ -77,6 +77,8 @@
 #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
 #define MADV_HWPOISON    100		/* poison a page for testing */
 
+#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- a/arch/parisc/include/asm/mman.h
+++ b/arch/parisc/include/asm/mman.h
@@ -59,6 +59,8 @@
 #define MADV_MERGEABLE   65		/* KSM may merge identical pages */
 #define MADV_UNMERGEABLE 66		/* KSM may not merge identical pages */
 
+#define MADV_HUGEPAGE	67		/* Worth backing with hugepages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 #define MAP_VARIABLE	0
--- a/arch/xtensa/include/asm/mman.h
+++ b/arch/xtensa/include/asm/mman.h
@@ -83,6 +83,8 @@
 #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
 #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
 
+#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
+
 /* compatibility flags */
 #define MAP_FILE	0
 
--- a/include/asm-generic/mman-common.h
+++ b/include/asm-generic/mman-common.h
@@ -45,7 +45,7 @@
 #define MADV_MERGEABLE   12		/* KSM may merge identical pages */
 #define MADV_UNMERGEABLE 13		/* KSM may not merge identical pages */
 
-#define MADV_HUGEPAGE	15		/* Worth backing with hugepages */
+#define MADV_HUGEPAGE	14		/* Worth backing with hugepages */
 
 /* compatibility flags */
 #define MAP_FILE	0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
