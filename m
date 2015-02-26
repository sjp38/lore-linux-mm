Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 336886B006E
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:35 -0500 (EST)
Received: by pdjz10 with SMTP id z10so12502066pdj.0
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:34 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id v10si798736pds.66.2015.02.26.03.35.34
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 06/17] m68k: mark PMD folded and expose number of page table levels
Date: Thu, 26 Feb 2015 13:35:09 +0200
Message-Id: <1424950520-90188-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/m68k/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index 87b7c7581b1d..2dd8f63bfbbb 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -67,6 +67,10 @@ config HZ
 	default 1000 if CLEOPATRA
 	default 100
 
+config PGTABLE_LEVELS
+	default 2 if SUN3 || COLDFIRE
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
