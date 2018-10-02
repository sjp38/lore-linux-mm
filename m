Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 179C26B026B
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 07:05:42 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id x194-v6so1002438oix.10
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 04:05:42 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b67-v6si1992981oii.148.2018.10.02.04.05.40
        for <linux-mm@kvack.org>;
        Tue, 02 Oct 2018 04:05:40 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 3/5] x86: pgtable: Drop pXd_none() checks from pXd_free_pYd_table()
Date: Tue,  2 Oct 2018 12:06:01 +0100
Message-Id: <1538478363-16255-4-git-send-email-will.deacon@arm.com>
In-Reply-To: <1538478363-16255-1-git-send-email-will.deacon@arm.com>
References: <1538478363-16255-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

Now that the core code checks this for us, we don't need to do it in the
backend.

Cc: Chintan Pandya <cpandya@codeaurora.org>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 arch/x86/mm/pgtable.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index ae394552fb94..b4919c44a194 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -796,9 +796,6 @@ int pud_free_pmd_page(pud_t *pud, unsigned long addr)
 	pte_t *pte;
 	int i;
 
-	if (pud_none(*pud))
-		return 1;
-
 	pmd = (pmd_t *)pud_page_vaddr(*pud);
 	pmd_sv = (pmd_t *)__get_free_page(GFP_KERNEL);
 	if (!pmd_sv)
@@ -840,9 +837,6 @@ int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 {
 	pte_t *pte;
 
-	if (pmd_none(*pmd))
-		return 1;
-
 	pte = (pte_t *)pmd_page_vaddr(*pmd);
 	pmd_clear(pmd);
 
-- 
2.1.4
