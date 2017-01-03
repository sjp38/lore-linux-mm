Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 133B66B0260
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 12:22:07 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id j29so232272986qtc.6
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:07 -0800 (PST)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by mx.google.com with ESMTPS id v5si33248602qkg.217.2017.01.03.09.22.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 09:22:06 -0800 (PST)
Received: by mail-qk0-f179.google.com with SMTP id t184so381964823qkd.0
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:06 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv6 01/11] lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
Date: Tue,  3 Jan 2017 09:21:43 -0800
Message-Id: <1483464113-1587-2-git-send-email-labbott@redhat.com>
In-Reply-To: <1483464113-1587-1-git-send-email-labbott@redhat.com>
References: <1483464113-1587-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org


DEBUG_VIRTUAL currently depends on DEBUG_KERNEL && X86. arm64 is getting
the same support. Rather than add a list of architectures, switch this
to ARCH_HAS_DEBUG_VIRTUAL and let architectures select it as
appropriate.

Acked-by: Ingo Molnar <mingo@kernel.org>
Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Suggested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 arch/x86/Kconfig  | 1 +
 lib/Kconfig.debug | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e487493..f1d4e8f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -46,6 +46,7 @@ config X86
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_DISCARD_MEMBLOCK
 	select ARCH_HAS_ACPI_TABLE_UPGRADE	if ACPI
+	select ARCH_HAS_DEBUG_VIRTUAL
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index b06848a..2aed316 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -622,9 +622,12 @@ config DEBUG_VM_PGFLAGS
 
 	  If unsure, say N.
 
+config ARCH_HAS_DEBUG_VIRTUAL
+	bool
+
 config DEBUG_VIRTUAL
 	bool "Debug VM translations"
-	depends on DEBUG_KERNEL && X86
+	depends on DEBUG_KERNEL && ARCH_HAS_DEBUG_VIRTUAL
 	help
 	  Enable some costly sanity checks in virtual to page code. This can
 	  catch mistakes with virt_to_page() and friends.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
