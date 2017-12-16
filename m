Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A55B440404
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 16:39:31 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id z109so1281670wrb.19
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 13:39:31 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p63si6375799wme.115.2017.12.16.13.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 13:39:30 -0800 (PST)
Message-Id: <20171216213137.386682331@linutronix.de>
Date: Sat, 16 Dec 2017 22:24:06 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V149 12/50] x86/mm: Use __flush_tlb_one() for kernel memory
References: <20171216212354.120930222@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0064-x86-mm-Use-__flush_tlb_one-for-kernel-memory.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Peter Zijlstra <peterz@infradead.org>

__flush_tlb_single() is for user mappings, __flush_tlb_one() for
kernel mappings.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
---
 arch/x86/mm/tlb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -551,7 +551,7 @@ static void do_kernel_range_flush(void *
 
 	/* flush range by one by one 'invlpg' */
 	for (addr = f->start; addr < f->end; addr += PAGE_SIZE)
-		__flush_tlb_single(addr);
+		__flush_tlb_one(addr);
 }
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
