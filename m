Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 71ED06B026A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 09:02:52 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id o204-v6so698738oif.10
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 06:02:52 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 50si579923otk.166.2018.10.23.06.02.51
        for <linux-mm@kvack.org>;
        Tue, 23 Oct 2018 06:02:51 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH V3 4/5] arm64/mm: Enable HugeTLB migration
Date: Tue, 23 Oct 2018 18:32:00 +0530
Message-Id: <1540299721-26484-5-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
References: <1540299721-26484-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Let arm64 subscribe to generic HugeTLB page migration framework. Right now
this only works on the following PMD and PUD level HugeTLB page sizes with
various kernel base page size combinations.

       CONT PTE    PMD    CONT PMD    PUD
       --------    ---    --------    ---
4K:         NA     2M         NA      1G
16K:        NA    32M         NA
64K:        NA   512M         NA

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a8ae30f..4b3e269 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -1331,6 +1331,10 @@ config SYSVIPC_COMPAT
 	def_bool y
 	depends on COMPAT && SYSVIPC
 
+config ARCH_ENABLE_HUGEPAGE_MIGRATION
+	def_bool y
+	depends on HUGETLB_PAGE && MIGRATION
+
 menu "Power management options"
 
 source "kernel/power/Kconfig"
-- 
2.7.4
