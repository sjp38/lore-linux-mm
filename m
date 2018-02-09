Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 31CBB6B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 04:25:57 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id d37so2900588wrd.15
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 01:25:57 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id m24si59228edm.84.2018.02.09.01.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 01:25:53 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 01/31] x86/asm-offsets: Move TSS_sp0 and TSS_sp1 to asm-offsets.c
Date: Fri,  9 Feb 2018 10:25:10 +0100
Message-Id: <1518168340-9392-2-git-send-email-joro@8bytes.org>
In-Reply-To: <1518168340-9392-1-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

These offsets will be used in 32 bit assembly code as well,
so make them available for all of x86 code.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/kernel/asm-offsets.c    | 4 ++++
 arch/x86/kernel/asm-offsets_64.c | 2 --
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/asm-offsets.c b/arch/x86/kernel/asm-offsets.c
index 76417a9..232152c 100644
--- a/arch/x86/kernel/asm-offsets.c
+++ b/arch/x86/kernel/asm-offsets.c
@@ -103,4 +103,8 @@ void common(void) {
 	OFFSET(CPU_ENTRY_AREA_entry_trampoline, cpu_entry_area, entry_trampoline);
 	OFFSET(CPU_ENTRY_AREA_entry_stack, cpu_entry_area, entry_stack_page);
 	DEFINE(SIZEOF_entry_stack, sizeof(struct entry_stack));
+
+	/* Offset for sp0 and sp1 into the tss_struct */
+	OFFSET(TSS_sp0, tss_struct, x86_tss.sp0);
+	OFFSET(TSS_sp1, tss_struct, x86_tss.sp1);
 }
diff --git a/arch/x86/kernel/asm-offsets_64.c b/arch/x86/kernel/asm-offsets_64.c
index bf51e51..d2eba73 100644
--- a/arch/x86/kernel/asm-offsets_64.c
+++ b/arch/x86/kernel/asm-offsets_64.c
@@ -65,8 +65,6 @@ int main(void)
 #undef ENTRY
 
 	OFFSET(TSS_ist, tss_struct, x86_tss.ist);
-	OFFSET(TSS_sp0, tss_struct, x86_tss.sp0);
-	OFFSET(TSS_sp1, tss_struct, x86_tss.sp1);
 	BLANK();
 
 #ifdef CONFIG_CC_STACKPROTECTOR
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
