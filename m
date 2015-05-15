Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 932016B0070
	for <linux-mm@kvack.org>; Fri, 15 May 2015 14:43:23 -0400 (EDT)
Received: by oica37 with SMTP id a37so89121118oic.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 11:43:23 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id a8si364651obx.8.2015.05.15.11.43.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 May 2015 11:43:22 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v5 1/6] mm, x86: Simplify conditions of HAVE_ARCH_HUGE_VMAP
Date: Fri, 15 May 2015 12:23:52 -0600
Message-Id: <1431714237-880-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com, Toshi Kani <toshi.kani@hp.com>

Simplify the conditions to select HAVE_ARCH_HUGE_VMAP
in arch/x86/Kconfig since X86_PAE depends on X86_32.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8fec044..73a4d03 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -100,7 +100,7 @@ config X86
 	select IRQ_FORCED_THREADING
 	select HAVE_BPF_JIT if X86_64
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
-	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)
+	select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE
 	select ARCH_HAS_SG_CHAIN
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
