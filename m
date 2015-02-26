Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id A55006B0085
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:36:05 -0500 (EST)
Received: by pdev10 with SMTP id v10so12391074pde.10
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:36:05 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bc4si506646pdb.237.2015.02.26.03.36.04
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:36:05 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 10/17] s390: expose number of page table levels
Date: Thu, 26 Feb 2015 13:35:13 +0200
Message-Id: <1424950520-90188-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/s390/Kconfig | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 373cd5badf1c..f6aebcb7a0f8 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -155,6 +155,11 @@ config S390
 config SCHED_OMIT_FRAME_POINTER
 	def_bool y
 
+config PGTABLE_LEVELS
+	int
+	default 4 if 64BIT
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
