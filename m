Message-Id: <20071030192102.985443792@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:02 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 05/28] Add cmpxchg64 and cmpxchg64_local to powerpc
Content-Disposition: inline; filename=add-cmpxchg64-to-powerpc.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

Make sure that at least cmpxchg64_local is available on all architectures to use
for unsigned long long values.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Acked-by: Paul Mackerras <paulus@samba.org>
CC: linuxppc-dev@ozlabs.org
---
 include/asm-powerpc/system.h |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6-lttng/include/asm-powerpc/system.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-powerpc/system.h	2007-09-24 10:50:11.000000000 -0400
+++ linux-2.6-lttng/include/asm-powerpc/system.h	2007-09-24 11:01:04.000000000 -0400
@@ -488,6 +488,12 @@ __cmpxchg_local(volatile void *ptr, unsi
  */
 #define NET_IP_ALIGN	0
 #define NET_SKB_PAD	L1_CACHE_BYTES
+
+#define cmpxchg64	cmpxchg
+#define cmpxchg64_local	cmpxchg_local
+#else
+#include <asm-generic/cmpxchg-local.h>
+#define cmpxchg64_local(ptr,o,n) __cmpxchg64_local_generic((ptr), (o), (n))
 #endif
 
 #define arch_align_stack(x) (x)

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
