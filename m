From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/7] pagemap: document clarifications
Date: Thu, 07 May 2009 09:21:22 +0800
Message-ID: <20090507014914.492422232@intel.com>
References: <20090507012116.996644836@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5F2486B0047
	for <linux-mm@kvack.org>; Wed,  6 May 2009 21:49:35 -0400 (EDT)
Content-Disposition: inline; filename=kpageflags-doc-fix.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Some bit ranges were inclusive and some not.
Fix them to be consistently inclusive.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/vm/pagemap.txt |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux.orig/Documentation/vm/pagemap.txt
+++ linux/Documentation/vm/pagemap.txt
@@ -12,9 +12,9 @@ There are three components to pagemap:
    value for each virtual page, containing the following data (from
    fs/proc/task_mmu.c, above pagemap_read):
 
-    * Bits 0-55  page frame number (PFN) if present
+    * Bits 0-54  page frame number (PFN) if present
     * Bits 0-4   swap type if swapped
-    * Bits 5-55  swap offset if swapped
+    * Bits 5-54  swap offset if swapped
     * Bits 55-60 page shift (page size = 1<<page shift)
     * Bit  61    reserved for future use
     * Bit  62    page swapped
@@ -36,7 +36,7 @@ There are three components to pagemap:
  * /proc/kpageflags.  This file contains a 64-bit set of flags for each
    page, indexed by PFN.
 
-   The flags are (from fs/proc/proc_misc, above kpageflags_read):
+   The flags are (from fs/proc/page.c, above kpageflags_read):
 
      0. LOCKED
      1. ERROR

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
