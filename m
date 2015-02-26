Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 05A746B0078
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:48 -0500 (EST)
Received: by paceu11 with SMTP id eu11so13338048pac.7
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:47 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ng11si815912pdb.55.2015.02.26.03.35.36
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:37 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 02/17] alpha: expose number of page table levels on Kconfig level
Date: Thu, 26 Feb 2015 13:35:05 +0200
Message-Id: <1424950520-90188-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/alpha/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index b7ff9a318c31..bf9e9d3b3792 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -76,6 +76,10 @@ config GENERIC_ISA_DMA
 	bool
 	default y
 
+config PGTABLE_LEVELS
+	int
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
