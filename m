Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9B05F6B03A7
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 08:51:31 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so6837498pdj.11
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 05:51:31 -0700 (PDT)
Received: from psmtp.com ([74.125.245.190])
        by mx.google.com with SMTP id bc2si12153489pad.216.2013.10.22.05.51.29
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 05:51:30 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 Oct 2013 18:21:24 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 6AD28394296B
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:16 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9MBVRIu19988554
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 17:01:27 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9MBSZGl023269
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:35 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 9/9] powerpc: mm: Enable numa faulting for hugepages
Date: Tue, 22 Oct 2013 16:58:20 +0530
Message-Id: <1382441300-1513-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Provide numa related functions for updating pmd entries.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 67ea8fb..aa3add7 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -95,19 +95,19 @@ static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
 #define pmd_numa pmd_numa
 static inline int pmd_numa(pmd_t pmd)
 {
-	return 0;
+	return pte_numa(pmd_pte(pmd));
 }
 
 #define pmd_mknonnuma pmd_mknonnuma
 static inline pmd_t pmd_mknonnuma(pmd_t pmd)
 {
-	return pmd;
+	return pte_pmd(pte_mknonnuma(pmd_pte(pmd)));
 }
 
 #define pmd_mknuma pmd_mknuma
 static inline pmd_t pmd_mknuma(pmd_t pmd)
 {
-	return pmd;
+	return pte_pmd(pte_mknuma(pmd_pte(pmd)));
 }
 
 # else
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
