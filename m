Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B52076B000A
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b12-v6so12185098wrs.10
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:00:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h2-v6si2786095wmg.141.2018.06.18.10.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:00:16 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5IGwstt074224
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:14 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jpe6qqa0t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:00:14 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 18 Jun 2018 18:00:11 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 02/11] docs/mm: nobootmem: fixup kernel-doc comments
Date: Mon, 18 Jun 2018 19:59:50 +0300
In-Reply-To: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1529341199-17682-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

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
