Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D32626B0008
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s21-v6so3689501edq.23
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 07:55:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h32-v6si3436372eda.150.2018.06.30.07.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 07:55:23 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5UErV5S126276
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:21 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jx5xvacqx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:21 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 30 Jun 2018 15:55:18 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 02/11] docs/mm: nobootmem: fixup kernel-doc comments
Date: Sat, 30 Jun 2018 17:54:57 +0300
In-Reply-To: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530370506-21751-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

* add kernel-doc marking to free_bootmem_late() description
* add return value descriptions
* mention that address parameter of free_bootmem{_node} is a physical address

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/nobootmem.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 9b02fda..c2cfa04 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -72,7 +72,7 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 	return ptr;
 }
 
-/*
+/**
  * free_bootmem_late - free bootmem pages directly to page allocator
  * @addr: starting address of the range
  * @size: size of the range in bytes
@@ -176,7 +176,7 @@ void __init reset_all_zones_managed_pages(void)
 /**
  * free_all_bootmem - release free pages to the buddy allocator
  *
- * Returns the number of pages actually released.
+ * Return: the number of pages actually released.
  */
 unsigned long __init free_all_bootmem(void)
 {
@@ -193,7 +193,7 @@ unsigned long __init free_all_bootmem(void)
 /**
  * free_bootmem_node - mark a page range as usable
  * @pgdat: node the range resides on
- * @physaddr: starting address of the range
+ * @physaddr: starting physical address of the range
  * @size: size of the range in bytes
  *
  * Partial pages will be considered reserved and left as they are.
@@ -208,7 +208,7 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 
 /**
  * free_bootmem - mark a page range as usable
- * @addr: starting address of the range
+ * @addr: starting physical address of the range
  * @size: size of the range in bytes
  *
  * Partial pages will be considered reserved and left as they are.
@@ -256,7 +256,7 @@ static void * __init ___alloc_bootmem_nopanic(unsigned long size,
  *
  * Allocation may happen on any node in the system.
  *
- * Returns NULL on failure.
+ * Return: address of the allocated region or %NULL on failure.
  */
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 					unsigned long goal)
@@ -293,6 +293,8 @@ static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
  * Allocation may happen on any node in the system.
  *
  * The function panics if the request can not be satisfied.
+ *
+ * Return: address of the allocated region.
  */
 void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 			      unsigned long goal)
@@ -367,6 +369,8 @@ static void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
  * can not hold the requested memory.
  *
  * The function panics if the request can not be satisfied.
+ *
+ * Return: address of the allocated region.
  */
 void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
@@ -396,6 +400,8 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
  * Allocation may happen on any node in the system.
  *
  * The function panics if the request can not be satisfied.
+ *
+ * Return: address of the allocated region.
  */
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 				  unsigned long goal)
@@ -425,6 +431,8 @@ void * __init __alloc_bootmem_low_nopanic(unsigned long size,
  * can not hold the requested memory.
  *
  * The function panics if the request can not be satisfied.
+ *
+ * Return: address of the allocated region.
  */
 void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
 				       unsigned long align, unsigned long goal)
-- 
2.7.4
