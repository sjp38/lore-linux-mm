Message-Id: <20071030192102.677087409@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:01 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 04/28] Add cmpxchg64 and cmpxchg64_local to mips
Content-Disposition: inline; filename=add-cmpxchg64-to-mips.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, ralf@linux-mips.org
List-ID: <linux-mm.kvack.org>

Make sure that at least cmpxchg64_local is available on all architectures to use
for unsigned long long values.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: ralf@linux-mips.org
CC linux-mips@linux-mips.org
---
 include/asm-mips/cmpxchg.h |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux-2.6-lttng/include/asm-mips/cmpxchg.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-mips/cmpxchg.h	2007-10-12 12:05:06.000000000 -0400
+++ linux-2.6-lttng/include/asm-mips/cmpxchg.h	2007-10-12 12:08:56.000000000 -0400
@@ -104,4 +104,13 @@ extern void __cmpxchg_called_with_bad_po
 #define cmpxchg(ptr, old, new)		__cmpxchg(ptr, old, new, smp_llsc_mb())
 #define cmpxchg_local(ptr, old, new)	__cmpxchg(ptr, old, new, )
 
+#define cmpxchg64	cmpxchg
+
+#ifdef CONFIG_64BIT
+#define cmpxchg64_local	cmpxchg_local
+#else
+#include <asm-generic/cmpxchg-local.h>
+#define cmpxchg64_local(ptr,o,n)	__cmpxchg64_local_generic((ptr),(o),(n))
+#endif
+
 #endif /* __ASM_CMPXCHG_H */

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
