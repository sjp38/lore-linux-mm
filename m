Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA9DC8E0005
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 07:01:51 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l76so11267970pfg.1
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 04:01:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f13si9536541pln.368.2019.01.20.04.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 04:01:49 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0KBsLgV010017
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 07:01:49 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q4hqby43n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 07:01:48 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 20 Jan 2019 12:01:45 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 1/3] docs/mm: vmalloc: re-indent kernel-doc comemnts
Date: Sun, 20 Jan 2019 14:01:35 +0200
In-Reply-To: <1547985697-24588-1-git-send-email-rppt@linux.ibm.com>
References: <1547985697-24588-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1547985697-24588-2-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Some kernel-doc comments in mm/vmalloc.c have leading tab in indentation.
This leads to excessive indentation in the generated HTML and to the
inconsistency of its layout [1].

Besides, multi-line Note: sections are not handled properly.

[1] https://www.kernel.org/doc/html/latest/core-api/mm-api.html?highlight=vfree#c.vfree

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/vmalloc.c | 367 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 182 insertions(+), 185 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 871e41c..215961c 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1187,6 +1187,7 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 EXPORT_SYMBOL(vm_map_ram);
 
 static struct vm_struct *vmlist __initdata;
+
 /**
  * vm_area_add_early - add vmap area early during boot
  * @vm: vm_struct to add
@@ -1421,13 +1422,13 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
 }
 
 /**
- *	get_vm_area  -  reserve a contiguous kernel virtual area
- *	@size:		size of the area
- *	@flags:		%VM_IOREMAP for I/O mappings or VM_ALLOC
+ * get_vm_area - reserve a contiguous kernel virtual area
+ * @size:	 size of the area
+ * @flags:	 %VM_IOREMAP for I/O mappings or VM_ALLOC
  *
- *	Search an area of @size in the kernel virtual mapping area,
- *	and reserved it for out purposes.  Returns the area descriptor
- *	on success or %NULL on failure.
+ * Search an area of @size in the kernel virtual mapping area,
+ * and reserved it for out purposes.  Returns the area descriptor
+ * on success or %NULL on failure.
  */
 struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
 {
@@ -1444,12 +1445,12 @@ struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
 }
 
 /**
- *	find_vm_area  -  find a continuous kernel virtual area
- *	@addr:		base address
+ * find_vm_area - find a continuous kernel virtual area
+ * @addr:	  base address
  *
- *	Search for the kernel VM area starting at @addr, and return it.
- *	It is up to the caller to do all required locking to keep the returned
- *	pointer valid.
+ * Search for the kernel VM area starting at @addr, and return it.
+ * It is up to the caller to do all required locking to keep the returned
+ * pointer valid.
  */
 struct vm_struct *find_vm_area(const void *addr)
 {
@@ -1463,12 +1464,12 @@ struct vm_struct *find_vm_area(const void *addr)
 }
 
 /**
- *	remove_vm_area  -  find and remove a continuous kernel virtual area
- *	@addr:		base address
+ * remove_vm_area - find and remove a continuous kernel virtual area
+ * @addr:	    base address
  *
- *	Search for the kernel VM area starting at @addr, and remove it.
- *	This function returns the found VM area, but using it is NOT safe
- *	on SMP machines, except for its size or flags.
+ * Search for the kernel VM area starting at @addr, and remove it.
+ * This function returns the found VM area, but using it is NOT safe
+ * on SMP machines, except for its size or flags.
  */
 struct vm_struct *remove_vm_area(const void *addr)
 {
@@ -1548,11 +1549,11 @@ static inline void __vfree_deferred(const void *addr)
 }
 
 /**
- *	vfree_atomic  -  release memory allocated by vmalloc()
- *	@addr:		memory base address
+ * vfree_atomic - release memory allocated by vmalloc()
+ * @addr:	  memory base address
  *
- *	This one is just like vfree() but can be called in any atomic context
- *	except NMIs.
+ * This one is just like vfree() but can be called in any atomic context
+ * except NMIs.
  */
 void vfree_atomic(const void *addr)
 {
@@ -1566,20 +1567,20 @@ void vfree_atomic(const void *addr)
 }
 
 /**
- *	vfree  -  release memory allocated by vmalloc()
- *	@addr:		memory base address
+ * vfree - release memory allocated by vmalloc()
+ * @addr:  memory base address
  *
- *	Free the virtually continuous memory area starting at @addr, as
- *	obtained from vmalloc(), vmalloc_32() or __vmalloc(). If @addr is
- *	NULL, no operation is performed.
+ * Free the virtually continuous memory area starting at @addr, as
+ * obtained from vmalloc(), vmalloc_32() or __vmalloc(). If @addr is
+ * NULL, no operation is performed.
  *
- *	Must not be called in NMI context (strictly speaking, only if we don't
- *	have CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG, but making the calling
- *	conventions for vfree() arch-depenedent would be a really bad idea)
+ * Must not be called in NMI context (strictly speaking, only if we don't
+ * have CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG, but making the calling
+ * conventions for vfree() arch-depenedent would be a really bad idea)
  *
- *	May sleep if called *not* from interrupt context.
+ * May sleep if called *not* from interrupt context.
  *
- *	NOTE: assumes that the object at @addr has a size >= sizeof(llist_node)
+ * NOTE: assumes that the object at @addr has a size >= sizeof(llist_node)
  */
 void vfree(const void *addr)
 {
@@ -1599,13 +1600,13 @@ void vfree(const void *addr)
 EXPORT_SYMBOL(vfree);
 
 /**
- *	vunmap  -  release virtual mapping obtained by vmap()
- *	@addr:		memory base address
+ * vunmap - release virtual mapping obtained by vmap()
+ * @addr:   memory base address
  *
- *	Free the virtually contiguous memory area starting at @addr,
- *	which was created from the page array passed to vmap().
+ * Free the virtually contiguous memory area starting at @addr,
+ * which was created from the page array passed to vmap().
  *
- *	Must not be called in interrupt context.
+ * Must not be called in interrupt context.
  */
 void vunmap(const void *addr)
 {
@@ -1617,17 +1618,17 @@ void vunmap(const void *addr)
 EXPORT_SYMBOL(vunmap);
 
 /**
- *	vmap  -  map an array of pages into virtually contiguous space
- *	@pages:		array of page pointers
- *	@count:		number of pages to map
- *	@flags:		vm_area->flags
- *	@prot:		page protection for the mapping
- *
- *	Maps @count pages from @pages into contiguous kernel virtual
- *	space.
+ * vmap - map an array of pages into virtually contiguous space
+ * @pages: array of page pointers
+ * @count: number of pages to map
+ * @flags: vm_area->flags
+ * @prot: page protection for the mapping
+ *
+ * Maps @count pages from @pages into contiguous kernel virtual
+ * space.
  */
 void *vmap(struct page **pages, unsigned int count,
-		unsigned long flags, pgprot_t prot)
+	   unsigned long flags, pgprot_t prot)
 {
 	struct vm_struct *area;
 	unsigned long size;		/* In bytes */
@@ -1714,20 +1715,20 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 }
 
 /**
- *	__vmalloc_node_range  -  allocate virtually contiguous memory
- *	@size:		allocation size
- *	@align:		desired alignment
- *	@start:		vm area range start
- *	@end:		vm area range end
- *	@gfp_mask:	flags for the page level allocator
- *	@prot:		protection mask for the allocated pages
- *	@vm_flags:	additional vm area flags (e.g. %VM_NO_GUARD)
- *	@node:		node to use for allocation or NUMA_NO_NODE
- *	@caller:	caller's return address
- *
- *	Allocate enough pages to cover @size from the page level
- *	allocator with @gfp_mask flags.  Map them into contiguous
- *	kernel virtual space, using a pagetable protection of @prot.
+ * __vmalloc_node_range - allocate virtually contiguous memory
+ * @size:		  allocation size
+ * @align:		  desired alignment
+ * @start:		  vm area range start
+ * @end:		  vm area range end
+ * @gfp_mask:		  flags for the page level allocator
+ * @prot:		  protection mask for the allocated pages
+ * @vm_flags:		  additional vm area flags (e.g. %VM_NO_GUARD)
+ * @node:		  node to use for allocation or NUMA_NO_NODE
+ * @caller:		  caller's return address
+ *
+ * Allocate enough pages to cover @size from the page level
+ * allocator with @gfp_mask flags.  Map them into contiguous
+ * kernel virtual space, using a pagetable protection of @prot.
  */
 void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
@@ -1769,24 +1770,23 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 }
 
 /**
- *	__vmalloc_node  -  allocate virtually contiguous memory
- *	@size:		allocation size
- *	@align:		desired alignment
- *	@gfp_mask:	flags for the page level allocator
- *	@prot:		protection mask for the allocated pages
- *	@node:		node to use for allocation or NUMA_NO_NODE
- *	@caller:	caller's return address
- *
- *	Allocate enough pages to cover @size from the page level
- *	allocator with @gfp_mask flags.  Map them into contiguous
- *	kernel virtual space, using a pagetable protection of @prot.
+ * __vmalloc_node - allocate virtually contiguous memory
+ * @size:	    allocation size
+ * @align:	    desired alignment
+ * @gfp_mask:	    flags for the page level allocator
+ * @prot:	    protection mask for the allocated pages
+ * @node:	    node to use for allocation or NUMA_NO_NODE
+ * @caller:	    caller's return address
  *
- *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_RETRY_MAYFAIL
- *	and __GFP_NOFAIL are not supported
+ * Allocate enough pages to cover @size from the page level
+ * allocator with @gfp_mask flags.  Map them into contiguous
+ * kernel virtual space, using a pagetable protection of @prot.
  *
- *	Any use of gfp flags outside of GFP_KERNEL should be consulted
- *	with mm people.
+ * Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_RETRY_MAYFAIL
+ * and __GFP_NOFAIL are not supported
  *
+ * Any use of gfp flags outside of GFP_KERNEL should be consulted
+ * with mm people.
  */
 static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
