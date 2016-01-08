Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 826456B0260
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:38 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id yy13so196753837pab.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:38 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id n16si7938166pfj.185.2016.01.08.15.15.37
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:37 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 01/13] x86/paravirt: Turn KASAN off for parvirt.o
Date: Fri,  8 Jan 2016 15:15:19 -0800
Message-Id: <bffe57f96d76a92655cb5d230d86cec195a20f6e.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

Otherwise terrible things happen if some of the callbacks end up
calling into KASAN in unexpected places.

This has no obvious symptoms yet, but adding a memory reference to
native_flush_tlb_global without this blows up on KASAN kernels.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/kernel/Makefile | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index b1b78ffe01d0..b7cd5bdf314b 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -19,6 +19,7 @@ endif
 KASAN_SANITIZE_head$(BITS).o := n
 KASAN_SANITIZE_dumpstack.o := n
 KASAN_SANITIZE_dumpstack_$(BITS).o := n
+KASAN_SANITIZE_paravirt.o := n
 
 CFLAGS_irq.o := -I$(src)/../include/asm/trace
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
