Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DE236828F3
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:46 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so53163720pab.0
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:46 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id je7si14057245pbd.15.2015.01.30.06.43.40
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 15/19] tile: expose number of page table levels
Date: Fri, 30 Jan 2015 16:43:24 +0200
Message-Id: <1422629008-13689-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chris Metcalf <cmetcalf@ezchip.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Chris Metcalf <cmetcalf@ezchip.com>
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
