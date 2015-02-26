Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id ECCC36B0074
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:43 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so13361006pab.4
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:43 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id v10si798736pds.66.2015.02.26.03.35.36
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 13/17] tile: expose number of page table levels
Date: Thu, 26 Feb 2015 13:35:16 +0200
Message-Id: <1424950520-90188-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chris Metcalf <cmetcalf@ezchip.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Chris Metcalf <cmetcalf@ezchip.com>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/tile/Kconfig | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/tile/Kconfig b/arch/tile/Kconfig
index 7cca41842a9e..0142d578b5a8 100644
--- a/arch/tile/Kconfig
+++ b/arch/tile/Kconfig
@@ -147,6 +147,11 @@ config ARCH_DEFCONFIG
 	default "arch/tile/configs/tilepro_defconfig" if !TILEGX
 	default "arch/tile/configs/tilegx_defconfig" if TILEGX
 
+config PGTABLE_LEVELS
+	int
+	default 3 if 64BIT
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
