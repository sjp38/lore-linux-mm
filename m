Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2051D8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:26:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w12-v6so1728467oie.12
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 03:26:04 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b135-v6si452780oii.71.2018.09.12.03.26.02
        for <linux-mm@kvack.org>;
        Wed, 12 Sep 2018 03:26:02 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH 2/5] arm64: mmu: Drop pXd_present() checks from pXd_free_pYd_table()
Date: Wed, 12 Sep 2018 11:26:11 +0100
Message-Id: <1536747974-25875-3-git-send-email-will.deacon@arm.com>
In-Reply-To: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
References: <1536747974-25875-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, akpm@linux-foundation.org, Will Deacon <will.deacon@arm.com>

Now that the core code checks this for us, we don't need to do it in the
backend.

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
index 8080c9f489c3..0dcb3354d6dd 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -985,10 +985,8 @@ int pmd_free_pte_page(pmd_t *pmdp, unsigned long addr)
 
 	pmd = READ_ONCE(*pmdp);
 
-	if (!pmd_present(pmd))
-		return 1;
 	if (!pmd_table(pmd)) {
-		VM_WARN_ON(!pmd_table(pmd));
+		VM_WARN_ON(1);
 		return 1;
 	}
 
@@ -1008,10 +1006,8 @@ int pud_free_pmd_page(pud_t *pudp, unsigned long addr)
 
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
