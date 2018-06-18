Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 302EF6B0266
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w9-v6so12370310wrl.13
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:00:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 3-v6si14904603wrb.266.2018.06.18.10.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:00:25 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwsdW182585
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:24 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jpde7h93h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:24 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 18 Jun 2018 18:00:22 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 07/11] docs/mm: memblock: update kernel-doc comments
Date: Mon, 18 Jun 2018 19:59:55 +0300
In-Reply-To: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1529341199-17682-8-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

* make memblock_discard description kernel-doc compatible
* add brief description for memblock_setclr_flag and describe its
  parameters
* fixup return value descriptions

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/memblock.h | 17 +++++++---
 mm/memblock.c            | 84 +++++++++++++++++++++++++++---------------------
 2 files changed, 59 insertions(+), 42 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 8b8fbce..63704c6 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -239,7 +239,6 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 /**
  * for_each_resv_unavail_range - iterate through reserved and unavailable memory
  * @i: u64 used as loop variable
- * @flags: pick from blocks based on memory attributes
  * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
  * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
  *
@@ -367,8 +366,10 @@ phys_addr_t memblock_get_current_limit(void);
  */
 
 /**
- * memblock_region_memory_base_pfn - Return the lowest pfn intersecting with the memory region
+ * memblock_region_memory_base_pfn - get the lowest pfn of the memory region
  * @reg: memblock_region structure
+ *
+ * Return: the lowest pfn intersecting with the memory region
  */
 static inline unsigned long memblock_region_memory_base_pfn(const struct memblock_region *reg)
 {
@@ -376,8 +377,10 @@ static inline unsigned long memblock_region_memory_base_pfn(const struct membloc
 }
 
 /**
- * memblock_region_memory_end_pfn - Return the end_pfn this region
+ * memblock_region_memory_end_pfn - get the end pfn of the memory region
  * @reg: memblock_region structure
+ *
+ * Return: the end_pfn of the reserved region
  */
 static inline unsigned long memblock_region_memory_end_pfn(const struct memblock_region *reg)
 {
@@ -385,8 +388,10 @@ static inline unsigned long memblock_region_memory_end_pfn(const struct memblock
 }
 
 /**
- * memblock_region_reserved_base_pfn - Return the lowest pfn intersecting with the reserved region
+ * memblock_region_reserved_base_pfn - get the lowest pfn of the reserved region
  * @reg: memblock_region structure
+ *
+ * Return: the lowest pfn intersecting with the reserved region
  */
 static inline unsigned long memblock_region_reserved_base_pfn(const struct memblock_region *reg)
 {
@@ -394,8 +399,10 @@ static inline unsigned long memblock_region_reserved_base_pfn(const struct membl
 }
 
 /**
- * memblock_region_reserved_end_pfn - Return the end_pfn this region
+ * memblock_region_reserved_end_pfn - get the end pfn of the reserved region
  * @reg: memblock_region structure
+ *
+ * Return: the end_pfn of the reserved region
  */
 static inline unsigned long memblock_region_reserved_end_pfn(const struct memblock_region *reg)
 {
diff --git a/mm/memblock.c b/mm/memblock.c
index fc5d966..3d6deff 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -92,10 +92,11 @@ bool __init_memblock memblock_overlaps_region(struct memblock_type *type,
 	return i < type->cnt;
 }
 
-/*
+/**
  * __memblock_find_range_bottom_up - find free area utility in bottom-up
  * @start: start of candidate range
- * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @end: end of candidate range, can be %MEMBLOCK_ALLOC_ANYWHERE or
+ *       %MEMBLOCK_ALLOC_ACCESSIBLE
  * @size: size of free area to find
  * @align: alignment of free area to find
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
@@ -103,7 +104,7 @@ bool __init_memblock memblock_overlaps_region(struct memblock_type *type,
  *
  * Utility called from memblock_find_in_range_node(), find free area bottom-up.
  *
- * RETURNS:
+ * Return:
  * Found address on success, 0 on failure.
  */
 static phys_addr_t __init_memblock
@@ -129,7 +130,8 @@ __memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
 /**
  * __memblock_find_range_top_down - find free area utility, in top-down
  * @start: start of candidate range
- * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @end: end of candidate range, can be %MEMBLOCK_ALLOC_ANYWHERE or
+ *       %MEMBLOCK_ALLOC_ACCESSIBLE
  * @size: size of free area to find
  * @align: alignment of free area to find
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
@@ -137,7 +139,7 @@ __memblock_find_range_bottom_up(phys_addr_t start, phys_addr_t end,
  *
  * Utility called from memblock_find_in_range_node(), find free area top-down.
  *
- * RETURNS:
+ * Return:
  * Found address on success, 0 on failure.
  */
 static phys_addr_t __init_memblock
@@ -169,7 +171,8 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
  * @size: size of free area to find
  * @align: alignment of free area to find
  * @start: start of candidate range
- * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @end: end of candidate range, can be %MEMBLOCK_ALLOC_ANYWHERE or
+ *       %MEMBLOCK_ALLOC_ACCESSIBLE
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  * @flags: pick from blocks based on memory attributes
  *
@@ -183,7 +186,7 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
  *
  * If bottom-up allocation failed, will try to allocate memory top-down.
  *
- * RETURNS:
+ * Return:
  * Found address on success, 0 on failure.
  */
 phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
@@ -238,13 +241,14 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
 /**
  * memblock_find_in_range - find free area in given range
  * @start: start of candidate range
- * @end: end of candidate range, can be %MEMBLOCK_ALLOC_{ANYWHERE|ACCESSIBLE}
+ * @end: end of candidate range, can be %MEMBLOCK_ALLOC_ANYWHERE or
+ *       %MEMBLOCK_ALLOC_ACCESSIBLE
  * @size: size of free area to find
  * @align: alignment of free area to find
  *
  * Find @size free area aligned to @align in the specified range.
  *
- * RETURNS:
+ * Return:
  * Found address on success, 0 on failure.
  */
 phys_addr_t __init_memblock memblock_find_in_range(phys_addr_t start,
@@ -288,7 +292,7 @@ static void __init_memblock memblock_remove_region(struct memblock_type *type, u
 
 #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
 /**
- * Discard memory and reserved arrays if they were allocated
+ * memblock_discard - discard memory and reserved arrays if they were allocated
  */
 void __init memblock_discard(void)
 {
@@ -318,11 +322,11 @@ void __init memblock_discard(void)
  *
  * Double the size of the @type regions array. If memblock is being used to
  * allocate memory for a new reserved regions array and there is a previously
- * allocated memory range [@new_area_start,@new_area_start+@new_area_size]
+ * allocated memory range [@new_area_start, @new_area_start + @new_area_size]
  * waiting to be reserved, ensure the memory used by the new array does
  * not overlap.
  *
- * RETURNS:
+ * Return:
  * 0 on success, -1 on failure.
  */
 static int __init_memblock memblock_double_array(struct memblock_type *type,
@@ -467,7 +471,7 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
  * @nid:	node id of the new region
  * @flags:	flags of the new region
  *
- * Insert new memblock region [@base,@base+@size) into @type at @idx.
+ * Insert new memblock region [@base, @base + @size) into @type at @idx.
  * @type must already have extra room to accommodate the new region.
  */
 static void __init_memblock memblock_insert_region(struct memblock_type *type,
@@ -496,12 +500,12 @@ static void __init_memblock memblock_insert_region(struct memblock_type *type,
  * @nid: nid of the new region
  * @flags: flags of the new region
  *
- * Add new memblock region [@base,@base+@size) into @type.  The new region
+ * Add new memblock region [@base, @base + @size) into @type.  The new region
  * is allowed to overlap with existing ones - overlaps don't affect already
  * existing regions.  @type is guaranteed to be minimal (all neighbouring
  * compatible regions are merged) after the addition.
  *
- * RETURNS:
+ * Return:
  * 0 on success, -errno on failure.
  */
 int __init_memblock memblock_add_range(struct memblock_type *type,
@@ -615,11 +619,11 @@ int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
  * @end_rgn: out parameter for the end of isolated region
  *
  * Walk @type and ensure that regions don't cross the boundaries defined by
- * [@base,@base+@size).  Crossing regions are split at the boundaries,
+ * [@base, @base + @size).  Crossing regions are split at the boundaries,
  * which may create at most two more regions.  The index of the first
  * region inside the range is returned in *@start_rgn and end in *@end_rgn.
  *
- * RETURNS:
+ * Return:
  * 0 on success, -errno on failure.
  */
 static int __init_memblock memblock_isolate_range(struct memblock_type *type,
@@ -725,10 +729,15 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 }
 
 /**
+ * memblock_setclr_flag - set or clear flag for a memory region
+ * @base: base address of the region
+ * @size: size of the region
+ * @set: set or clear the flag
+ * @flag: the flag to udpate
  *
  * This function isolates region [@base, @base + @size), and sets/clears flag
  *
- * Return 0 on success, -errno on failure.
+ * Return: 0 on success, -errno on failure.
  */
 static int __init_memblock memblock_setclr_flag(phys_addr_t base,
 				phys_addr_t size, int set, int flag)
@@ -755,7 +764,7 @@ static int __init_memblock memblock_setclr_flag(phys_addr_t base,
  * @base: the base phys addr of the region
  * @size: the size of the region
  *
- * Return 0 on success, -errno on failure.
+ * Return: 0 on success, -errno on failure.
  */
 int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
 {
@@ -767,7 +776,7 @@ int __init_memblock memblock_mark_hotplug(phys_addr_t base, phys_addr_t size)
  * @base: the base phys addr of the region
  * @size: the size of the region
  *
- * Return 0 on success, -errno on failure.
+ * Return: 0 on success, -errno on failure.
  */
 int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
 {
@@ -779,7 +788,7 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
  * @base: the base phys addr of the region
  * @size: the size of the region
  *
- * Return 0 on success, -errno on failure.
+ * Return: 0 on success, -errno on failure.
  */
 int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
 {
@@ -793,7 +802,7 @@ int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
  * @base: the base phys addr of the region
  * @size: the size of the region
  *
- * Return 0 on success, -errno on failure.
+ * Return: 0 on success, -errno on failure.
  */
 int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
 {
@@ -805,7 +814,7 @@ int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
  * @base: the base phys addr of the region
  * @size: the size of the region
  *
- * Return 0 on success, -errno on failure.
+ * Return: 0 on success, -errno on failure.
  */
 int __init_memblock memblock_clear_nomap(phys_addr_t base, phys_addr_t size)
 {
@@ -966,9 +975,6 @@ void __init_memblock __next_mem_range(u64 *idx, int nid,
 /**
  * __next_mem_range_rev - generic next function for for_each_*_range_rev()
  *
- * Finds the next range from type_a which is not marked as unsuitable
- * in type_b.
- *
  * @idx: pointer to u64 loop variable
  * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @flags: pick from blocks based on memory attributes
@@ -978,6 +984,9 @@ void __init_memblock __next_mem_range(u64 *idx, int nid,
  * @out_end: ptr to phys_addr_t for end address of the range, can be %NULL
  * @out_nid: ptr to int for nid of the range, can be %NULL
  *
+ * Finds the next range from type_a which is not marked as unsuitable
+ * in type_b.
+ *
  * Reverse of __next_mem_range().
  */
 void __init_memblock __next_mem_range_rev(u64 *idx, int nid,
@@ -1113,10 +1122,10 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
  * @type: memblock type to set node ID for
  * @nid: node ID to set
  *
- * Set the nid of memblock @type regions in [@base,@base+@size) to @nid.
+ * Set the nid of memblock @type regions in [@base, @base + @size) to @nid.
  * Regions which cross the area boundaries are split as necessary.
  *
- * RETURNS:
+ * Return:
  * 0 on success, -errno on failure.
  */
 int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
@@ -1240,7 +1249,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
  * The allocation is performed from memory region limited by
  * memblock.current_limit if @max_addr == %BOOTMEM_ALLOC_ACCESSIBLE.
  *
- * The memory block is aligned on SMP_CACHE_BYTES if @align == 0.
+ * The memory block is aligned on %SMP_CACHE_BYTES if @align == 0.
  *
  * The phys address of allocated boot memory block is converted to virtual and
  * allocated memory is reset to 0.
@@ -1248,7 +1257,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
  * In addition, function sets the min_count to 0 using kmemleak_alloc for
  * allocated boot memory block, so that it is never reported as leaks.
  *
- * RETURNS:
+ * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
  */
 static void * __init memblock_virt_alloc_internal(
@@ -1333,7 +1342,7 @@ static void * __init memblock_virt_alloc_internal(
  * info), if enabled. Does not zero allocated memory, does not panic if request
  * cannot be satisfied.
  *
- * RETURNS:
+ * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
  */
 void * __init memblock_virt_alloc_try_nid_raw(
@@ -1370,7 +1379,7 @@ void * __init memblock_virt_alloc_try_nid_raw(
  * Public function, provides additional debug information (including caller
  * info), if enabled. This function zeroes the allocated memory.
  *
- * RETURNS:
+ * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
  */
 void * __init memblock_virt_alloc_try_nid_nopanic(
@@ -1406,7 +1415,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
  * which provides debug information (including caller info), if enabled,
  * and panics if the request can not be satisfied.
  *
- * RETURNS:
+ * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
  */
 void * __init memblock_virt_alloc_try_nid(
@@ -1663,9 +1672,9 @@ int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
  * @base: base of region to check
  * @size: size of region to check
  *
- * Check if the region [@base, @base+@size) is a subset of a memory block.
+ * Check if the region [@base, @base + @size) is a subset of a memory block.
  *
- * RETURNS:
+ * Return:
  * 0 if false, non-zero if true
  */
 bool __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size)
@@ -1684,9 +1693,10 @@ bool __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t siz
  * @base: base of region to check
  * @size: size of region to check
  *
- * Check if the region [@base, @base+@size) intersects a reserved memory block.
+ * Check if the region [@base, @base + @size) intersects a reserved
+ * memory block.
  *
- * RETURNS:
+ * Return:
  * True if they intersect, false if not.
  */
 bool __init_memblock memblock_is_region_reserved(phys_addr_t base, phys_addr_t size)
-- 
2.7.4
