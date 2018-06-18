Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8776B000D
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j14-v6so12393353wrq.4
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:00:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 68-v6si1488433wra.360.2018.06.18.10.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:00:18 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwsMV046055
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:16 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jpfx8t58e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:15 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 18 Jun 2018 18:00:13 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 03/11] docs/mm: bootmem: fix kernel-doc warnings
Date: Mon, 18 Jun 2018 19:59:51 +0300
In-Reply-To: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1529341199-17682-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Add descriptions of the return value where they were missing and fixup the
syntax for present ones.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/bootmem.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 42ab0da..76fc17e 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -62,6 +62,8 @@ static unsigned long __init bootmap_bytes(unsigned long pages)
 /**
  * bootmem_bootmap_pages - calculate bitmap size in pages
  * @pages: number of pages the bitmap has to represent
+ *
+ * Return: the number of pages needed to hold the bitmap.
  */
 unsigned long __init bootmem_bootmap_pages(unsigned long pages)
 {
@@ -121,7 +123,7 @@ static unsigned long __init init_bootmem_core(bootmem_data_t *bdata,
  * @startpfn: first pfn on the node
  * @endpfn: first pfn after the node
  *
- * Returns the number of bytes needed to hold the bitmap for this node.
+ * Return: the number of bytes needed to hold the bitmap for this node.
  */
 unsigned long __init init_bootmem_node(pg_data_t *pgdat, unsigned long freepfn,
 				unsigned long startpfn, unsigned long endpfn)
@@ -134,7 +136,7 @@ unsigned long __init init_bootmem_node(pg_data_t *pgdat, unsigned long freepfn,
  * @start: pfn where the bitmap is to be placed
  * @pages: number of available physical pages
  *
- * Returns the number of bytes needed to hold the bitmap.
+ * Return: the number of bytes needed to hold the bitmap.
  */
 unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
 {
@@ -406,6 +408,8 @@ void __init free_bootmem(unsigned long physaddr, unsigned long size)
  * Partial pages will be reserved.
  *
  * The range must reside completely on the specified node.
+ *
+ * Return: 0 on success, -errno on failure.
  */
 int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 				 unsigned long size, int flags)
@@ -427,6 +431,8 @@ int __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
  * Partial pages will be reserved.
  *
  * The range must be contiguous but may span node boundaries.
+ *
+ * Return: 0 on success, -errno on failure.
  */
 int __init reserve_bootmem(unsigned long addr, unsigned long size,
 			    int flags)
-- 
2.7.4
