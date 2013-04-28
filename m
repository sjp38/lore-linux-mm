Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 167F26B0044
	for <linux-mm@kvack.org>; Sun, 28 Apr 2013 15:37:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 29 Apr 2013 01:03:18 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 4FA44394005A
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:46 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3SJbfsR52625468
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 01:07:41 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3SJbjSa003187
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 05:37:45 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V7 10/18] powerpc: Reduce the PTE_INDEX_SIZE
Date: Mon, 29 Apr 2013 01:07:31 +0530
Message-Id: <1367177859-7893-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, dwg@au1.ibm.com, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This make one PMD cover 16MB range. That helps in easier implementation of THP
on power. THP core code make use of one pmd entry to track the hugepage and
the range mapped by a single pmd entry should be equal to the hugepage size
supported by the hardware.

This also switch PGD to cover 16GB. That is needed so that we can simplify the
hugetlb page walking code so that we have same pte format for explicit hugepage
and THP hugepage.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64-64k.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64-64k.h b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
index be4e287..45142d6 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64-64k.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
@@ -4,10 +4,10 @@
 #include <asm-generic/pgtable-nopud.h>
 
 
-#define PTE_INDEX_SIZE  12
-#define PMD_INDEX_SIZE  12
+#define PTE_INDEX_SIZE  8
+#define PMD_INDEX_SIZE  10
 #define PUD_INDEX_SIZE	0
-#define PGD_INDEX_SIZE  6
+#define PGD_INDEX_SIZE  12
 
 #ifndef __ASSEMBLY__
 #define PTE_TABLE_SIZE	(sizeof(real_pte_t) << PTE_INDEX_SIZE)
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
