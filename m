Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFE0C6B0269
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k18-v6so12031216wrn.8
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:00:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 60-v6si12600227wri.64.2018.06.18.10.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:00:29 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwscI182643
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:28 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jpde7h965-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:28 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 18 Jun 2018 18:00:26 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 09/11] docs/mm: memblock: add kernel-doc description for memblock types
Date: Mon, 18 Jun 2018 19:59:57 +0300
In-Reply-To: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1529341199-17682-10-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/memblock.h | 37 +++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 63704c6..5169205 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -20,7 +20,13 @@
 #define INIT_MEMBLOCK_REGIONS	128
 #define INIT_PHYSMEM_REGIONS	4
 
-/* Definition of memblock flags. */
+/**
+ * enum memblock_flags - definition of memory region attributes
+ * @MEMBLOCK_NONE: no special request
+ * @MEMBLOCK_HOTPLUG: hotpluggable region
+ * @MEMBLOCK_MIRROR: mirrored region
+ * @MEMBLOCK_NOMAP: don't add to kernel direct mapping
+ */
 enum memblock_flags {
 	MEMBLOCK_NONE		= 0x0,	/* No special request */
 	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
@@ -28,6 +34,13 @@ enum memblock_flags {
 	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
 };
 
+/**
+ * struct memblock_region - represents a memory region
+ * @base: physical address of the region
+ * @size: size of the region
+ * @flags: memory region attributes
+ * @nid: NUMA node id
+ */
 struct memblock_region {
 	phys_addr_t base;
 	phys_addr_t size;
@@ -37,14 +50,30 @@ struct memblock_region {
 #endif
 };
 
+/**
+ * struct memblock_type - collection of memory regions of certain type
+ * @cnt: number of regions
+ * @max: size of the allocated array
+ * @total_size: size of all regions
+ * @regions: array of regions
+ * @name: the memory type symbolic name
+ */
 struct memblock_type {
-	unsigned long cnt;	/* number of regions */
-	unsigned long max;	/* size of the allocated array */
-	phys_addr_t total_size;	/* size of all regions */
+	unsigned long cnt;
+	unsigned long max;
+	phys_addr_t total_size;
 	struct memblock_region *regions;
 	char *name;
 };
 
+/**
+ * struct memblock - memblock allocator metadata
+ * @bottom_up: is bottom up direction?
+ * @current_limit: physical address of the current allocation limit
+ * @memory: usabe memory regions
+ * @reserved: reserved memory regions
+ * @physmem: all physical memory
+ */
 struct memblock {
 	bool bottom_up;  /* is bottom up direction? */
 	phys_addr_t current_limit;
-- 
2.7.4
