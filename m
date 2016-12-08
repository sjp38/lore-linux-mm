Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA7A6B0267
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:23:38 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id z187so8422012iod.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:23:38 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k1si29529274pld.26.2016.12.08.08.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:23:37 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv1 28/28] TESTING-ONLY: bump TASK_SIZE_MAX
Date: Thu,  8 Dec 2016 19:21:50 +0300
Message-Id: <20161208162150.148763-30-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is useful for now to play with.

We would need to imlement proper opt-in with prctl()/personality()/ELF
flag.
---
 arch/x86/include/asm/processor.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 63def9537a2d..ab44cbe853cb 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -755,7 +755,8 @@ extern unsigned long thread_saved_pc(struct task_struct *tsk);
  * particular problem by preventing anything from being mapped
  * at the maximum canonical address.
  */
-#define TASK_SIZE_MAX	((1UL << 47) - PAGE_SIZE)
+/* TODO: use >47bit only if requested */
+#define TASK_SIZE_MAX	((1UL << __VIRTUAL_MASK_SHIFT) - PAGE_SIZE)
 
 /* This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
