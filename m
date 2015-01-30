Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id EAA85828F3
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:56 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so53049557pab.6
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ub10si13831752pbc.203.2015.01.30.06.43.50
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:50 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 03/19] arm: expose number of page table levels on Kconfig level
Date: Fri, 30 Jan 2015 16:43:12 +0200
Message-Id: <1422629008-13689-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King <linux@arm.linux.org.uk>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Russell King <linux@arm.linux.org.uk>
---
 arch/arm/Kconfig | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 4211507e2bca..d7dca652573f 100644
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
