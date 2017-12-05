Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD956B0033
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 09:01:32 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j3so215543pfh.16
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 06:01:32 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p3si116208pld.717.2017.12.05.06.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 06:01:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 2/4] x86/boot/compressed/64: Rename pagetable.c to kaslr_64.c
Date: Tue,  5 Dec 2017 16:59:40 +0300
Message-Id: <20171205135942.24634-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
References: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The name of the file -- pagetable.c -- is misleading: it only contains
helpers used for KASLR in 64-bin mode.

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
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
