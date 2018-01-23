Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18E31800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:06 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id d3so13318584qth.5
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:48:06 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o17si3997480qkl.94.2018.01.23.01.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 01:48:04 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0N9kQqS097262
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:04 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fp2jwgbh0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:03 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 23 Jan 2018 09:48:01 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/3] mm: docs: fix parameter names mismatch
Date: Tue, 23 Jan 2018 11:47:50 +0200
In-Reply-To: <1516700871-22279-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1516700871-22279-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1516700871-22279-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm <linux-mm@kvack.org>, linux-doc <linux-doc@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

There are several places where parameter descriptions do no match the
actual code.
Fix it.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/bootmem.c           |  2 +-
 mm/maccess.c           |  2 +-
 mm/memcontrol.c        |  2 +-
 mm/process_vm_access.c |  2 +-
 mm/swap.c              |  4 ++--
 mm/z3fold.c            |  4 ++--
 mm/zbud.c              |  4 ++--
 mm/zpool.c             | 20 ++++++++++----------
 8 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 6aef64254203..9e197987b67d 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -410,7 +410,7 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 
 /**
  * free_bootmem - mark a page range as usable
- * @addr: starting physical address of the range
+ * @physaddr: starting physical address of the range
  * @size: size of the range in bytes
  *
  * Partial pages will be considered reserved and left as they are.
diff --git a/mm/maccess.c b/mm/maccess.c
index 78f9274dd49d..ec00be51a24f 100644
--- a/mm/maccess.c
+++ b/mm/maccess.c
@@ -70,7 +70,7 @@ EXPORT_SYMBOL_GPL(probe_kernel_write);
  * strncpy_from_unsafe: - Copy a NUL terminated string from unsafe address.
  * @dst:   Destination address, in kernel space.  This buffer must be at
  *         least @count bytes long.
- * @src:   Unsafe address.
+ * @unsafe_addr: Unsafe address.
  * @count: Maximum number of bytes to copy, including the trailing NUL.
  *
  * Copies a NUL-terminated string from unsafe address to kernel buffer.
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cddea3ed8e86..0975cde3e83b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -946,7 +946,7 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 /**
  * mem_cgroup_page_lruvec - return lruvec for isolating/putting an LRU page
  * @page: the page
- * @zone: zone of the page
+ * @pgdat: pgdat of the page
  *
  * This function is only safe when following the LRU page isolation
  * and putback protocol: the LRU lock must be held, and the page must
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 8973cd231ece..011edefd3c92 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -25,7 +25,7 @@
 /**
  * process_vm_rw_pages - read/write pages from task specified
  * @pages: array of pointers to pages we want to copy
- * @start_offset: offset in page to start copying from/to
+ * @offset: offset in page to start copying from/to
  * @len: number of bytes to copy
  * @iter: where to copy to/from locally
  * @vm_write: 0 means copy from, 1 means copy to
diff --git a/mm/swap.c b/mm/swap.c
index 38e1b6374a97..2e8dae403474 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -913,11 +913,11 @@ EXPORT_SYMBOL(__pagevec_lru_add);
  * @pvec:	Where the resulting entries are placed
  * @mapping:	The address_space to search
  * @start:	The starting entry index
- * @nr_entries:	The maximum number of entries
+ * @nr_pages:	The maximum number of pages
  * @indices:	The cache indices corresponding to the entries in @pvec
  *
  * pagevec_lookup_entries() will search for and return a group of up
- * to @nr_entries pages and shadow entries in the mapping.  All
+ * to @nr_pages pages and shadow entries in the mapping.  All
  * entries are placed in @pvec.  pagevec_lookup_entries() takes a
  * reference against actual pages in @pvec.
  *
diff --git a/mm/z3fold.c b/mm/z3fold.c
index 39e19125d6a0..d589d318727f 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -769,7 +769,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 /**
  * z3fold_reclaim_page() - evicts allocations from a pool page and frees it
  * @pool:	pool from which a page will attempt to be evicted
- * @retires:	number of pages on the LRU list for which eviction will
+ * @retries:	number of pages on the LRU list for which eviction will
  *		be attempted before failing
  *
  * z3fold reclaim is different from normal system reclaim in that it is done
@@ -779,7 +779,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
  * z3fold and the user, however.
  *
  * To avoid these, this is how z3fold_reclaim_page() should be called:
-
+ *
  * The user detects a page should be reclaimed and calls z3fold_reclaim_page().
  * z3fold_reclaim_page() will remove a z3fold page from the pool LRU list and
  * call the user-defined eviction handler with the pool and handle as
diff --git a/mm/zbud.c b/mm/zbud.c
index b42322e50f63..28458f7d1e84 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -466,7 +466,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 /**
  * zbud_reclaim_page() - evicts allocations from a pool page and frees it
  * @pool:	pool from which a page will attempt to be evicted
- * @retires:	number of pages on the LRU list for which eviction will
+ * @retries:	number of pages on the LRU list for which eviction will
  *		be attempted before failing
  *
  * zbud reclaim is different from normal system reclaim in that the reclaim is
@@ -476,7 +476,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
  * the user, however.
  *
  * To avoid these, this is how zbud_reclaim_page() should be called:
-
+ *
  * The user detects a page should be reclaimed and calls zbud_reclaim_page().
  * zbud_reclaim_page() will remove a zbud page from the pool LRU list and call
  * the user-defined eviction handler with the pool and handle as arguments.
diff --git a/mm/zpool.c b/mm/zpool.c
index 2e6f9c3cebe7..4cf4af94a629 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -199,7 +199,7 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
 
 /**
  * zpool_destroy_pool() - Destroy a zpool
- * @pool:	The zpool to destroy.
+ * @zpool:	The zpool to destroy.
  *
  * Implementations must guarantee this to be thread-safe,
  * however only when destroying different pools.  The same
@@ -222,7 +222,7 @@ void zpool_destroy_pool(struct zpool *zpool)
 
 /**
  * zpool_get_type() - Get the type of the zpool
- * @pool:	The zpool to check
+ * @zpool:	The zpool to check
  *
  * This returns the type of the pool.
  *
@@ -237,7 +237,7 @@ const char *zpool_get_type(struct zpool *zpool)
 
 /**
  * zpool_malloc() - Allocate memory
- * @pool:	The zpool to allocate from.
+ * @zpool:	The zpool to allocate from.
  * @size:	The amount of memory to allocate.
  * @gfp:	The GFP flags to use when allocating memory.
  * @handle:	Pointer to the handle to set
@@ -259,7 +259,7 @@ int zpool_malloc(struct zpool *zpool, size_t size, gfp_t gfp,
 
 /**
  * zpool_free() - Free previously allocated memory
- * @pool:	The zpool that allocated the memory.
+ * @zpool:	The zpool that allocated the memory.
  * @handle:	The handle to the memory to free.
  *
  * This frees previously allocated memory.  This does not guarantee
@@ -278,7 +278,7 @@ void zpool_free(struct zpool *zpool, unsigned long handle)
 
 /**
  * zpool_shrink() - Shrink the pool size
- * @pool:	The zpool to shrink.
+ * @zpool:	The zpool to shrink.
  * @pages:	The number of pages to shrink the pool.
  * @reclaimed:	The number of pages successfully evicted.
  *
@@ -301,11 +301,11 @@ int zpool_shrink(struct zpool *zpool, unsigned int pages,
 
 /**
  * zpool_map_handle() - Map a previously allocated handle into memory
- * @pool:	The zpool that the handle was allocated from
+ * @zpool:	The zpool that the handle was allocated from
  * @handle:	The handle to map
- * @mm:		How the memory should be mapped
+ * @mapmode:	How the memory should be mapped
  *
- * This maps a previously allocated handle into memory.  The @mm
+ * This maps a previously allocated handle into memory.  The @mapmode
  * param indicates to the implementation how the memory will be
  * used, i.e. read-only, write-only, read-write.  If the
  * implementation does not support it, the memory will be treated
@@ -329,7 +329,7 @@ void *zpool_map_handle(struct zpool *zpool, unsigned long handle,
 
 /**
  * zpool_unmap_handle() - Unmap a previously mapped handle
- * @pool:	The zpool that the handle was allocated from
+ * @zpool:	The zpool that the handle was allocated from
  * @handle:	The handle to unmap
  *
  * This unmaps a previously mapped handle.  Any locks or other
@@ -344,7 +344,7 @@ void zpool_unmap_handle(struct zpool *zpool, unsigned long handle)
 
 /**
  * zpool_get_total_size() - The total size of the pool
- * @pool:	The zpool to check
+ * @zpool:	The zpool to check
  *
  * This returns the total size in bytes of the pool.
  *
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
