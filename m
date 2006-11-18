Date: Fri, 17 Nov 2006 21:44:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061118054413.8884.99940.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
References: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 6/7] Use an external declaration in exit.c for fs_cachep
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Use an external declaration in exit.c for fs_cachep.

fs_cachep is only used in kernel/exit.c and in kernel/fork.c.
It is defined in kernel/fork.c so we need to add an external
declaration to kernel/exit.c to be able to avoid the
declaration.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-17 23:04:05.859898302 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-17 23:04:09.679562142 -0600
@@ -298,7 +298,6 @@ static inline void kmem_set_shrinker(kme
 
 /* System wide caches */
 extern kmem_cache_t	*names_cachep;
-extern kmem_cache_t	*fs_cachep;
 
 #endif	/* __KERNEL__ */
 
Index: linux-2.6.19-rc5-mm2/kernel/exit.c
===================================================================
--- linux-2.6.19-rc5-mm2.orig/kernel/exit.c	2006-11-15 16:48:11.485511089 -0600
+++ linux-2.6.19-rc5-mm2/kernel/exit.c	2006-11-17 23:04:09.764530373 -0600
@@ -48,6 +48,8 @@
 #include <asm/pgtable.h>
 #include <asm/mmu_context.h>
 
+extern kmem_cache_t *fs_cachep;
+
 extern void sem_exit (void);
 
 static void exit_mm(struct task_struct * tsk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
