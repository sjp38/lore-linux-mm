Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 470366B0012
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 03:05:53 -0500 (EST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Feb 2013 18:00:02 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id C76332BB0055
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:33 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1Q7qvHs9896258
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 18:52:57 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1Q85Xjt007565
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 19:05:33 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V1 04/24] powerpc: Reduce the PTE_INDEX_SIZE
Date: Tue, 26 Feb 2013 13:34:54 +0530
Message-Id: <1361865914-13911-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This make one PMD cover 16MB range. That helps in easier implementation of THP
on power. THP core code make use of one pmd entry to track the huge page and
the range mapped by a single pmd entry should be equal to the huge page size
supported by the hardware.

Acked-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64-64k.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64-64k.h b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
index be4e287..3c529b4 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64-64k.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
@@ -4,10 +4,10 @@
 #include <asm-generic/pgtable-nopud.h>
 
 
-#define PTE_INDEX_SIZE  12
+#define PTE_INDEX_SIZE  8
 #define PMD_INDEX_SIZE  12
 #define PUD_INDEX_SIZE	0
-#define PGD_INDEX_SIZE  6
+#define PGD_INDEX_SIZE  10
 
 #ifndef __ASSEMBLY__
 #define PTE_TABLE_SIZE	(sizeof(real_pte_t) << PTE_INDEX_SIZE)
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
