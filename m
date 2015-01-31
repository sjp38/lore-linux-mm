Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA4E6B006C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 19:27:37 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so58306688pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 16:27:36 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id we6si15491712pac.129.2015.01.30.16.27.36
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 16:27:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 11/19] powerpc: expose number of page table levels on Kconfig level
Date: Sat, 31 Jan 2015 02:27:27 +0200
Message-Id: <1422664047-220637-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-12-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-12-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
---
 v2: s/64K_PAGES/PPC_64K_PAGES/
---
 arch/powerpc/Kconfig | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 22b0940494bb..91ad76f30d18 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -297,6 +297,12 @@ config ZONE_DMA32
 	bool
 	default y if PPC64
 
+config PGTABLE_LEVELS
+	int
+	default 2 if !PPC64
+	default 3 if PPC_64K_PAGES
+	default 4
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
