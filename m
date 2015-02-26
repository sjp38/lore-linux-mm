Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 467E16B007D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:52 -0500 (EST)
Received: by padfb1 with SMTP id fb1so13330736pad.8
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:52 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xw3si788321pab.71.2015.02.26.03.35.37
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:38 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 14/17] um: expose number of page table levels
Date: Thu, 26 Feb 2015 13:35:17 +0200
Message-Id: <1424950520-90188-15-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/um/Kconfig.um | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/um/Kconfig.um b/arch/um/Kconfig.um
index a7520c90f62d..5dbfe3d9107c 100644
--- a/arch/um/Kconfig.um
+++ b/arch/um/Kconfig.um
@@ -155,3 +155,8 @@ config MMAPPER
 
 config NO_DMA
 	def_bool y
+
+config PGTABLE_LEVELS
+	int
+	default 3 if 3_LEVEL_PGTABLES
+	default 2
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
