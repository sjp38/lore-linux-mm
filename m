Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 96B966B0073
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:49:25 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so227916979pac.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:49:25 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id cm5si5730243pdb.228.2015.03.24.07.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 24 Mar 2015 07:49:24 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NLQ00M9Z1D1DO60@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Mar 2015 14:53:25 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH 1/2] kasan, x86: move KASAN_SHADOW_OFFSET to the arch Kconfig
Date: Tue, 24 Mar 2015 17:49:03 +0300
Message-id: <1427208544-8232-2-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>

KASAN_SHADOW_OFFSET is purely arch specific setting,
so it should be in arch's Kconfig file. This simplifies
porting KASan to other architectures and maintenance of it.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/Kconfig  | 4 ++++
 lib/Kconfig.kasan | 4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cb23206..66ee917 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -247,6 +247,10 @@ config ARCH_SUPPORTS_OPTIMIZED_INLINING
 config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	def_bool y
 
+config KASAN_SHADOW_OFFSET
+	hex
+	default 0xdffffc0000000000
+
 config HAVE_INTEL_TXT
 	def_bool y
 	depends on INTEL_IOMMU && ACPI
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 4fecaedc..ba31b8c 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -15,10 +15,6 @@ config KASAN
 	  For better error detection enable CONFIG_STACKTRACE,
 	  and add slub_debug=U to boot cmdline.
 
-config KASAN_SHADOW_OFFSET
-	hex
-	default 0xdffffc0000000000 if X86_64
-
 choice
 	prompt "Instrumentation type"
 	depends on KASAN
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
