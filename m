Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 331D7800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:07 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id r23so19386633qte.13
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:48:07 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r18si1016478qtr.424.2018.01.23.01.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 01:48:06 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0N9jmWn080746
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:05 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fnx08jhnx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:48:04 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 23 Jan 2018 09:48:00 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm: docs: fixup punctuation
Date: Tue, 23 Jan 2018 11:47:49 +0200
In-Reply-To: <1516700871-22279-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1516700871-22279-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1516700871-22279-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm <linux-mm@kvack.org>, linux-doc <linux-doc@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

so that kernel-doc will properly recognize the parameter and function
descriptions.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/ksm.c            |  2 +-
 mm/memcontrol.c     |  4 ++--
 mm/mlock.c          |  2 +-
 mm/nommu.c          |  2 +-
 mm/sparse-vmemmap.c |  4 ++--
 mm/zpool.c          | 44 ++++++++++++++++++++++----------------------
 6 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index be8f4576f842..64207d936659 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2309,7 +2309,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 
 /**
  * ksm_do_scan  - the ksm scanner main worker function.
- * @scan_npages - number of pages we want to scan before we return.
+ * @scan_npages:  number of pages we want to scan before we return.
  */
 static void ksm_do_scan(unsigned int scan_npages)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ac2ffd5e02b9..cddea3ed8e86 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5885,8 +5885,8 @@ bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 
 /**
  * mem_cgroup_uncharge_skmem - uncharge socket memory
- * @memcg - memcg to uncharge
- * @nr_pages - number of pages to uncharge
+ * @memcg: memcg to uncharge
+ * @nr_pages: number of pages to uncharge
  */
 void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
 {
diff --git a/mm/mlock.c b/mm/mlock.c
index 30472d438794..3d2e834a6cb7 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -157,7 +157,7 @@ static void __munlock_isolation_failed(struct page *page)
 
 /**
  * munlock_vma_page - munlock a vma page
- * @page - page to be unlocked, either a normal page or THP page head
+ * @page: page to be unlocked, either a normal page or THP page head
  *
  * returns the size of the page as a page mask (0 for normal page,
  *         HPAGE_PMD_NR - 1 for THP head page)
diff --git a/mm/nommu.c b/mm/nommu.c
index 17c00d93de2e..52c14127a861 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1843,7 +1843,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 }
 
 /**
- * @access_remote_vm - access another process' address space
+ * access_remote_vm - access another process' address space
  * @mm:		the mm_struct of the target address space
  * @addr:	start address to access
  * @buf:	source or destination buffer
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 17acf01791fa..015ee4eb79bc 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -108,8 +108,8 @@ static unsigned long __meminit vmem_altmap_nr_free(struct vmem_altmap *altmap)
 
 /**
  * vmem_altmap_alloc - allocate pages from the vmem_altmap reservation
- * @altmap - reserved page pool for the allocation
- * @nr_pfns - size (in pages) of the allocation
+ * @altmap: reserved page pool for the allocation
+ * @nr_pfns: size (in pages) of the allocation
  *
  * Allocations are aligned to the size of the request
  */
diff --git a/mm/zpool.c b/mm/zpool.c
index fd3ff719c32c..2e6f9c3cebe7 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -100,7 +100,7 @@ static void zpool_put_driver(struct zpool_driver *driver)
 
 /**
  * zpool_has_pool() - Check if the pool driver is available
- * @type	The type of the zpool to check (e.g. zbud, zsmalloc)
+ * @type:	The type of the zpool to check (e.g. zbud, zsmalloc)
  *
  * This checks if the @type pool driver is available.  This will try to load
  * the requested module, if needed, but there is no guarantee the module will
@@ -135,10 +135,10 @@ EXPORT_SYMBOL(zpool_has_pool);
 
 /**
  * zpool_create_pool() - Create a new zpool
- * @type	The type of the zpool to create (e.g. zbud, zsmalloc)
- * @name	The name of the zpool (e.g. zram0, zswap)
- * @gfp		The GFP flags to use when allocating the pool.
- * @ops		The optional ops callback.
+ * @type:	The type of the zpool to create (e.g. zbud, zsmalloc)
+ * @name:	The name of the zpool (e.g. zram0, zswap)
+ * @gfp:	The GFP flags to use when allocating the pool.
+ * @ops:	The optional ops callback.
  *
  * This creates a new zpool of the specified type.  The gfp flags will be
  * used when allocating memory, if the implementation supports it.  If the
@@ -199,7 +199,7 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
 
 /**
  * zpool_destroy_pool() - Destroy a zpool
- * @pool	The zpool to destroy.
+ * @pool:	The zpool to destroy.
  *
  * Implementations must guarantee this to be thread-safe,
  * however only when destroying different pools.  The same
@@ -222,7 +222,7 @@ void zpool_destroy_pool(struct zpool *zpool)
 
 /**
  * zpool_get_type() - Get the type of the zpool
- * @pool	The zpool to check
+ * @pool:	The zpool to check
  *
  * This returns the type of the pool.
  *
@@ -237,10 +237,10 @@ const char *zpool_get_type(struct zpool *zpool)
 
 /**
  * zpool_malloc() - Allocate memory
- * @pool	The zpool to allocate from.
- * @size	The amount of memory to allocate.
- * @gfp		The GFP flags to use when allocating memory.
- * @handle	Pointer to the handle to set
+ * @pool:	The zpool to allocate from.
+ * @size:	The amount of memory to allocate.
+ * @gfp:	The GFP flags to use when allocating memory.
+ * @handle:	Pointer to the handle to set
  *
  * This allocates the requested amount of memory from the pool.
  * The gfp flags will be used when allocating memory, if the
@@ -259,8 +259,8 @@ int zpool_malloc(struct zpool *zpool, size_t size, gfp_t gfp,
 
 /**
  * zpool_free() - Free previously allocated memory
- * @pool	The zpool that allocated the memory.
- * @handle	The handle to the memory to free.
+ * @pool:	The zpool that allocated the memory.
+ * @handle:	The handle to the memory to free.
  *
  * This frees previously allocated memory.  This does not guarantee
  * that the pool will actually free memory, only that the memory
@@ -278,9 +278,9 @@ void zpool_free(struct zpool *zpool, unsigned long handle)
 
 /**
  * zpool_shrink() - Shrink the pool size
- * @pool	The zpool to shrink.
- * @pages	The number of pages to shrink the pool.
- * @reclaimed	The number of pages successfully evicted.
+ * @pool:	The zpool to shrink.
+ * @pages:	The number of pages to shrink the pool.
+ * @reclaimed:	The number of pages successfully evicted.
  *
  * This attempts to shrink the actual memory size of the pool
  * by evicting currently used handle(s).  If the pool was
@@ -301,9 +301,9 @@ int zpool_shrink(struct zpool *zpool, unsigned int pages,
 
 /**
  * zpool_map_handle() - Map a previously allocated handle into memory
- * @pool	The zpool that the handle was allocated from
- * @handle	The handle to map
- * @mm		How the memory should be mapped
+ * @pool:	The zpool that the handle was allocated from
+ * @handle:	The handle to map
+ * @mm:		How the memory should be mapped
  *
  * This maps a previously allocated handle into memory.  The @mm
  * param indicates to the implementation how the memory will be
@@ -329,8 +329,8 @@ void *zpool_map_handle(struct zpool *zpool, unsigned long handle,
 
 /**
  * zpool_unmap_handle() - Unmap a previously mapped handle
- * @pool	The zpool that the handle was allocated from
- * @handle	The handle to unmap
+ * @pool:	The zpool that the handle was allocated from
+ * @handle:	The handle to unmap
  *
  * This unmaps a previously mapped handle.  Any locks or other
  * actions that the implementation took in zpool_map_handle()
@@ -344,7 +344,7 @@ void zpool_unmap_handle(struct zpool *zpool, unsigned long handle)
 
 /**
  * zpool_get_total_size() - The total size of the pool
- * @pool	The zpool to check
+ * @pool:	The zpool to check
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
