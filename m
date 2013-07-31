Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A17196B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:22:50 -0400 (EDT)
Message-ID: <0000014035c0e66c-98875436-a963-4e74-be1c-361e58652bec-000000@email.amazonses.com>
Date: Wed, 31 Jul 2013 17:22:49 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 3/5] slabs: Remove unnecessary #includes
References: <20130731171257.629155011@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Now that there are only some struct definitions left in
sl?b_def.h we can remove most of the #include statements.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2013-07-18 11:11:59.757679886 -0500
+++ linux/include/linux/slab_def.h	2013-07-18 11:11:59.753679819 -0500
@@ -3,20 +3,6 @@
 
 /*
  * Definitions unique to the original Linux SLAB allocator.
- *
- * What we provide here is a way to optimize the frequent kmalloc
- * calls in the kernel by selecting the appropriate general cache
- * if kmalloc was called with a size that can be established at
- * compile time.
- */
-
-#include <linux/init.h>
-#include <linux/compiler.h>
-
-/*
- * struct kmem_cache
- *
- * manages a cache.
  */
 
 struct kmem_cache {
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2013-07-18 11:11:59.757679886 -0500
+++ linux/include/linux/slub_def.h	2013-07-18 11:13:32.000000000 -0500
@@ -6,10 +6,6 @@
  *
  * (C) 2007 SGI, Christoph Lameter
  */
-#include <linux/types.h>
-#include <linux/gfp.h>
-#include <linux/bug.h>
-#include <linux/workqueue.h>
 #include <linux/kobject.h>
 
 enum stat_item {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
