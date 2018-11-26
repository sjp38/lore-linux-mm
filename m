Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED656B42CE
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:07:36 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id a89so8649479otc.8
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:07:36 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 203si374148oid.154.2018.11.26.09.07.31
        for <linux-mm@kvack.org>;
        Mon, 26 Nov 2018 09:07:31 -0800 (PST)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v4 2/5] arm64: mmu: Drop pXd_present() checks from pXd_free_pYd_table()
Date: Mon, 26 Nov 2018 17:07:44 +0000
Message-Id: <1543252067-30831-3-git-send-email-will.deacon@arm.com>
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
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 arch/arm64/mm/mmu.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index d1d6601b385d..786cfa6355be 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -989,10 +989,8 @@ int pmd_free_pte_page(pmd_t *pmdp, unsigned long addr)
 
 	pmd = READ_ONCE(*pmdp);
 
-	if (!pmd_present(pmd))
-		return 1;
 	if (!pmd_table(pmd)) {
-		VM_WARN_ON(!pmd_table(pmd));
+		VM_WARN_ON(1);
 		return 1;
 	}
 
@@ -1012,10 +1010,8 @@ int pud_free_pmd_page(pud_t *pudp, unsigned long addr)
 
 	pud = READ_ONCE(*pudp);
 
-	if (!pud_present(pud))
-		return 1;
 	if (!pud_table(pud)) {
-		VM_WARN_ON(!pud_table(pud));
+		VM_WARN_ON(1);
 		return 1;
 	}
 
-- 
2.1.4
