Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 353A36B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:41:20 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id z1so58842pfl.9
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:41:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c123si44680pfg.166.2017.12.05.04.41.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:41:19 -0800 (PST)
Message-Id: <20171205123820.337227593@infradead.org>
Date: Tue, 05 Dec 2017 13:34:54 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 9/9] x86/doc: Remove obvious weirdness
References: <20171205123444.990868007@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-mm-doc.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at


Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
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
@@ -47,8 +45,9 @@ ffffffffffe00000 - ffffffffffffffff (=2
 
 Architecture defines a 64-bit virtual address. Implementations can support
 less. Currently supported are 48- and 57-bit virtual addresses. Bits 63
-through to the most-significant implemented bit are set to either all ones
-or all zero. This causes hole between user space and kernel addresses.
+through to the most-significant implemented bit are sign extended.
+This causes hole between user space and kernel addresses if you interpret them
+as unsigned.
 
 The direct mapping covers all memory in the system up to the highest
 memory address (this means in some cases it can also include PCI memory
@@ -58,9 +57,6 @@ vmalloc space is lazily synchronized int
 the processes using the page fault handler, with init_top_pgt as
 reference.
 
-Current X86-64 implementations support up to 46 bits of address space (64 TB),
-which is our current limit. This expands into MBZ space in the page tables.
-
 We map EFI runtime services in the 'efi_pgd' PGD in a 64Gb large virtual
 memory window (this size is arbitrary, it can be raised later if needed).
 The mappings are not part of any other kernel PGD and are only available
@@ -72,5 +68,3 @@ following fixmap section.
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
