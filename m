Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF016B025A
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 07:12:11 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id u190so9808078pfb.3
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 04:12:11 -0800 (PST)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id o65si12153241pfo.226.2016.03.09.04.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 04:12:07 -0800 (PST)
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 9 Mar 2016 22:12:04 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 2B23A2BB0059
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 23:12:01 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u29CBqEp61603928
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:12:00 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u29CBSAr022054
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:28 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 8/9] powerpc/mm: Enable HugeTLB page migration
Date: Wed,  9 Mar 2016 17:40:49 +0530
Message-Id: <1457525450-4262-8-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

This change enables HugeTLB page migration for PPC64_BOOK3S systems
for HugeTLB pages implemented at the PMD level. It enables the kernel
configuration option ARCH_ENABLE_HUGEPAGE_MIGRATION which turns on
'hugepage_migration_supported' function which is checked for feature
presence during migration.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index c6920bb..cefc368 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -86,6 +86,10 @@ config GENERIC_HWEIGHT
 config ARCH_HAS_DMA_SET_COHERENT_MASK
         bool
 
+config ARCH_ENABLE_HUGEPAGE_MIGRATION
+	def_bool y
+	depends on PPC_BOOK3S_64 && HUGETLB_PAGE && MIGRATION
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
