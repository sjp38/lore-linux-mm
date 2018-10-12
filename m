Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E14A6B0008
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 00:00:31 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id v188-v6so7632486oie.3
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 21:00:31 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p4si4526070otc.88.2018.10.11.21.00.30
        for <linux-mm@kvack.org>;
        Thu, 11 Oct 2018 21:00:30 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH V2 1/5] mm/hugetlb: Enable PUD level huge page migration
Date: Fri, 12 Oct 2018 09:29:55 +0530
Message-Id: <1539316799-6064-2-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1539316799-6064-1-git-send-email-anshuman.khandual@arm.com>
References: <1539316799-6064-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Architectures like arm64 have PUD level HugeTLB pages for certain configs
(1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
enabled for migration. It can be achieved through checking for PUD_SHIFT
order based HugeTLB pages during migration.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/linux/hugetlb.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6b68e34..9c1b77f 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -483,7 +483,8 @@ static inline bool hugepage_migration_supported(struct hstate *h)
 {
 #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
 	if ((huge_page_shift(h) == PMD_SHIFT) ||
-		(huge_page_shift(h) == PGDIR_SHIFT))
+		(huge_page_shift(h) == PUD_SHIFT) ||
+			(huge_page_shift(h) == PGDIR_SHIFT))
 		return true;
 	else
 		return false;
-- 
2.7.4
