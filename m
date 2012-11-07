Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id E52906B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 20:10:21 -0500 (EST)
Message-ID: <5099B4F2.2090602@infradead.org>
Date: Tue, 06 Nov 2012 17:10:10 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH] mm: fix slab.c kernel-doc warnings
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

From: Randy Dunlap <rdunlap@infradead.org>

Fix new kernel-doc warnings in mm/slab.c:

Warning(mm/slab.c:2358): No description found for parameter 'cachep'
Warning(mm/slab.c:2358): Excess function parameter 'name' description in '__kmem_cache_create'
Warning(mm/slab.c:2358): Excess function parameter 'size' description in '__kmem_cache_create'
Warning(mm/slab.c:2358): Excess function parameter 'align' description in '__kmem_cache_create'
Warning(mm/slab.c:2358): Excess function parameter 'ctor' description in '__kmem_cache_create'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc:	Christoph Lameter <cl@linux-foundation.org>
Cc:	Pekka Enberg <penberg@kernel.org>
Cc:	Matt Mackall <mpm@selenic.com>
---
 mm/slab.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- lnx-37-rc4.orig/mm/slab.c
+++ lnx-37-rc4/mm/slab.c
@@ -2331,11 +2331,8 @@ static int __init_refok setup_cpu_cache(
 
 /**
  * __kmem_cache_create - Create a cache.
- * @name: A string which is used in /proc/slabinfo to identify this cache.
- * @size: The size of objects to be created in this cache.
- * @align: The required alignment for the objects.
+ * @cachep: cache management descriptor
  * @flags: SLAB flags
- * @ctor: A constructor for the objects.
  *
  * Returns a ptr to the cache on success, NULL on failure.
  * Cannot be called within a int, but can be interrupted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
