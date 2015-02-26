Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 565AB6B0080
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:54 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so13408386pab.0
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:54 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id h7si79548pdn.131.2015.02.26.03.35.38
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:38 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 04/17] arm: expose number of page table levels on Kconfig level
Date: Thu, 26 Feb 2015 13:35:07 +0200
Message-Id: <1424950520-90188-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King <linux@arm.linux.org.uk>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Russell King <linux@arm.linux.org.uk>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/arm/Kconfig | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 9f1f09a2bc9b..16f20b2b37e3 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -286,6 +286,11 @@ config GENERIC_BUG
 	def_bool y
 	depends on BUG
 
+config PGTABLE_LEVELS
+	int
+	default 3 if ARM_LPAE
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
