Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1BA6B0263
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 01:38:09 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id td3so47920552pab.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 22:38:09 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [125.16.236.9])
        by mx.google.com with ESMTPS id bw8si9334541pad.127.2016.04.06.22.38.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 22:38:05 -0700 (PDT)
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 7 Apr 2016 11:08:03 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u375cFDk65077260
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:08:15 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u375brKN006351
	for <linux-mm@kvack.org>; Thu, 7 Apr 2016 11:07:57 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 09/10] powerpc/hugetlb: Selectively enable ARCH_ENABLE_HUGEPAGE_MIGRATION
Date: Thu,  7 Apr 2016 11:07:43 +0530
Message-Id: <1460007464-26726-10-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

This change enables the config option ARCH_ENABLE_HUGEPAGE_MIGRATION
depending on whether the platform has got ARCH_WANT_GENERAL_HUGETLB
or not along with config option MIGRATION. In turn, it turns on the
'hugepage_migration_supported' function which is checked for feature
presence during HugeTLB page migration and clears the way.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 9b3ce18..f2a45eb 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -86,6 +86,10 @@ config GENERIC_HWEIGHT
 config ARCH_HAS_DMA_SET_COHERENT_MASK
         bool
 
+config ARCH_ENABLE_HUGEPAGE_MIGRATION
+	def_bool y
+	depends on ARCH_WANT_GENERAL_HUGETLB && MIGRATION
+
 config PPC
 	bool
 	default y
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
