Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22E1D6B42CC
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:07:33 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id 32so8793776ots.15
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:07:33 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 68si358023otp.89.2018.11.26.09.07.31
        for <linux-mm@kvack.org>;
        Mon, 26 Nov 2018 09:07:31 -0800 (PST)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v4 3/5] x86/pgtable: Drop pXd_none() checks from pXd_free_pYd_table()
Date: Mon, 26 Nov 2018 17:07:45 +0000
Message-Id: <1543252067-30831-4-git-send-email-will.deacon@arm.com>
In-Reply-To: <1543252067-30831-1-git-send-email-will.deacon@arm.com>
References: <1543252067-30831-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

The core code already has a check for pXd_none(), so remove it from the
architecture implementation.

Cc: Chintan Pandya <cpandya@codeaurora.org>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 arch/x86/mm/pgtable.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 59274e2c1ac4..e95a7d6ac8f8 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -811,9 +811,6 @@ int pud_free_pmd_page(pud_t *pud, unsigned long addr)
 	pte_t *pte;
 	int i;
 
-	if (pud_none(*pud))
-		return 1;
-
 	pmd = (pmd_t *)pud_page_vaddr(*pud);
 	pmd_sv = (pmd_t *)__get_free_page(GFP_KERNEL);
 	if (!pmd_sv)
@@ -855,9 +852,6 @@ int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 {
 	pte_t *pte;
 
-	if (pmd_none(*pmd))
-		return 1;
-
 	pte = (pte_t *)pmd_page_vaddr(*pmd);
 	pmd_clear(pmd);
 
-- 
2.1.4
