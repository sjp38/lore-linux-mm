Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E878C6B027B
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:27:56 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u83so4411531wmb.3
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:27:56 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id p27si233480edc.208.2018.03.05.02.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:19 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 25/34] x86/mm/pti: Define X86_CR3_PTI_PCID_USER_BIT on x86_32
Date: Mon,  5 Mar 2018 11:25:54 +0100
Message-Id: <1520245563-8444-26-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Move it out of the X86_64 specific processor defines so
that its visible for 32bit too.

Reviewed-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/processor-flags.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/include/asm/processor-flags.h b/arch/x86/include/asm/processor-flags.h
index 625a52a..02c2cbd 100644
--- a/arch/x86/include/asm/processor-flags.h
+++ b/arch/x86/include/asm/processor-flags.h
@@ -39,10 +39,6 @@
 #define CR3_PCID_MASK	0xFFFull
 #define CR3_NOFLUSH	BIT_ULL(63)
 
-#ifdef CONFIG_PAGE_TABLE_ISOLATION
-# define X86_CR3_PTI_PCID_USER_BIT	11
-#endif
-
 #else
 /*
  * CR3_ADDR_MASK needs at least bits 31:5 set on PAE systems, and we save
@@ -53,4 +49,8 @@
 #define CR3_NOFLUSH	0
 #endif
 
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+# define X86_CR3_PTI_PCID_USER_BIT	11
+#endif
+
 #endif /* _ASM_X86_PROCESSOR_FLAGS_H */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
