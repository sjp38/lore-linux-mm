Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 437DE6B026A
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:33 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4-v6so5449421wmh.0
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:00:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f10-v6si425596wmh.212.2018.06.18.10.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:00:31 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwsMQ077005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:30 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jpence173-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:25 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 18 Jun 2018 18:00:23 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 08/11] docs/mm: memblock: add kernel-doc comments for memblock_add[_node]
Date: Mon, 18 Jun 2018 19:59:56 +0300
In-Reply-To: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1529341199-17682-9-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/memblock.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 3d6deff..c4838a9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -594,12 +594,35 @@ int __init_memblock memblock_add_range(struct memblock_type *type,
 	}
 }
 
+/**
+ * memblock_add_node - add new memblock region within a NUMA node
+ * @base: base address of the new region
+ * @size: size of the new region
+ * @nid: nid of the new region
+ *
+ * Add new memblock region [@base, @base + @size) to the "memory"
+ * type. See memblock_add_range() description for mode details
+ *
+ * Return:
+ * 0 on success, -errno on failure.
+ */
 int __init_memblock memblock_add_node(phys_addr_t base, phys_addr_t size,
 				       int nid)
 {
 	return memblock_add_range(&memblock.memory, base, size, nid, 0);
 }
 
+/**
+ * memblock_add - add new memblock region
+ * @base: base address of the new region
+ * @size: size of the new region
+ *
+ * Add new memblock region [@base, @base + @size) to the "memory"
+ * type. See memblock_add_range() description for mode details
+ *
+ * Return:
+ * 0 on success, -errno on failure.
+ */
 int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
 {
 	phys_addr_t end = base + size - 1;
@@ -1458,9 +1481,9 @@ void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
 	memblock_remove_range(&memblock.reserved, base, size);
 }
 
-/*
+/**
  * __memblock_free_late - free bootmem block pages directly to buddy allocator
- * @addr: phys starting address of the  boot memory block
+ * @base: phys starting address of the  boot memory block
  * @size: size of the boot memory block in bytes
  *
  * This is only useful when the bootmem allocator has already been torn
-- 
2.7.4
