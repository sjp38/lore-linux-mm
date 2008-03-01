Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by relay1.corp.sgi.com (Postfix) with ESMTP id 2F98C8F80A9
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:16 -0800 (PST)
Received: from clameter by schroedinger.engr.sgi.com with local (Exim 3.36 #1 (Debian))
	id 1JVJ1E-0004YT-00
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:16 -0800
Message-Id: <20080301040815.842764035@sgi.com>
References: <20080301040755.268426038@sgi.com>
Date: Fri, 29 Feb 2008 20:08:03 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 08/10] Export NR_MAX_ZONES to the preprocessor
Content-Disposition: inline; filename=bounds_nr_max_zones
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---
 include/linux/bounds.h |    1 +
 include/linux/mmzone.h |    3 ++-
 kernel/bounds.c        |    1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2008-02-29 18:18:19.000000000 -0800
+++ linux-2.6/include/linux/mmzone.h	2008-02-29 18:20:30.000000000 -0800
@@ -17,6 +17,7 @@
 #include <linux/pageblock-flags.h>
 #include <asm/atomic.h>
 #include <asm/page.h>
+#include <linux/bounds.h>
 
 /* Free memory management - zoned buddy allocator.  */
 #ifndef CONFIG_FORCE_MAX_ZONEORDER
@@ -177,7 +178,7 @@ enum zone_type {
 	ZONE_HIGHMEM,
 #endif
 	ZONE_MOVABLE,
-	MAX_NR_ZONES
+	__MAX_NR_ZONES
 };
 
 /*
Index: linux-2.6/kernel/bounds.c
===================================================================
--- linux-2.6.orig/kernel/bounds.c	2008-02-29 18:18:19.000000000 -0800
+++ linux-2.6/kernel/bounds.c	2008-02-29 18:18:53.000000000 -0800
@@ -14,4 +14,5 @@
 void foo(void)
 {
 	DEFINE(NR_PAGEFLAGS, __NR_PAGEFLAGS);
+	DEFINE(MAX_NR_ZONES, __MAX_NR_ZONES);
 }
Index: linux-2.6/include/linux/bounds.h
===================================================================
--- linux-2.6.orig/include/linux/bounds.h	2008-02-29 18:18:19.000000000 -0800
+++ linux-2.6/include/linux/bounds.h	2008-02-29 18:20:32.000000000 -0800
@@ -8,5 +8,6 @@
  */
 
 #define NR_PAGEFLAGS 32 /* __NR_PAGEFLAGS	# */
+#define MAX_NR_ZONES 4 /* __MAX_NR_ZONES	# */
 
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
