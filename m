Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7B43D6B006E
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:37 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so53179758pad.1
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sm10si13821105pab.239.2015.01.30.06.43.36
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 08/19] mips: expose number of page table levels on Kconfig level
Date: Fri, 30 Jan 2015 16:43:17 +0200
Message-Id: <1422629008-13689-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ralf Baechle <ralf@linux-mips.org>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
---
 arch/mips/Kconfig | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 843713c05b79..2eea81795139 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -2535,6 +2535,11 @@ config STACKTRACE_SUPPORT
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
