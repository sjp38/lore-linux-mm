Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD8E76B02F4
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:18:54 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z36so25814132wrb.13
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 23:18:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l35si15129683wre.293.2017.07.26.23.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 23:18:53 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6R6DfHV025181
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:18:52 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2by76hrxk8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:18:51 -0400
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 02:18:51 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v3 3/3] powerpc/mm/hugetlb: Allow runtime allocation of 16G.
Date: Thu, 27 Jul 2017 11:48:28 +0530
In-Reply-To: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20170727061828.11406-3-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We now have GIGANTIC_PAGE on powerpc. Currently this is enabled only on
radix with 1G as gigantic hugepage size. Enable this with hash translation mode
too (ie, with 16G hugepage size). Depending on the total system memory we may
be able to allocate 16G hugepage size. This bring parity between radix and hash
translation mode. Also reduce the confusion of the user with respect to
hugetlbfs usage.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hugetlb.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index 5c28bd6f2ae1..2d1ca488ca44 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -54,9 +54,7 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 #ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
 static inline bool gigantic_page_supported(void)
 {
-	if (radix_enabled())
-		return true;
-	return false;
+	return true;
 }
 #endif
 
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
