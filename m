Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67E076B0253
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:55:39 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id m67so139241444qkf.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:55:39 -0800 (PST)
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com. [209.85.220.180])
        by mx.google.com with ESMTPS id c145si35570373qke.290.2016.11.29.10.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:55:38 -0800 (PST)
Received: by mail-qk0-f180.google.com with SMTP id n204so184701885qke.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:55:38 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv4 01/10] lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
Date: Tue, 29 Nov 2016 10:55:20 -0800
Message-Id: <1480445729-27130-2-git-send-email-labbott@redhat.com>
In-Reply-To: <1480445729-27130-1-git-send-email-labbott@redhat.com>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
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
v4: No changes, just Acks
---
 arch/x86/Kconfig  | 1 +
 lib/Kconfig.debug | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index bada636..f533321 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -23,6 +23,7 @@ config X86
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_DISCARD_MEMBLOCK
 	select ARCH_HAS_ACPI_TABLE_UPGRADE if ACPI
+	select ARCH_HAS_DEBUG_VIRTUAL
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index a6c8db1..be65e04 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -603,9 +603,12 @@ config DEBUG_VM_PGFLAGS
 
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
