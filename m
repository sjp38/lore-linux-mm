Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBHHABSn003220
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 12:10:11 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBHH9u86188506
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 12:10:11 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBHH9j9j017210
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 12:09:45 -0500
Subject: [patch] kill off ARCH_HAS_ATOMIC_UNSIGNED
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 17 Dec 2004 09:09:34 -0800
Message-Id: <E1CfLbi-0005Tu-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Andi says that we don't need this on x86_64 any more.  Since it
is the only user, let's kill it off completely.  BTW, this now
makes 4 free bytes of space in page->flags for all 64-bit
architectures to use.  

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 apw2-dave/include/asm-x86_64/bitops.h |    2 --
 apw2-dave/include/linux/mm.h          |    4 ----
 apw2-dave/include/linux/mmzone.h      |    2 +-
 3 files changed, 1 insertion(+), 7 deletions(-)

diff -puN arch/x86_64/Kconfig~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED arch/x86_64/Kconfig
diff -puN include/linux/mm.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED include/linux/mm.h
--- apw2/include/linux/mm.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-16 16:29:29.000000000 -0800
+++ apw2-dave/include/linux/mm.h	2004-12-17 08:05:13.000000000 -0800
@@ -216,11 +216,7 @@ struct vm_operations_struct {
 struct mmu_gather;
 struct inode;
 
-#ifdef ARCH_HAS_ATOMIC_UNSIGNED
-typedef unsigned page_flags_t;
-#else
 typedef unsigned long page_flags_t;
-#endif
 
 /*
  * Each physical page in the system has a struct page associated with
diff -puN include/linux/mmzone.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED include/linux/mmzone.h
--- apw2/include/linux/mmzone.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-16 16:29:29.000000000 -0800
+++ apw2-dave/include/linux/mmzone.h	2004-12-17 08:05:30.000000000 -0800
@@ -388,7 +388,7 @@ extern struct pglist_data contig_page_da
 
 #include <asm/mmzone.h>
 
-#if BITS_PER_LONG == 32 || defined(ARCH_HAS_ATOMIC_UNSIGNED)
+#if BITS_PER_LONG == 32
 /*
  * with 32 bit page->flags field, we reserve 8 bits for node/zone info.
  * there are 3 zones (2 bits) and this leaves 8-2=6 bits for nodes.
diff -puN include/asm-x86_64/bitops.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED include/asm-x86_64/bitops.h
--- apw2/include/asm-x86_64/bitops.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-16 16:32:42.000000000 -0800
+++ apw2-dave/include/asm-x86_64/bitops.h	2004-12-17 08:05:47.000000000 -0800
@@ -411,8 +411,6 @@ static __inline__ int ffs(int x)
 /* find last set bit */
 #define fls(x) generic_fls(x)
 
-#define ARCH_HAS_ATOMIC_UNSIGNED 1
-
 #endif /* __KERNEL__ */
 
 #endif /* _X86_64_BITOPS_H */
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
