Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F1E956B025E
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 06:54:39 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o20so9111508wro.8
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:54:39 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id y34si2309777wrd.181.2017.12.18.03.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 03:54:39 -0800 (PST)
Message-Id: <20171218115254.247700454@linutronix.de>
Date: Mon, 18 Dec 2017 12:42:23 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V163 08/51] x86/doc: Remove obvious weirdness
References: <20171218114215.239543034@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0069-x86-doc-Remove-obvious-weirdness.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Peter Zijlstra <peterz@infradead.org>

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
 Documentation/x86/x86_64/mm.txt |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -1,6 +1,4 @@
 
-<previous description obsolete, deleted>
-
 Virtual memory map with 4 level page tables:
 
 0000000000000000 - 00007fffffffffff (=47 bits) user space, different per mm
@@ -49,8 +47,9 @@ ffffffffffe00000 - ffffffffffffffff (=2
 
 Architecture defines a 64-bit virtual address. Implementations can support
 less. Currently supported are 48- and 57-bit virtual addresses. Bits 63
-through to the most-significant implemented bit are set to either all ones
-or all zero. This causes hole between user space and kernel addresses.
+through to the most-significant implemented bit are sign extended.
+This causes hole between user space and kernel addresses if you interpret them
+as unsigned.
 
 The direct mapping covers all memory in the system up to the highest
 memory address (this means in some cases it can also include PCI memory
@@ -60,9 +59,6 @@ vmalloc space is lazily synchronized int
 the processes using the page fault handler, with init_top_pgt as
 reference.
 
-Current X86-64 implementations support up to 46 bits of address space (64 TB),
-which is our current limit. This expands into MBZ space in the page tables.
-
 We map EFI runtime services in the 'efi_pgd' PGD in a 64Gb large virtual
 memory window (this size is arbitrary, it can be raised later if needed).
 The mappings are not part of any other kernel PGD and are only available
@@ -74,5 +70,3 @@ following fixmap section.
 Note that if CONFIG_RANDOMIZE_MEMORY is enabled, the direct mapping of all
 physical memory, vmalloc/ioremap space and virtual memory map are randomized.
 Their order is preserved but their base will be offset early at boot time.
-
--Andi Kleen, Jul 2004


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
