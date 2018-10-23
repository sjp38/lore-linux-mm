Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE2ED6B0010
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 09:02:41 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id v2-v6so714818oie.3
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 06:02:41 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 5si539067otr.231.2018.10.23.06.02.37
        for <linux-mm@kvack.org>;
        Tue, 23 Oct 2018 06:02:37 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH V3 2/5] mm/hugetlb: Enable PUD level huge page migration
Date: Tue, 23 Oct 2018 18:31:58 +0530
Message-Id: <1540299721-26484-3-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Architectures like arm64 have PUD level HugeTLB pages for certain configs
(1GB huge page is PUD based on ARM64_4K_PAGES base page size) that can be
enabled for migration. It can be achieved through checking for PUD_SHIFT
order based HugeTLB pages during migration.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 include/linux/hugetlb.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 1b858d7..70bcd89 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -497,7 +497,8 @@ static inline bool hugepage_migration_supported(struct hstate *h)
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