@@ -1818,13 +1818,14 @@ void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags,
 }
 
 /**
- *	vmalloc  -  allocate virtually contiguous memory
- *	@size:		allocation size
- *	Allocate enough pages to cover @size from the page level
- *	allocator and map them into contiguous kernel virtual space.
+ * vmalloc - allocate virtually contiguous memory
+ * @size:    allocation size
+ *
+ * Allocate enough pages to cover @size from the page level
+ * allocator and map them into contiguous kernel virtual space.
  *
- *	For tight control over page level allocator and protection flags
- *	use __vmalloc() instead.
+ * For tight control over page level allocator and protection flags
+ * use __vmalloc() instead.
  */
 void *vmalloc(unsigned long size)
 {
@@ -1834,14 +1835,15 @@ void *vmalloc(unsigned long size)
 EXPORT_SYMBOL(vmalloc);
 
 /**
- *	vzalloc - allocate virtually contiguous memory with zero fill
- *	@size:	allocation size
- *	Allocate enough pages to cover @size from the page level
- *	allocator and map them into contiguous kernel virtual space.
- *	The memory allocated is set to zero.
- *
- *	For tight control over page level allocator and protection flags
- *	use __vmalloc() instead.
+ * vzalloc - allocate virtually contiguous memory with zero fill
+ * @size:    allocation size
+ *
+ * Allocate enough pages to cover @size from the page level
+ * allocator and map them into contiguous kernel virtual space.
+ * The memory allocated is set to zero.
+ *
+ * For tight control over page level allocator and protection flags
+ * use __vmalloc() instead.
  */
 void *vzalloc(unsigned long size)
 {
@@ -1875,15 +1877,15 @@ void *vmalloc_user(unsigned long size)
 EXPORT_SYMBOL(vmalloc_user);
 
 /**
- *	vmalloc_node  -  allocate memory on a specific node
- *	@size:		allocation size
- *	@node:		numa node
+ * vmalloc_node - allocate memory on a specific node
+ * @size:	  allocation size
+ * @node:	  numa node
  *
- *	Allocate enough pages to cover @size from the page level
- *	allocator and map them into contiguous kernel virtual space.
+ * Allocate enough pages to cover @size from the page level
+ * allocator and map them into contiguous kernel virtual space.
  *
- *	For tight control over page level allocator and protection flags
- *	use __vmalloc() instead.
+ * For tight control over page level allocator and protection flags
+ * use __vmalloc() instead.
  */
 void *vmalloc_node(unsigned long size, int node)
 {
@@ -1912,17 +1914,16 @@ void *vzalloc_node(unsigned long size, int node)
 EXPORT_SYMBOL(vzalloc_node);
 
 /**
- *	vmalloc_exec  -  allocate virtually contiguous, executable memory
- *	@size:		allocation size
+ * vmalloc_exec - allocate virtually contiguous, executable memory
+ * @size:	  allocation size
  *
- *	Kernel-internal function to allocate enough pages to cover @size
- *	the page level allocator and map them into contiguous and
- *	executable kernel virtual space.
+ * Kernel-internal function to allocate enough pages to cover @size
+ * the page level allocator and map them into contiguous and
+ * executable kernel virtual space.
  *
- *	For tight control over page level allocator and protection flags
- *	use __vmalloc() instead.
+ * For tight control over page level allocator and protection flags
+ * use __vmalloc() instead.
  */
-
 void *vmalloc_exec(unsigned long size)
 {
 	return __vmalloc_node(size, 1, GFP_KERNEL, PAGE_KERNEL_EXEC,
@@ -1942,11 +1943,11 @@ void *vmalloc_exec(unsigned long size)
 #endif
 
 /**
- *	vmalloc_32  -  allocate virtually contiguous memory (32bit addressable)
- *	@size:		allocation size
+ * vmalloc_32 - allocate virtually contiguous memory (32bit addressable)
+ * @size:	allocation size
  *
- *	Allocate enough 32bit PA addressable pages to cover @size from the
- *	page level allocator and map them into contiguous kernel virtual space.
+ * Allocate enough 32bit PA addressable pages to cover @size from the
+ * page level allocator and map them into contiguous kernel virtual space.
  */
 void *vmalloc_32(unsigned long size)
 {
@@ -1957,7 +1958,7 @@ EXPORT_SYMBOL(vmalloc_32);
 
 /**
  * vmalloc_32_user - allocate zeroed virtually contiguous 32bit memory
- *	@size:		allocation size
+ * @size:	     allocation size
  *
  * The resulting memory area is 32bit addressable and zeroed so it can be
  * mapped to userspace without leaking data.
@@ -2059,31 +2060,29 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
 }
 
 /**
- *	vread() -  read vmalloc area in a safe way.
- *	@buf:		buffer for reading data
- *	@addr:		vm address.
- *	@count:		number of bytes to be read.
- *
- *	Returns # of bytes which addr and buf should be increased.
- *	(same number to @count). Returns 0 if [addr...addr+count) doesn't
- *	includes any intersect with alive vmalloc area.
- *
- *	This function checks that addr is a valid vmalloc'ed area, and
- *	copy data from that area to a given buffer. If the given memory range
- *	of [addr...addr+count) includes some valid address, data is copied to
- *	proper area of @buf. If there are memory holes, they'll be zero-filled.
- *	IOREMAP area is treated as memory hole and no copy is done.
- *
- *	If [addr...addr+count) doesn't includes any intersects with alive
- *	vm_struct area, returns 0. @buf should be kernel's buffer.
- *
- *	Note: In usual ops, vread() is never necessary because the caller
- *	should know vmalloc() area is valid and can use memcpy().
- *	This is for routines which have to access vmalloc area without
- *	any informaion, as /dev/kmem.
- *
+ * vread() - read vmalloc area in a safe way.
+ * @buf:     buffer for reading data
+ * @addr:    vm address.
+ * @count:   number of bytes to be read.
+ *
+ * Returns # of bytes which addr and buf should be increased.
+ * (same number to @count). Returns 0 if [addr...addr+count) doesn't
+ * includes any intersect with alive vmalloc area.
+ *
+ * This function checks that addr is a valid vmalloc'ed area, and
+ * copy data from that area to a given buffer. If the given memory range
+ * of [addr...addr+count) includes some valid address, data is copied to
+ * proper area of @buf. If there are memory holes, they'll be zero-filled.
+ * IOREMAP area is treated as memory hole and no copy is done.
+ *
+ * If [addr...addr+count) doesn't includes any intersects with alive
+ * vm_struct area, returns 0. @buf should be kernel's buffer.
+ *
+ * Note: In usual ops, vread() is never necessary because the caller
+ * should know vmalloc() area is valid and can use memcpy().
+ * This is for routines which have to access vmalloc area without
+ * any informaion, as /dev/kmem.
  */
-
 long vread(char *buf, char *addr, unsigned long count)
 {
 	struct vmap_area *va;
@@ -2140,31 +2139,30 @@ long vread(char *buf, char *addr, unsigned long count)
 }
 
 /**
- *	vwrite() -  write vmalloc area in a safe way.
- *	@buf:		buffer for source data
- *	@addr:		vm address.
- *	@count:		number of bytes to be read.
- *
- *	Returns # of bytes which addr and buf should be incresed.
- *	(same number to @count).
- *	If [addr...addr+count) doesn't includes any intersect with valid
- *	vmalloc area, returns 0.
- *
- *	This function checks that addr is a valid vmalloc'ed area, and
- *	copy data from a buffer to the given addr. If specified range of
- *	[addr...addr+count) includes some valid address, data is copied from
- *	proper area of @buf. If there are memory holes, no copy to hole.
- *	IOREMAP area is treated as memory hole and no copy is done.
- *
- *	If [addr...addr+count) doesn't includes any intersects with alive
- *	vm_struct area, returns 0. @buf should be kernel's buffer.
- *
- *	Note: In usual ops, vwrite() is never necessary because the caller
- *	should know vmalloc() area is valid and can use memcpy().
- *	This is for routines which have to access vmalloc area without
- *	any informaion, as /dev/kmem.
+ * vwrite() - write vmalloc area in a safe way.
+ * @buf:      buffer for source data
+ * @addr:     vm address.
+ * @count:    number of bytes to be read.
+ *
+ * Returns # of bytes which addr and buf should be incresed.
+ * (same number to @count).
+ * If [addr...addr+count) doesn't includes any intersect with valid
+ * vmalloc area, returns 0.
+ *
+ * This function checks that addr is a valid vmalloc'ed area, and
+ * copy data from a buffer to the given addr. If specified range of
+ * [addr...addr+count) includes some valid address, data is copied from
+ * proper area of @buf. If there are memory holes, no copy to hole.
+ * IOREMAP area is treated as memory hole and no copy is done.
+ *
+ * If [addr...addr+count) doesn't includes any intersects with alive
+ * vm_struct area, returns 0. @buf should be kernel's buffer.
+ *
+ * Note: In usual ops, vwrite() is never necessary because the caller
+ * should know vmalloc() area is valid and can use memcpy().
+ * This is for routines which have to access vmalloc area without
+ * any informaion, as /dev/kmem.
  */
-
 long vwrite(char *buf, char *addr, unsigned long count)
 {
 	struct vmap_area *va;
@@ -2216,20 +2214,20 @@ long vwrite(char *buf, char *addr, unsigned long count)
 }
 
 /**
- *	remap_vmalloc_range_partial  -  map vmalloc pages to userspace
- *	@vma:		vma to cover
- *	@uaddr:		target user address to start at
- *	@kaddr:		virtual address of vmalloc kernel memory
- *	@size:		size of map area
+ * remap_vmalloc_range_partial - map vmalloc pages to userspace
+ * @vma:		vma to cover
+ * @uaddr:		target user address to start at
+ * @kaddr:		virtual address of vmalloc kernel memory
+ * @size:		size of map area
  *
- *	Returns:	0 for success, -Exxx on failure
+ * Returns:	0 for success, -Exxx on failure
  *
- *	This function checks that @kaddr is a valid vmalloc'ed area,
- *	and that it is big enough to cover the range starting at
- *	@uaddr in @vma. Will return failure if that criteria isn't
- *	met.
+ * This function checks that @kaddr is a valid vmalloc'ed area,
+ * and that it is big enough to cover the range starting at
+ * @uaddr in @vma. Will return failure if that criteria isn't
+ * met.
  *
- *	Similar to remap_pfn_range() (see mm/memory.c)
+ * Similar to remap_pfn_range() (see mm/memory.c)
  */
 int remap_vmalloc_range_partial(struct vm_area_struct *vma, unsigned long uaddr,
 				void *kaddr, unsigned long size)
@@ -2271,18 +2269,18 @@ int remap_vmalloc_range_partial(struct vm_area_struct *vma, unsigned long uaddr,
 EXPORT_SYMBOL(remap_vmalloc_range_partial);
 
 /**
- *	remap_vmalloc_range  -  map vmalloc pages to userspace
- *	@vma:		vma to cover (map full range of vma)
- *	@addr:		vmalloc memory
- *	@pgoff:		number of pages into addr before first page to map
+ * remap_vmalloc_range - map vmalloc pages to userspace
+ * @vma:		vma to cover (map full range of vma)
+ * @addr:		vmalloc memory
+ * @pgoff:		number of pages into addr before first page to map
  *
- *	Returns:	0 for success, -Exxx on failure
+ * Returns:	0 for success, -Exxx on failure
  *
- *	This function checks that addr is a valid vmalloc'ed area, and
- *	that it is big enough to cover the vma. Will return failure if
- *	that criteria isn't met.
+ * This function checks that addr is a valid vmalloc'ed area, and
+ * that it is big enough to cover the vma. Will return failure if
+ * that criteria isn't met.
  *
- *	Similar to remap_pfn_range() (see mm/memory.c)
+ * Similar to remap_pfn_range() (see mm/memory.c)
  */
 int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 						unsigned long pgoff)
@@ -2314,18 +2312,18 @@ static int f(pte_t *pte, pgtable_t table, unsigned long addr, void *data)
 }
 
 /**
- *	alloc_vm_area - allocate a range of kernel address space
- *	@size:		size of the area
- *	@ptes:		returns the PTEs for the address space
+ * alloc_vm_area - allocate a range of kernel address space
+ * @size:	   size of the area
+ * @ptes:	   returns the PTEs for the address space
  *
- *	Returns:	NULL on failure, vm_struct on success
+ * Returns:	NULL on failure, vm_struct on success
  *
- *	This function reserves a range of kernel address space, and
- *	allocates pagetables to map that range.  No actual mappings
- *	are created.
+ * This function reserves a range of kernel address space, and
+ * allocates pagetables to map that range.  No actual mappings
+ * are created.
  *
- *	If @ptes is non-NULL, pointers to the PTEs (in init_mm)
- *	allocated for the VM area are returned.
+ * If @ptes is non-NULL, pointers to the PTEs (in init_mm)
+ * allocated for the VM area are returned.
  */
 struct vm_struct *alloc_vm_area(size_t size, pte_t **ptes)
 {
@@ -2751,4 +2749,3 @@ static int __init proc_vmalloc_init(void)
 module_init(proc_vmalloc_init);
 
 #endif
-
-- 
2.7.4
