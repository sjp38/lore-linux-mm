Message-Id: <20080131135355.410741000@bull.net>
References: <20080131134018.273154000@bull.net>
Date: Thu, 31 Jan 2008 14:40:21 +0100
From: Nadia.Derbey@bull.net
Subject: [RFC][PATCH v2 3/7] Defining the slab_memory_callback priority as a constant
Content-Disposition: inline; filename=ipc_slab_memory_callback_prio_to_const.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, Nadia Derbey <Nadia.Derbey@bull.net>
List-ID: <linux-mm.kvack.org>

[PATCH 03/07]

This is a trivial patch that defines the priority of slab_memory_callback in
the callback chain as a constant.
This is to prepare for next patch in the series.

Signed-off-by: Nadia Derbey <Nadia.Derbey@bull.net>

---
 include/linux/memory.h |    6 ++++++
 mm/slub.c              |    2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

Index: linux-2.6.24/include/linux/memory.h
===================================================================
--- linux-2.6.24.orig/include/linux/memory.h	2008-01-29 16:54:38.000000000 +0100
+++ linux-2.6.24/include/linux/memory.h	2008-01-31 10:30:37.000000000 +0100
@@ -54,6 +54,12 @@ struct memory_notify {
 struct notifier_block;
 struct mem_section;
 
+/*
+ * Priorities for the hotplug memory callback routines (stored in decreasing
+ * order in the callback chain)
+ */
+#define SLAB_CALLBACK_PRI       1
+
 #ifndef CONFIG_MEMORY_HOTPLUG_SPARSE
 static inline int memory_dev_init(void)
 {
Index: linux-2.6.24/mm/slub.c
===================================================================
--- linux-2.6.24.orig/mm/slub.c	2008-01-29 16:54:49.000000000 +0100
+++ linux-2.6.24/mm/slub.c	2008-01-31 10:31:34.000000000 +0100
@@ -2816,7 +2816,7 @@ void __init kmem_cache_init(void)
 	kmalloc_caches[0].refcount = -1;
 	caches++;
 
-	hotplug_memory_notifier(slab_memory_callback, 1);
+	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
 #endif
 
 	/* Able to allocate the per node structures */

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
