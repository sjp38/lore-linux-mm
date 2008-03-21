Date: Fri, 21 Mar 2008 08:31:57 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - Increase max physical memory size of x86_64
Message-ID: <20080321133157.GA10911@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, ak@suse.de, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Increase the maximum physical address size of x86_64 system
to 44-bits. This is in preparation for future chips that
support larger physical memory sizes.

	Signed-off-by: Jack Steiner <steiner@sgi.com>

---
 include/asm-x86/sparsemem.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux/include/asm-x86/sparsemem.h
===================================================================
--- linux.orig/include/asm-x86/sparsemem.h	2008-03-10 00:22:27.000000000 -0500
+++ linux/include/asm-x86/sparsemem.h	2008-03-11 14:46:29.000000000 -0500
@@ -26,8 +26,8 @@
 # endif
 #else /* CONFIG_X86_32 */
 # define SECTION_SIZE_BITS	27 /* matt - 128 is convenient right now */
-# define MAX_PHYSADDR_BITS	40
-# define MAX_PHYSMEM_BITS	40
+# define MAX_PHYSADDR_BITS	44
+# define MAX_PHYSMEM_BITS	44
 #endif
 
 #endif /* CONFIG_SPARSEMEM */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
