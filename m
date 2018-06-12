Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3C36B026A
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:39:29 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t19-v6so4670346plo.9
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:39:29 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o4-v6si259891plk.321.2018.06.12.07.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:39:27 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 11/17] x86/mm: Rename CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING
Date: Tue, 12 Jun 2018 17:39:09 +0300
Message-Id: <20180612143915.68065-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Rename the option to CONFIG_MEMORY_PHYSICAL_PADDING. It will be used
not only for KASLR.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig    | 2 +-
 arch/x86/mm/kaslr.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 4992598ae411..4fa2cf807321 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2187,7 +2187,7 @@ config RANDOMIZE_MEMORY
 
 	   If unsure, say Y.
 
-config RANDOMIZE_MEMORY_PHYSICAL_PADDING
+config MEMORY_PHYSICAL_PADDING
 	hex "Physical memory mapping padding" if EXPERT
 	depends on RANDOMIZE_MEMORY
 	default "0xa" if MEMORY_HOTPLUG
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 61db77b0eda9..4408cd9a3bef 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -102,7 +102,7 @@ void __init kernel_randomize_memory(void)
 	 */
 	BUG_ON(kaslr_regions[0].base != &page_offset_base);
 	memory_tb = DIV_ROUND_UP(max_pfn << PAGE_SHIFT, 1UL << TB_SHIFT) +
-		CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING;
+		CONFIG_MEMORY_PHYSICAL_PADDING;
 
 	/* Adapt phyiscal memory region size based on available memory */
 	if (memory_tb < kaslr_regions[0].size_tb)
-- 
2.17.1
