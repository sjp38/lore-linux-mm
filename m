Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E18F16B000E
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 08:15:54 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id r68-v6so839667oie.12
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 05:15:54 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j10si1595236otb.180.2018.10.02.05.15.53
        for <linux-mm@kvack.org>;
        Tue, 02 Oct 2018 05:15:53 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH 3/4] arm64/mm: Enable HugeTLB migration
Date: Tue,  2 Oct 2018 17:45:30 +0530
Message-Id: <1538482531-26883-4-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

Let arm64 subscribe to generic HugeTLB page migration framework. Right now
this only works on the following PMD and PUD level HugeTLB page sizes with
various kernel base page size combinations.

       CONT PTE    PMD    CONT PMD    PUD
       --------    ---    --------    ---
4K:         NA     2M         NA      1G
16K:        NA    32M         NA
64K:        NA   512M         NA

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 1b1a0e9..e54350f 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -1305,6 +1305,10 @@ config SYSVIPC_COMPAT
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
