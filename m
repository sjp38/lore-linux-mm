Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CB6836B0087
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 09:18:43 -0500 (EST)
Message-Id: <20100221141752.738951500@redhat.com>
Date: Sun, 21 Feb 2010 15:10:10 +0100
From: aarcange@redhat.com
Subject: [patch 01/36] define MADV_HUGEPAGE
References: <20100221141009.581909647@redhat.com>
Content-Disposition: inline; filename=madv_hugepage_define
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Define MADV_HUGEPAGE.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---

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
