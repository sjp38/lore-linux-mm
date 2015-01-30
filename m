Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id D6332828F3
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:48 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so53048264pab.6
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:48 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id jj1si14112951pac.5.2015.01.30.06.43.40
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:40 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 16/19] um: expose number of page table levels
Date: Fri, 30 Jan 2015 16:43:25 +0200
Message-Id: <1422629008-13689-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
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
