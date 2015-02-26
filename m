Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0876B0070
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:35 -0500 (EST)
Received: by paceu11 with SMTP id eu11so13291887pac.10
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:35 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id v10si798736pds.66.2015.02.26.03.35.34
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 07/17] mips: expose number of page table levels on Kconfig level
Date: Thu, 26 Feb 2015 13:35:10 +0200
Message-Id: <1424950520-90188-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ralf Baechle <ralf@linux-mips.org>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/mips/Kconfig | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index c7a16904cd03..a9d112d2a135 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -2600,6 +2600,11 @@ config STACKTRACE_SUPPORT
 	bool
 	default y
 
+config PGTABLE_LEVELS
+	int
+	default 3 if 64BIT && !PAGE_SIZE_64KB
+	default 2
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
