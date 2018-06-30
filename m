Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 489D06B0005
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c12-v6so6252373wrs.13
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 07:55:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w206-v6si3151581wma.11.2018.06.30.07.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jun 2018 07:55:19 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5UErW3a050163
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:18 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jx60wj94m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 10:55:18 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 30 Jun 2018 15:55:16 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 01/11] mm/bootmem: drop duplicated kernel-doc comments
Date: Sat, 30 Jun 2018 17:54:56 +0300
In-Reply-To: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1530370506-21751-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Parts of the bootmem interfaces are duplicated in nobootmem.c along with
the kernel-doc comments. There is no point to keep two copies of the
comments, so let's drop the bootmem.c copy.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/bootmem.c | 102 -----------------------------------------------------------
 1 file changed, 102 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 9e19798..42ab0da 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -143,15 +143,6 @@ unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
 	return init_bootmem_core(NODE_DATA(0)->bdata, start, 0, pages);
 }
 
-/*
- * free_bootmem_late - free bootmem pages directly to page allocator
- * @addr: starting physical address of the range
- * @size: size of the range in bytes
- *
- * This is only useful when the bootmem allocator has already been torn
- * down, but we are still initializing the system.  Pages are given directly
- * to the page allocator, no bootmem metadata is updated because it is gone.
- */
 void __init free_bootmem_late(unsigned long physaddr, unsigned long size)
 {
 	unsigned long cursor, end;
@@ -264,11 +255,6 @@ void __init reset_all_zones_managed_pages(void)
 	reset_managed_pages_done = 1;
 }
 
-/**
- * free_all_bootmem - release free pages to the buddy allocator
- *
- * Returns the number of pages actually released.
- */
 unsigned long __init free_all_bootmem(void)
 {
 	unsigned long total_pages = 0;
@@ -385,16 +371,6 @@ static int __init mark_bootmem(unsigned long start, unsigned long end,
 	BUG();
 }
 
-/**
- * free_bootmem_node - mark a page range as usable
- * @pgdat: node the range resides on
- * @physaddr: starting address of the range
- * @size: size of the range in bytes
- *
- * Partial pages will be considered reserved and left as they are.
- *
- * The range must reside completely on the specified node.
- */
 void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 			      unsigned long size)
 {
@@ -408,15 +384,6 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 	mark_bootmem_node(pgdat->bdata, start, end, 0, 0);
 }
 
-/**
- * free_bootmem - mark a page range as usable
- * @physaddr: starting physical address of the range
- * @size: size of the range in bytes
- *
- * Partial pages will be considered reserved and left as they are.
- *
- * The range must be contiguous but may span node boundaries.
- */
 void __init free_bootmem(unsigned long physaddr, unsigned long size)
 {
 	unsigned long start, end;
@@ -646,19 +613,6 @@ static void * __init ___alloc_bootmem_nopanic(unsigned long size,
 	return NULL;
 }
 
-/**
- * __alloc_bootmem_nopanic - allocate boot memory without panicking
- * @size: size of the request in bytes
- * @align: alignment of the region
- * @goal: preferred starting address of the region
- *
- * The goal is dropped if it can not be satisfied and the allocation will
- * fall back to memory below @goal.
- *
- * Allocation may happen on any node in the system.
- *
- * Returns NULL on failure.
- */
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 					unsigned long goal)
 {
@@ -682,19 +636,6 @@ static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
 	return NULL;
 }
 
-/**
- * __alloc_bootmem - allocate boot memory
- * @size: size of the request in bytes
- * @align: alignment of the region
- * @goal: preferred starting address of the region
- *
- * The goal is dropped if it can not be satisfied and the allocation will
- * fall back to memory below @goal.
- *
- * Allocation may happen on any node in the system.
- *
- * The function panics if the request can not be satisfied.
- */
 void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 			      unsigned long goal)
 {
@@ -754,21 +695,6 @@ void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 	return NULL;
 }
 
-/**
- * __alloc_bootmem_node - allocate boot memory from a specific node
- * @pgdat: node to allocate from
- * @size: size of the request in bytes
- * @align: alignment of the region
- * @goal: preferred starting address of the region
- *
- * The goal is dropped if it can not be satisfied and the allocation will
- * fall back to memory below @goal.
- *
- * Allocation may fall back to any node in the system if the specified node
- * can not hold the requested memory.
- *
- * The function panics if the request can not be satisfied.
- */
 void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
@@ -807,19 +733,6 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 
 }
 
-/**
- * __alloc_bootmem_low - allocate low boot memory
- * @size: size of the request in bytes
- * @align: alignment of the region
- * @goal: preferred starting address of the region
- *
- * The goal is dropped if it can not be satisfied and the allocation will
- * fall back to memory below @goal.
- *
- * Allocation may happen on any node in the system.
- *
- * The function panics if the request can not be satisfied.
- */
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 				  unsigned long goal)
 {
@@ -834,21 +747,6 @@ void * __init __alloc_bootmem_low_nopanic(unsigned long size,
 					ARCH_LOW_ADDRESS_LIMIT);
 }
 
-/**
- * __alloc_bootmem_low_node - allocate low boot memory from a specific node
- * @pgdat: node to allocate from
- * @size: size of the request in bytes
- * @align: alignment of the region
- * @goal: preferred starting address of the region
- *
- * The goal is dropped if it can not be satisfied and the allocation will
- * fall back to memory below @goal.
- *
- * Allocation may fall back to any node in the system if the specified node
- * can not hold the requested memory.
- *
- * The function panics if the request can not be satisfied.
- */
 void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
 				       unsigned long align, unsigned long goal)
 {
-- 
2.7.4
