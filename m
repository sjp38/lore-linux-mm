Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C77566B027A
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:49:40 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id s5so19154873wra.3
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:49:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q23si13686952wmf.43.2017.12.27.08.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:49:39 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 18/74] x86/doc: Remove obvious weirdnesses from the x86 MM layout documentation
Date: Wed, 27 Dec 2017 17:45:51 +0100
Message-Id: <20171227164614.835029879@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Peter Zijlstra <peterz@infradead.org>

commit e8ffe96e5933d417195268478479933d56213a3f upstream.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
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
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

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
