Message-Id: <20071030192102.364981487@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:00 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 03/28] Add cmpxchg64 and cmpxchg64_local to alpha
Content-Disposition: inline; filename=add-cmpxchg64-to-alpha.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, rth@twiddle.net, ink@jurassic.park.msu.ru
List-ID: <linux-mm.kvack.org>

Make sure that at least cmpxchg64_local is available on all architectures to use
for unsigned long long values.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: rth@twiddle.net
CC: ink@jurassic.park.msu.ru
---
 include/asm-alpha/system.h |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6-lttng/include/asm-alpha/system.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-alpha/system.h	2007-08-27 11:23:08.000000000 -0400
+++ linux-2.6-lttng/include/asm-alpha/system.h	2007-08-27 11:23:46.000000000 -0400
@@ -687,6 +687,7 @@ __cmpxchg(volatile void *ptr, unsigned l
      (__typeof__(*(ptr))) __cmpxchg((ptr), (unsigned long)_o_,		 \
 				    (unsigned long)_n_, sizeof(*(ptr))); \
   })
+#define cmpxchg64	cmpxchg
 
 static inline unsigned long
 __cmpxchg_u8_local(volatile char *m, long old, long new)
@@ -809,6 +810,7 @@ __cmpxchg_local(volatile void *ptr, unsi
      (__typeof__(*(ptr))) __cmpxchg_local((ptr), (unsigned long)_o_,	 \
 				    (unsigned long)_n_, sizeof(*(ptr))); \
   })
+#define cmpxchg64_local	cmpxchg_local
 
 #endif /* __ASSEMBLY__ */
 

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
