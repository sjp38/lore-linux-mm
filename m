Date: Wed, 16 Apr 2008 11:39:36 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH] - Increase MAX_APICS for large configs
Message-ID: <20080416163936.GA23099@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Increase the maximum number of apics when running very large
configurations. This patch has no affect on most systems.

Signed-off-by: Jack Steiner <steiner@sgi.com>

---

I think this area of the code will be substantially changed when
the full x2apic patch is available. In the meantime, this seems
like an acceptible alternative. The patch has no effect on any 32-bit
kernel. It adds ~4k to the size of 64-bit kernels but only if
NR_CPUS > 255.


 include/asm-x86/mpspec_def.h |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: linux/include/asm-x86/mpspec_def.h
===================================================================
--- linux.orig/include/asm-x86/mpspec_def.h	2008-03-29 06:45:28.000000000 -0500
+++ linux/include/asm-x86/mpspec_def.h	2008-03-31 14:17:01.000000000 -0500
@@ -17,10 +17,11 @@
 # define MAX_MPC_ENTRY 1024
 # define MAX_APICS      256
 #else
-/*
- * A maximum of 255 APICs with the current APIC ID architecture.
- */
-# define MAX_APICS 255
+# if NR_CPUS <= 255
+#  define MAX_APICS     255
+# else
+#  define MAX_APICS   32768
+# endif
 #endif
 
 struct intel_mp_floating {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
