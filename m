Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3708C6B0006
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 12:23:15 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 30-v6so3975508ots.12
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 09:23:15 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 188-v6si6278863oid.28.2018.10.10.09.23.13
        for <linux-mm@kvack.org>;
        Wed, 10 Oct 2018 09:23:14 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v3 3/5] x86/pgtable: Drop pXd_none() checks from pXd_free_pYd_table()
Date: Wed, 10 Oct 2018 17:23:02 +0100
Message-Id: <1539188584-15819-4-git-send-email-will.deacon@arm.com>
In-Reply-To: <1539188584-15819-1-git-send-email-will.deacon@arm.com>
References: <1539188584-15819-1-git-send-email-will.deacon@arm.com>
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
