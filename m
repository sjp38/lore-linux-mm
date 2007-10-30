Message-Id: <20071030192106.745173888@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:13 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 16/28] m32r: build fix of arch/m32r/kernel/smpboot.c
Content-Disposition: inline; filename=fix-m32r-include-sched-h-in-smpboot.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Hirokazu Takata <takata@linux-m32r.org>
List-ID: <linux-mm.kvack.org>

This patch is for Mathieu Desnoyers's include/asm-m32r/local.h.
Applying the new include/asm-m32r/local.h, inclusion of linux/sched.h
is needed to fix a build error of arch/m32r/kernel/smpboot.c.

<--  snip  -->
  ...
  CC      arch/m32r/kernel/smpboot.o
/project/m32r-linux/kernel/work/linux-2.6_dev.git/arch/m32r/kernel/smpboot.c: In function 'do_boot_cpu':
/project/m32r-linux/kernel/work/linux-2.6_dev.git/arch/m32r/kernel/smpboot.c:279: error: implicit declaration of function 'fork_idle'
/project/m32r-linux/kernel/work/linux-2.6_dev.git/arch/m32r/kernel/smpboot.c:279: warning: assignment makes pointer from integer without a cast
/project/m32r-linux/kernel/work/linux-2.6_dev.git/arch/m32r/kernel/smpboot.c:283: error: dereferencing pointer to incomplete type
/project/m32r-linux/kernel/work/linux-2.6_dev.git/arch/m32r/kernel/smpboot.c:289: error: dereferencing pointer to incomplete type
/project/m32r-linux/kernel/work/linux-2.6_dev.git/arch/m32r/kernel/smpboot.c:290: error: implicit declaration of function 'task_thread_info'
/project/m32r-linux/kernel/work/linux-2.6_dev.git/arch/m32r/kernel/smpboot.c:290: error: invalid type argument of '->'
/project/m32r-linux/kernel/work/linux-2.6_dev.git/arch/m32r/kernel/smpboot.c: In function 'start_secondary':
/project/m32r-linux/kernel/work/linux-2.6_dev.git/arch/m32r/kernel/smpboot.c:429: error: implicit declaration of function 'cpu_init'
make[2]: *** [arch/m32r/kernel/smpboot.o] Error 1
<--  snip  -->

Signed-off-by: Hirokazu Takata <takata@linux-m32r.org>
---
 arch/m32r/kernel/smpboot.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6-lttng/arch/m32r/kernel/smpboot.c
===================================================================
--- linux-2.6-lttng.orig/arch/m32r/kernel/smpboot.c	2007-08-21 09:57:48.000000000 -0400
+++ linux-2.6-lttng/arch/m32r/kernel/smpboot.c	2007-08-21 09:58:12.000000000 -0400
@@ -43,6 +43,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
+#include <linux/sched.h>
 #include <linux/err.h>
 #include <linux/irq.h>
 #include <linux/bootmem.h>

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
