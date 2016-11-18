Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD176B038C
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 20:17:04 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w132so7313100ita.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 17:17:04 -0800 (PST)
Received: from mail-it0-f42.google.com (mail-it0-f42.google.com. [209.85.214.42])
        by mx.google.com with ESMTPS id d1si429261ite.3.2016.11.17.17.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 17:17:03 -0800 (PST)
Received: by mail-it0-f42.google.com with SMTP id l8so6044908iti.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 17:17:03 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 1/6] lib/Kconfig.debug: Add ARCH_HAS_DEBUG_VIRTUAL
Date: Thu, 17 Nov 2016 17:16:51 -0800
Message-Id: <1479431816-5028-2-git-send-email-labbott@redhat.com>
In-Reply-To: <1479431816-5028-1-git-send-email-labbott@redhat.com>
References: <1479431816-5028-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org


DEBUG_VIRTUAL currently depends on DEBUG_KERNEL && X86. arm64 is getting
the same support. Rather than add a list of architectures, switch this
to ARCH_HAS_DEBUG_VIRTUAL and let architectures select it as
appropriate.

Suggested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v3: No change, x86 maintainers please ack if you are okay with this.
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
index b01e547..5050530 100644
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
