Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A01036B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 09:22:37 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i8so3961894pgv.23
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 06:22:37 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id e71si1430101pgc.571.2018.02.09.06.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 06:22:36 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 1/4] x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
Date: Fri,  9 Feb 2018 17:22:25 +0300
Message-Id: <20180209142228.21231-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180209142228.21231-1-kirill.shutemov@linux.intel.com>
References: <20180209142228.21231-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The name of the file -- pagetable.c -- is misleading: it only contains
helpers used for KASLR in 64-bit mode.

Let's rename the file to reflect its content.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/Makefile                    | 2 +-
 arch/x86/boot/compressed/{pagetable.c => kaslr_64.c} | 0
 2 files changed, 1 insertion(+), 1 deletion(-)
 rename arch/x86/boot/compressed/{pagetable.c => kaslr_64.c} (100%)

diff --git a/arch/x86/boot/compressed/Makefile b/arch/x86/boot/compressed/Makefile
index f25e1530e064..1f734cd98fd3 100644
--- a/arch/x86/boot/compressed/Makefile
+++ b/arch/x86/boot/compressed/Makefile
@@ -78,7 +78,7 @@ vmlinux-objs-y := $(obj)/vmlinux.lds $(obj)/head_$(BITS).o $(obj)/misc.o \
 vmlinux-objs-$(CONFIG_EARLY_PRINTK) += $(obj)/early_serial_console.o
 vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr.o
 ifdef CONFIG_X86_64
-	vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/pagetable.o
+	vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr_64.o
 	vmlinux-objs-y += $(obj)/mem_encrypt.o
 	vmlinux-objs-y += $(obj)/pgtable_64.o
 endif
diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/kaslr_64.c
similarity index 100%
rename from arch/x86/boot/compressed/pagetable.c
rename to arch/x86/boot/compressed/kaslr_64.c
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
