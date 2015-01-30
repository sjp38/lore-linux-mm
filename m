Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C69B56B0070
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:43:38 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so53121605pad.4
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:43:38 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sm10si13821105pab.239.2015.01.30.06.43.37
        for <linux-mm@kvack.org>;
        Fri, 30 Jan 2015 06:43:38 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 01/19] alpha: expose number of page table levels on Kconfig level
Date: Fri, 30 Jan 2015 16:43:10 +0200
Message-Id: <1422629008-13689-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Cc: Matt Turner <mattst88@gmail.com>
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
