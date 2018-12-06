Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92E2C6B7B4F
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 13:21:17 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id r82so599845oie.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 10:21:17 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 1si472529otg.123.2018.12.06.10.21.16
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 10:21:16 -0800 (PST)
From: Will Deacon <will.deacon@arm.com>
Subject: [RESEND PATCH v4 3/5] x86/pgtable: Drop pXd_none() checks from pXd_free_pYd_table()
Date: Thu,  6 Dec 2018 18:21:33 +0000
Message-Id: <1544120495-17438-4-git-send-email-will.deacon@arm.com>
In-Reply-To: <1544120495-17438-1-git-send-email-will.deacon@arm.com>
References: <1544120495-17438-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

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
