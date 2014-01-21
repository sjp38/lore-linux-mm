Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 955F26B003B
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 20:24:44 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so6181745pad.25
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 17:24:44 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ln7si3085653pab.236.2014.01.20.17.24.42
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 17:24:43 -0800 (PST)
Subject: [PATCH v8 6/6] MCS Lock: Allow architecture specific asm files to
 be used for contended case
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1390239879.git.tim.c.chen@linux.intel.com>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jan 2014 17:24:39 -0800
Message-ID: <1390267479.3138.40.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

From: Peter Zijlstra <peterz@infradead.org>

This patch allows each architecture to add its specific assembly optimized
arch_mcs_spin_lock_contended and arch_mcs_spinlock_uncontended for
MCS lock and unlock functions.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 arch/alpha/include/asm/Kbuild      |  1 +
 arch/arc/include/asm/Kbuild        |  1 +
 arch/arm/include/asm/Kbuild        |  1 +
 arch/arm64/include/asm/Kbuild      |  1 +
 arch/avr32/include/asm/Kbuild      |  1 +
 arch/blackfin/include/asm/Kbuild   |  1 +
 arch/c6x/include/asm/Kbuild        |  1 +
 arch/cris/include/asm/Kbuild       |  1 +
 arch/frv/include/asm/Kbuild        |  1 +
 arch/hexagon/include/asm/Kbuild    |  1 +
 arch/ia64/include/asm/Kbuild       |  2 +-
 arch/m32r/include/asm/Kbuild       |  1 +
 arch/m68k/include/asm/Kbuild       |  1 +
 arch/metag/include/asm/Kbuild      |  1 +
 arch/microblaze/include/asm/Kbuild |  1 +
 arch/mips/include/asm/Kbuild       |  1 +
 arch/mn10300/include/asm/Kbuild    |  1 +
 arch/openrisc/include/asm/Kbuild   |  1 +
 arch/parisc/include/asm/Kbuild     |  1 +
 arch/powerpc/include/asm/Kbuild    |  2 +-
 arch/s390/include/asm/Kbuild       |  1 +
 arch/score/include/asm/Kbuild      |  1 +
 arch/sh/include/asm/Kbuild         |  1 +
 arch/sparc/include/asm/Kbuild      |  1 +
 arch/tile/include/asm/Kbuild       |  1 +
 arch/um/include/asm/Kbuild         |  1 +
 arch/unicore32/include/asm/Kbuild  |  1 +
 arch/x86/include/asm/Kbuild        |  1 +
 arch/xtensa/include/asm/Kbuild     |  1 +
 include/asm-generic/mcs_spinlock.h | 13 +++++++++++++
 include/linux/mcs_spinlock.h       |  2 ++
 31 files changed, 44 insertions(+), 2 deletions(-)
 create mode 100644 include/asm-generic/mcs_spinlock.h

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index f01fb50..14cbbbc 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += clkdev.h
 generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 9ae21c1..c0773a5 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -48,3 +48,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index c38b58c..c68cfdd 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -34,3 +34,4 @@ generic-y += timex.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index 519f89f..24a3c10 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -51,3 +51,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 658001b..466e13d 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -18,3 +18,4 @@ generic-y       += sections.h
 generic-y       += topology.h
 generic-y	+= trace_clock.h
 generic-y       += xor.h
+generic-y += mcs_spinlock.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index f2b4347..0bd1c5c 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -45,3 +45,4 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index fc0b3c3..21d7100 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -57,3 +57,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 199b1a9..c571cc1 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -13,3 +13,4 @@ generic-y += trace_clock.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 74742dc..ccca92e 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -3,3 +3,4 @@ generic-y += clkdev.h
 generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index ada843c..553077d 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -55,3 +55,4 @@ generic-y += ucontext.h
 generic-y += unaligned.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index f93ee08..25aed55 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -4,4 +4,4 @@ generic-y += exec.h
 generic-y += kvm_para.h
 generic-y += trace_clock.h
 generic-y += preempt.h
-generic-y += vtime.h
\ No newline at end of file
+generic-y += vtime.hgeneric-y += mcs_spinlock.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 2b58c5f..d64fdd1 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += exec.h
 generic-y += module.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index a5d27f2..1f4d44c 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -32,3 +32,4 @@ generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 84d0c1d..ae0ae6e 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -53,3 +53,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index a824265..6eb70bd 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -5,3 +5,4 @@ generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += syscalls.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 1acbb8b..c718d63 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -14,3 +14,4 @@ generic-y += trace_clock.h
 generic-y += preempt.h
 generic-y += ucontext.h
 generic-y += xor.h
+generic-y += mcs_spinlock.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index 032143e..1393ae5 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += clkdev.h
 generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index da1951a..7e049d3 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -69,3 +69,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index 34b0be4..ebe1649 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -6,3 +6,4 @@ generic-y += word-at-a-time.h auxvec.h user.h cputime.h emergency-restart.h \
 	  poll.h xor.h clkdev.h exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index d8f9d2f..426001b 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -3,4 +3,4 @@ generic-y += clkdev.h
 generic-y += rwsem.h
 generic-y += trace_clock.h
 generic-y += preempt.h
-generic-y += vtime.h
\ No newline at end of file
+generic-y += vtime.hgeneric-y += mcs_spinlock.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 7a5288f..8508913 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -3,3 +3,4 @@
 generic-y += clkdev.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index fe7471e..8e39afc 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -6,3 +6,4 @@ generic-y += clkdev.h
 generic-y += trace_clock.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 231efbb..1aed131 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -35,3 +35,4 @@ generic-y += trace_clock.h
 generic-y += ucontext.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index bf39066..8843299 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -17,3 +17,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index 22f3bd1..152fc48 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -39,3 +39,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index fdde187..620d729 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += ftrace.h pci.h io.h param.h delay.h mutex.h current.h exec.h
 generic-y += switch_to.h clkdev.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 00045cb..cd7822c 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -61,3 +61,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 7f66985..a8fee07 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -5,3 +5,4 @@ genhdr-y += unistd_64.h
 genhdr-y += unistd_x32.h
 
 generic-y += clkdev.h
+generic-y += mcs_spinlock.h
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 228d6ae..9653e5c 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -29,3 +29,4 @@ generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/include/asm-generic/mcs_spinlock.h b/include/asm-generic/mcs_spinlock.h
new file mode 100644
index 0000000..10cd4ff
--- /dev/null
+++ b/include/asm-generic/mcs_spinlock.h
@@ -0,0 +1,13 @@
+#ifndef __ASM_MCS_SPINLOCK_H
+#define __ASM_MCS_SPINLOCK_H
+
+/*
+ * Architectures can define their own:
+ *
+ *   arch_mcs_spin_lock_contended(l)
+ *   arch_mcs_spin_unlock_contended(l)
+ *
+ * See kernel/locking/mcs_spinlock.c.
+ */
+
+#endif /* __ASM_MCS_SPINLOCK_H */
diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
index d54bb23..164298a 100644
--- a/include/linux/mcs_spinlock.h
+++ b/include/linux/mcs_spinlock.h
@@ -12,6 +12,8 @@
 #ifndef __LINUX_MCS_SPINLOCK_H
 #define __LINUX_MCS_SPINLOCK_H
 
+#include <asm/mcs_spinlock.h>
+
 struct mcs_spinlock {
 	struct mcs_spinlock *next;
 	int locked; /* 1 if lock acquired */
-- 
1.7.11.7


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
