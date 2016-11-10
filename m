Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6B76B028C
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:29:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n85so100050140pfi.4
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:29:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id ze5si3200284pac.262.2016.11.10.01.29.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 01:29:36 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAA9T5PG007710
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:29:36 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26me9rksh8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:29:35 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 10 Nov 2016 04:29:34 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/4] powerpc/mm: Rename hugetlb-radix.h to hugetlb.h
Date: Thu, 10 Nov 2016 14:59:16 +0530
In-Reply-To: <20161110092918.21139-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161110092918.21139-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20161110092918.21139-2-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will start moving some book3s specific hugetlb functions there.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/{hugetlb-radix.h => hugetlb.h} | 6 ++++--
 arch/powerpc/include/asm/hugetlb.h                                | 2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)
 rename arch/powerpc/include/asm/book3s/64/{hugetlb-radix.h => hugetlb.h} (84%)

diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb-radix.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
similarity index 84%
rename from arch/powerpc/include/asm/book3s/64/hugetlb-radix.h
rename to arch/powerpc/include/asm/book3s/64/hugetlb.h
index c45189aa7476..a7d2b6107383 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb-radix.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -1,5 +1,5 @@
-#ifndef _ASM_POWERPC_BOOK3S_64_HUGETLB_RADIX_H
-#define _ASM_POWERPC_BOOK3S_64_HUGETLB_RADIX_H
+#ifndef _ASM_POWERPC_BOOK3S_64_HUGETLB_H
+#define _ASM_POWERPC_BOOK3S_64_HUGETLB_H
 /*
  * For radix we want generic code to handle hugetlb. But then if we want
  * both hash and radix to be enabled together we need to workaround the
@@ -21,6 +21,8 @@ static inline int hstate_get_psize(struct hstate *hstate)
 		return MMU_PAGE_2M;
 	else if (shift == mmu_psize_defs[MMU_PAGE_1G].shift)
 		return MMU_PAGE_1G;
+	else if (shift == mmu_psize_defs[MMU_PAGE_16M].shift)
+		return MMU_PAGE_16M;
 	else {
 		WARN(1, "Wrong huge page shift\n");
 		return mmu_virtual_psize;
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index c5517f463ec7..c03e0a3dd4d8 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -9,7 +9,7 @@ extern struct kmem_cache *hugepte_cache;
 
 #ifdef CONFIG_PPC_BOOK3S_64
 
-#include <asm/book3s/64/hugetlb-radix.h>
+#include <asm/book3s/64/hugetlb.h>
 /*
  * This should work for other subarchs too. But right now we use the
  * new format only for 64bit book3s
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
