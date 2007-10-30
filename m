Message-Id: <20071030192105.557027608@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:10 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 13/28] Add cmpxchg_local, cmpxchg64 and cmpxchg64_local to ia64
Content-Disposition: inline; filename=add-cmpxchg-local-to-ia64.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, tony.luck@intel.com, Keith Owens <kaos@ocs.com.au>
List-ID: <linux-mm.kvack.org>

Add the primitives cmpxchg_local, cmpxchg64 and cmpxchg64_local to ia64. They
use cmpxchg_acq as underlying macro, just like the already existing ia64
cmpxchg().

Changelog:

ia64 cmpxchg_local coding style fix
Quoting Keith Owens:

As a matter of coding style, I prefer

#define cmpxchg_local   cmpxchg
#define cmpxchg64_local cmpxchg64

Which makes it absolutely clear that they are the same code.  With your
patch, humans have to do a string compare of two defines to see if they
are the same.

Note cmpxchg is *not* a performance win vs interrupt disable / enable on IA64.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Acked-by: Christoph Lameter <clameter@sgi.com>
CC: tony.luck@intel.com
CC: Keith Owens <kaos@ocs.com.au>
---
 include/asm-ia64/intrinsics.h |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-2.6-lttng/include/asm-ia64/intrinsics.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-ia64/intrinsics.h	2007-08-12 09:33:57.000000000 -0400
+++ linux-2.6-lttng/include/asm-ia64/intrinsics.h	2007-08-12 15:09:49.000000000 -0400
@@ -158,6 +158,10 @@ extern long ia64_cmpxchg_called_with_bad
 
 /* for compatibility with other platforms: */
 #define cmpxchg(ptr,o,n)	cmpxchg_acq(ptr,o,n)
+#define cmpxchg64(ptr,o,n)	cmpxchg_acq(ptr,o,n)
+
+#define cmpxchg_local		cmpxchg
+#define cmpxchg64_local		cmpxchg64
 
 #ifdef CONFIG_IA64_DEBUG_CMPXCHG
 # define CMPXCHG_BUGCHECK_DECL	int _cmpxchg_bugcheck_count = 128;

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
