Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E0073828F3
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:58 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so53047210pab.3
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:58 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id oh8si1543211pdb.40.2015.01.30.06.43.50
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 14/19] sparc: expose number of page table levels
Date: Fri, 30 Jan 2015 16:43:23 +0200
Message-Id: <1422629008-13689-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "David S. Miller" <davem@davemloft.net>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
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
