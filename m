Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 195068E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:11:42 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v4-v6so9331628oix.2
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:11:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i7-v6si3433296oib.262.2018.09.14.05.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:11:40 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC5NN4006137
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:11:40 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgb9y3svm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:11:39 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:11:36 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 05/30] mm: nobootmem: remove dead code
Date: Fri, 14 Sep 2018 15:10:20 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-6-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

Several bootmem functions and macros are not used. Remove them.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/bootmem.h | 26 --------------------------
 mm/nobootmem.c          | 35 -----------------------------------
 2 files changed, 61 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index fce6278..b74bafd1 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -36,17 +36,6 @@ extern void free_bootmem_node(pg_data_t *pgdat,
 extern void free_bootmem(unsigned long physaddr, unsigned long size);
 extern void free_bootmem_late(unsigned long physaddr, unsigned long size);
 
-/*
- * Flags for reserve_bootmem (also if CONFIG_HAVE_ARCH_BOOTMEM_NODE,
- * the architecture-specific code should honor this).
- *
- * If flags is BOOTMEM_DEFAULT, then the return value is always 0 (success).
- * If flags contains BOOTMEM_EXCLUSIVE, then -EBUSY is returned if the memory
- * already was reserved.
- */
-#define BOOTMEM_DEFAULT		0
-#define BOOTMEM_EXCLUSIVE	(1<<0)
-
 extern void *__alloc_bootmem(unsigned long size,
 			     unsigned long align,
 			     unsigned long goal);
@@ -73,13 +62,6 @@ void *___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
 extern void *__alloc_bootmem_low(unsigned long size,
 				 unsigned long align,
 				 unsigned long goal) __malloc;
-void *__alloc_bootmem_low_nopanic(unsigned long size,
-				 unsigned long align,
-				 unsigned long goal) __malloc;
-extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
-				      unsigned long size,
-				      unsigned long align,
-				      unsigned long goal) __malloc;
 
 /* We are using top down, so it is safe to use 0 here */
 #define BOOTMEM_LOW_LIMIT 0
@@ -92,8 +74,6 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
 #define alloc_bootmem_align(x, align) \
 	__alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)
-#define alloc_bootmem_nopanic(x) \
-	__alloc_bootmem_nopanic(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
 #define alloc_bootmem_pages(x) \
 	__alloc_bootmem(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
 #define alloc_bootmem_pages_nopanic(x) \
@@ -104,17 +84,11 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 	__alloc_bootmem_node_nopanic(pgdat, x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
 #define alloc_bootmem_pages_node(pgdat, x) \
 	__alloc_bootmem_node(pgdat, x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
-#define alloc_bootmem_pages_node_nopanic(pgdat, x) \
-	__alloc_bootmem_node_nopanic(pgdat, x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
 
 #define alloc_bootmem_low(x) \
 	__alloc_bootmem_low(x, SMP_CACHE_BYTES, 0)
-#define alloc_bootmem_low_pages_nopanic(x) \
-	__alloc_bootmem_low_nopanic(x, PAGE_SIZE, 0)
 #define alloc_bootmem_low_pages(x) \
 	__alloc_bootmem_low(x, PAGE_SIZE, 0)
-#define alloc_bootmem_low_pages_node(pgdat, x) \
-	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
 
 /* FIXME: use MEMBLOCK_ALLOC_* variants here */
 #define BOOTMEM_ALLOC_ACCESSIBLE	0
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index d4d0cd4..44ce7de 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -404,38 +404,3 @@ void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 {
 	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
 }
-
-void * __init __alloc_bootmem_low_nopanic(unsigned long size,
-					  unsigned long align,
-					  unsigned long goal)
-{
-	return ___alloc_bootmem_nopanic(size, align, goal,
-					ARCH_LOW_ADDRESS_LIMIT);
-}
-
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
- *
- * Return: address of the allocated region.
- */
-void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
-				       unsigned long align, unsigned long goal)
-{
-	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
-
-	return ___alloc_bootmem_node(pgdat, size, align, goal,
-				     ARCH_LOW_ADDRESS_LIMIT);
-}
-- 
2.7.4
