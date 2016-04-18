Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3DE16B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 14:42:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so344444668pfb.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 11:42:03 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id l28si8988319pfb.246.2016.04.18.11.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 11:42:02 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id 184so83848790pff.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 11:42:02 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] arm64: Kconfig: remove redundant HAVE_ARCH_TRANSPARENT_HUGEPAGE definition
Date: Mon, 18 Apr 2016 11:16:14 -0700
Message-Id: <1461003374-5412-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

HAVE_ARCH_TRANSPARENT_HUGEPAGE has been defined in arch/Kconfig already,
the ARM64 version is identical with it and the default value is Y. So remove
the redundant definition and just select it under CONFIG_ARM64.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 arch/arm64/Kconfig | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index e5de825..496c1b4 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -98,6 +98,7 @@ config ARM64
 	select SYSCTL_EXCEPTION_TRACE
 	select HAVE_CONTEXT_TRACKING
 	select HAVE_ARM_SMCCC
+	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	help
 	  ARM 64-bit (AArch64) Linux support.
 
@@ -580,9 +581,6 @@ config SYS_SUPPORTS_HUGETLBFS
 config ARCH_WANT_HUGE_PMD_SHARE
 	def_bool y if ARM64_4K_PAGES || (ARM64_16K_PAGES && !ARM64_VA_BITS_36)
 
-config HAVE_ARCH_TRANSPARENT_HUGEPAGE
-	def_bool y
-
 config ARCH_HAS_CACHE_LINE_SIZE
 	def_bool y
 
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
