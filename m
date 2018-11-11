Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0168A6B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 11:48:57 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id g24-v6so5779994pfi.23
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 08:48:56 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n33si12987302pgl.336.2018.11.11.08.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Nov 2018 08:48:55 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wABGjJOT088949
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 11:48:54 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2npd75vxce-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 11:48:54 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 11 Nov 2018 16:48:52 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] docs/mm: update kmalloc kernel-doc description
Date: Sun, 11 Nov 2018 18:48:44 +0200
Message-Id: <1541954924-21471-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>

Add references to GFP documentation and the memory-allocation.rst and remove
GFP_USER, GFP_DMA and GFP_NOIO descriptions.

While on it slightly change the formatting so that the list of GFP flags
will be rendered as "description" in the generated html.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---

Probably this should go via the -mm tree as it touches include/linux/slab.h

 Documentation/core-api/memory-allocation.rst |  2 +
 include/linux/slab.h                         | 55 ++++++++++++++--------------
 2 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/Documentation/core-api/memory-allocation.rst b/Documentation/core-api/memory-allocation.rst
index f8bb9aa..39f35eb 100644
--- a/Documentation/core-api/memory-allocation.rst
+++ b/Documentation/core-api/memory-allocation.rst
@@ -1,3 +1,5 @@
+.. _memory_allocation:
+
 =======================
 Memory Allocation Guide
 =======================
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 918f374..4a342eb 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -486,48 +486,47 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
  * kmalloc is the normal method of allocating memory
  * for objects smaller than page size in the kernel.
  *
- * The @flags argument may be one of:
+ * The @flags argument may be one of the GFP flags defined at
+ * include/linux/gfp.h and described at
+ * :ref:`Documentation/core-api/mm-api.rst <mm-api-gfp-flags>`
  *
- * %GFP_USER - Allocate memory on behalf of user.  May sleep.
+ * The recommended usage of the @flags is described at
+ * :ref:`Documentation/core-api/memory-allocation.rst <memory_allocation>`
  *
- * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
+ * Below is a brief outline of the most useful GFP flags
  *
- * %GFP_ATOMIC - Allocation will not sleep.  May use emergency pools.
- *   For example, use this inside interrupt handlers.
+ * %GFP_KERNEL
+ *	Allocate normal kernel ram. May sleep.
  *
- * %GFP_HIGHUSER - Allocate pages from high memory.
+ * %GFP_NOWAIT
+ *	Allocation will not sleep.
  *
- * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
+ * %GFP_ATOMIC
+ *	Allocation will not sleep.  May use emergency pools.
  *
- * %GFP_NOFS - Do not make any fs calls while trying to get memory.
- *
- * %GFP_NOWAIT - Allocation will not sleep.
- *
- * %__GFP_THISNODE - Allocate node-local memory only.
- *
- * %GFP_DMA - Allocation suitable for DMA.
- *   Should only be used for kmalloc() caches. Otherwise, use a
- *   slab created with SLAB_DMA.
+ * %GFP_HIGHUSER
+ *	Allocate memory from high memory on behalf of user.
  *
  * Also it is possible to set different flags by OR'ing
  * in one or more of the following additional @flags:
  *
- * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
- *
- * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
- *   (think twice before using).
+ * %__GFP_HIGH
+ *	This allocation has high priority and may use emergency pools.
  *
- * %__GFP_NORETRY - If memory is not immediately available,
- *   then give up at once.
+ * %__GFP_NOFAIL
+ *	Indicate that this allocation is in no way allowed to fail
+ *	(think twice before using).
  *
- * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
+ * %__GFP_NORETRY
+ *	If memory is not immediately available,
+ *	then give up at once.
  *
- * %__GFP_RETRY_MAYFAIL - Try really hard to succeed the allocation but fail
- *   eventually.
+ * %__GFP_NOWARN
+ *	If allocation fails, don't issue any warnings.
  *
- * There are other flags available as well, but these are not intended
- * for general use, and so are not documented here. For a full list of
- * potential flags, always refer to linux/gfp.h.
+ * %__GFP_RETRY_MAYFAIL
+ *	Try really hard to succeed the allocation but fail
+ *	eventually.
  */
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
-- 
2.7.4
