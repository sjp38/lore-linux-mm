Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 181A86B0088
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:36:09 -0500 (EST)
Received: by pdjy10 with SMTP id y10so12436779pdj.6
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:36:08 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hw2si2247000pbb.188.2015.02.26.03.36.05
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:36:06 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 12/17] sparc: expose number of page table levels
Date: Thu, 26 Feb 2015 13:35:15 +0200
Message-Id: <1424950520-90188-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "David S. Miller" <davem@davemloft.net>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/sparc/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 96ac69c5eba0..cb06f5433e12 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -143,6 +143,10 @@ config GENERIC_ISA_DMA
 config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	def_bool y if SPARC64
 
+config PGTABLE_LEVELS
+	default 4 if 64BIT
+	default 3
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
