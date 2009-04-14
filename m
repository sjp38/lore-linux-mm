Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E0F535F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 12:50:14 -0400 (EDT)
Date: Tue, 14 Apr 2009 18:50:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 5/5] mm: prompt slqb default for oldconfig 
Message-ID: <20090414165058.GE14873@wotan.suse.de>
References: <20090414164439.GA14873@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090414164439.GA14873@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Pekka,

Well there have been reasonably significant changes both for SLQB and
SLUB that I thought it is better to wait one more round before merging
SLQB. Also, SLQB may not have been getting as much testing as it could
have in -next, due to oldconfig choosing existing config as the default.

Thanks,
Nick
--

Change Kconfig names for slab allocator choices to prod SLQB into being
the default. Hopefully increasing testing base.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig	2009-04-15 02:36:05.000000000 +1000
+++ linux-2.6/init/Kconfig	2009-04-15 02:41:25.000000000 +1000
@@ -975,18 +975,23 @@ config COMPAT_BRK
 
 choice
 	prompt "Choose SLAB allocator"
-	default SLQB
+	default SLQB_ALLOCATOR
 	help
 	   This option allows to select a slab allocator.
 
-config SLAB
+config SLAB_ALLOCATOR
 	bool "SLAB"
 	help
 	  The regular slab allocator that is established and known to work
 	  well in all environments. It organizes cache hot objects in
 	  per cpu and per node queues.
 
-config SLUB
+config SLAB
+	bool
+	default y
+	depends on SLAB_ALLOCATOR
+
+config SLUB_ALLOCATOR
 	bool "SLUB (Unqueued Allocator)"
 	help
 	   SLUB is a slab allocator that minimizes cache line usage
@@ -996,11 +1001,21 @@ config SLUB
 	   and has enhanced diagnostics. SLUB is the default choice for
 	   a slab allocator.
 
-config SLQB
+config SLUB
+	bool
+	default y
+	depends on SLUB_ALLOCATOR
+
+config SLQB_ALLOCATOR
 	bool "SLQB (Queued allocator)"
 	help
 	  SLQB is a proposed new slab allocator.
 
+config SLQB
+	bool
+	default y
+	depends on SLQB_ALLOCATOR
+
 config SLOB
 	depends on EMBEDDED
 	bool "SLOB (Simple Allocator)"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
