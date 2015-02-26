Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D4D8E6B0087
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:36:06 -0500 (EST)
Received: by pdno5 with SMTP id o5so12422090pdn.8
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:36:06 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id by5si830181pad.46.2015.02.26.03.36.05
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:36:06 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 11/17] sh: expose number of page table levels
Date: Thu, 26 Feb 2015 13:35:14 +0200
Message-Id: <1424950520-90188-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-sh@vger.kernel.org

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: linux-sh@vger.kernel.org
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/sh/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index eb4ef274ae9b..50057fed819d 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -162,6 +162,10 @@ config NEED_DMA_MAP_STATE
 config NEED_SG_DMA_LENGTH
 	def_bool y
 
+config PGTABLE_LEVELS
+	default 3 if X2TLB
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
