Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E58E46B0273
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u1-v6so3168925wrs.18
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 07:55:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h11-v6si2491152wri.460.2018.06.30.07.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 07:55:36 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5UErZfA124525
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:35 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jx5v4t9j5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:35 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 30 Jun 2018 15:55:33 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 08/11] docs/mm: memblock: add kernel-doc comments for memblock_add[_node]
Date: Sat, 30 Jun 2018 17:55:03 +0300
In-Reply-To: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530370506-21751-9-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/memblock.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 8159869..3e6be01 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -595,12 +595,35 @@ int __init_memblock memblock_add_range(struct memblock_type *type,
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
@@ -1464,9 +1487,9 @@ void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
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
