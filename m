From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH -mm 02/14] bootmem: clean up bootmem.c file header
Date: Fri, 30 May 2008 21:42:22 +0200
Message-ID: <20080530194737.546890386@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755223AbYE3UDX@vger.kernel.org>
Content-Disposition: inline; filename=bootmem-adjust-file-header.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Change the description, move a misplaced comment about the allocator
itself and add me to the list of copyright holders.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Ingo Molnar <mingo@elte.hu>
---

 mm/bootmem.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -1,12 +1,12 @@
 /*
- *  linux/mm/bootmem.c
+ *  bootmem - A boot-time physical memory allocator and configurator
  *
  *  Copyright (C) 1999 Ingo Molnar
- *  Discontiguous memory support, Kanoj Sarcar, SGI, Nov 1999
+ *                1999 Kanoj Sarcar, SGI
+ *                2008 Johannes Weiner
  *
- *  simple boot-time physical memory area allocator and
- *  free memory collector. It's used to deal with reserved
- *  system memory and memory holes as well.
+ * Access to this subsystem has to be serialized externally (which is true
+ * for the boot process anyway).
  */
 #include <linux/init.h>
 #include <linux/pfn.h>
@@ -19,10 +19,6 @@
 
 #include "internal.h"
 
-/*
- * Access to this subsystem has to be serialized externally. (this is
- * true for the boot process anyway)
- */
 unsigned long max_low_pfn;
 unsigned long min_low_pfn;
 unsigned long max_pfn;

-- 
