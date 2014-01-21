Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 44C106B00B8
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 18:36:22 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so9068495pab.40
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 15:36:21 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id p3si7240633pbj.248.2014.01.21.15.36.19
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 15:36:20 -0800 (PST)
Subject: [PATCH v9 5/6] MCS Lock: Order the header files in Kbuild of each
 architecture in alphabetical order
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1390320729.git.tim.c.chen@linux.intel.com>
References: <cover.1390320729.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Jan 2014 15:36:16 -0800
Message-ID: <1390347376.3138.66.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

From: Peter Zijlstra <peterz@infradead.org>

We perform a clean up of the Kbuid files in each architecture.
We order the files in each Kbuild in alphabetical order
by running the below script on each Kbuild file:

gawk '/^generic-y/ {
        i = 3;
        do {
                for (; i<=NF; i++) {
                        if ($i == "\\") {
                                getline;
                                i=1;
                                continue;
                        }
                        if ($i != "")
                                hdr[$i] = $i;
                }
                break;
        } while (1);
        next;
}
END {
        n = asort(hdr);
        for (i=1; i<=n; i++)
                print "generic-y += " hdr[i];
}'

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 arch/alpha/include/asm/Kbuild      |  4 ++--
 arch/arc/include/asm/Kbuild        |  6 +++---
 arch/arm/include/asm/Kbuild        |  2 +-
 arch/arm64/include/asm/Kbuild      |  4 ++--
 arch/avr32/include/asm/Kbuild      | 38 +++++++++++++++++++-------------------
 arch/blackfin/include/asm/Kbuild   |  4 ++--
 arch/c6x/include/asm/Kbuild        |  2 +-
 arch/cris/include/asm/Kbuild       |  2 +-
 arch/frv/include/asm/Kbuild        |  2 +-
 arch/hexagon/include/asm/Kbuild    |  6 +++---
 arch/ia64/include/asm/Kbuild       |  4 ++--
 arch/m32r/include/asm/Kbuild       |  2 +-
 arch/m68k/include/asm/Kbuild       |  4 ++--
 arch/metag/include/asm/Kbuild      |  2 +-
 arch/microblaze/include/asm/Kbuild |  4 ++--
 arch/mips/include/asm/Kbuild       |  2 +-
 arch/mn10300/include/asm/Kbuild    |  2 +-
 arch/openrisc/include/asm/Kbuild   |  8 ++++----
 arch/parisc/include/asm/Kbuild     | 26 +++++++++++++++++++++-----
 arch/powerpc/include/asm/Kbuild    |  4 ++--
 arch/s390/include/asm/Kbuild       |  2 +-
 arch/score/include/asm/Kbuild      |  2 +-
 arch/sh/include/asm/Kbuild         |  6 +++---
 arch/sparc/include/asm/Kbuild      |  8 ++++----
 arch/tile/include/asm/Kbuild       |  2 +-
 arch/um/include/asm/Kbuild         | 29 ++++++++++++++++++++++++-----
 arch/unicore32/include/asm/Kbuild  |  2 +-
 arch/xtensa/include/asm/Kbuild     |  2 +-
 28 files changed, 108 insertions(+), 73 deletions(-)

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index f01fb50..532356b 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -1,6 +1,6 @@
 
-generic-y += clkdev.h
 
+generic-y += clkdev.h
 generic-y += exec.h
-generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += trace_clock.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 9ae21c1..4348dbc 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -1,15 +1,15 @@
 generic-y += auxvec.h
 generic-y += barrier.h
-generic-y += bugs.h
 generic-y += bitsperlong.h
+generic-y += bugs.h
 generic-y += clkdev.h
 generic-y += cputime.h
 generic-y += device.h
 generic-y += div64.h
 generic-y += emergency-restart.h
 generic-y += errno.h
-generic-y += fcntl.h
 generic-y += fb.h
+generic-y += fcntl.h
 generic-y += ftrace.h
 generic-y += hardirq.h
 generic-y += hw_irq.h
@@ -29,6 +29,7 @@ generic-y += pci.h
 generic-y += percpu.h
 generic-y += poll.h
 generic-y += posix_types.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += sembuf.h
@@ -47,4 +48,3 @@ generic-y += ucontext.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index c38b58c..8f37076 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -17,6 +17,7 @@ generic-y += msgbuf.h
 generic-y += param.h
 generic-y += parport.h
 generic-y += poll.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += sections.h
 generic-y += segment.h
@@ -33,4 +34,3 @@ generic-y += termios.h
 generic-y += timex.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
-generic-y += preempt.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index 519f89f..a14534d 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -29,6 +29,7 @@ generic-y += pci.h
 generic-y += percpu.h
 generic-y += poll.h
 generic-y += posix_types.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += sections.h
@@ -39,8 +40,8 @@ generic-y += shmbuf.h
 generic-y += sizes.h
 generic-y += socket.h
 generic-y += sockios.h
-generic-y += switch_to.h
 generic-y += swab.h
+generic-y += switch_to.h
 generic-y += termbits.h
 generic-y += termios.h
 generic-y += topology.h
@@ -50,4 +51,3 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 658001b..d831429 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -1,20 +1,20 @@
 
-generic-y	+= clkdev.h
-generic-y       += cputime.h
-generic-y       += delay.h
-generic-y       += device.h
-generic-y       += div64.h
-generic-y       += emergency-restart.h
-generic-y	+= exec.h
-generic-y       += futex.h
-generic-y	+= preempt.h
-generic-y       += irq_regs.h
-generic-y	+= param.h
-generic-y       += local.h
-generic-y       += local64.h
-generic-y       += percpu.h
-generic-y       += scatterlist.h
-generic-y       += sections.h
-generic-y       += topology.h
-generic-y	+= trace_clock.h
-generic-y       += xor.h
+generic-y += clkdev.h
+generic-y += cputime.h
+generic-y += delay.h
+generic-y += device.h
+generic-y += div64.h
+generic-y += emergency-restart.h
+generic-y += exec.h
+generic-y += futex.h
+generic-y += irq_regs.h
+generic-y += local.h
+generic-y += local64.h
+generic-y += param.h
+generic-y += percpu.h
+generic-y += preempt.h
+generic-y += scatterlist.h
+generic-y += sections.h
+generic-y += topology.h
+generic-y += trace_clock.h
+generic-y += xor.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index f2b4347..37b9282 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -17,14 +17,15 @@ generic-y += irq_regs.h
 generic-y += kdebug.h
 generic-y += kmap_types.h
 generic-y += kvm_para.h
-generic-y += local64.h
 generic-y += local.h
+generic-y += local64.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += mutex.h
 generic-y += param.h
 generic-y += percpu.h
 generic-y += pgalloc.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += sembuf.h
@@ -44,4 +45,3 @@ generic-y += ucontext.h
 generic-y += unaligned.h
 generic-y += user.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index fc0b3c3..4b3f516 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -34,6 +34,7 @@ generic-y += percpu.h
 generic-y += pgalloc.h
 generic-y += poll.h
 generic-y += posix_types.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += segment.h
@@ -56,4 +57,3 @@ generic-y += ucontext.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 199b1a9..85c090d 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -9,7 +9,7 @@ generic-y += exec.h
 generic-y += kvm_para.h
 generic-y += linkage.h
 generic-y += module.h
+generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += vga.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 74742dc..695246e 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -1,5 +1,5 @@
 
 generic-y += clkdev.h
 generic-y += exec.h
-generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += trace_clock.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index ada843c..17f3996 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -24,14 +24,15 @@ generic-y += ipcbuf.h
 generic-y += irq_regs.h
 generic-y += kdebug.h
 generic-y += kmap_types.h
-generic-y += local64.h
 generic-y += local.h
+generic-y += local64.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += pci.h
 generic-y += percpu.h
 generic-y += poll.h
 generic-y += posix_types.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += rwsem.h
 generic-y += scatterlist.h
@@ -44,8 +45,8 @@ generic-y += siginfo.h
 generic-y += sizes.h
 generic-y += socket.h
 generic-y += sockios.h
-generic-y += statfs.h
 generic-y += stat.h
+generic-y += statfs.h
 generic-y += termbits.h
 generic-y += termios.h
 generic-y += topology.h
@@ -54,4 +55,3 @@ generic-y += types.h
 generic-y += ucontext.h
 generic-y += unaligned.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index f93ee08..6f1de3b 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -2,6 +2,6 @@
 generic-y += clkdev.h
 generic-y += exec.h
 generic-y += kvm_para.h
-generic-y += trace_clock.h
 generic-y += preempt.h
-generic-y += vtime.h
\ No newline at end of file
+generic-y += trace_clock.h
+generic-y += vtime.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 2b58c5f..5cfbdd4 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -2,5 +2,5 @@
 generic-y += clkdev.h
 generic-y += exec.h
 generic-y += module.h
-generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += trace_clock.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index a5d27f2..c690a6f 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -13,11 +13,12 @@ generic-y += irq_regs.h
 generic-y += kdebug.h
 generic-y += kmap_types.h
 generic-y += kvm_para.h
-generic-y += local64.h
 generic-y += local.h
+generic-y += local64.h
 generic-y += mman.h
 generic-y += mutex.h
 generic-y += percpu.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += sections.h
@@ -31,4 +32,3 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 84d0c1d..3fc4a2e 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -30,6 +30,7 @@ generic-y += pci.h
 generic-y += percpu.h
 generic-y += poll.h
 generic-y += posix_types.h
+generic-y += preempt.h
 generic-y += scatterlist.h
 generic-y += sections.h
 generic-y += sembuf.h
@@ -52,4 +53,3 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index a824265..88968fa 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -2,6 +2,6 @@
 generic-y += barrier.h
 generic-y += clkdev.h
 generic-y += exec.h
-generic-y += trace_clock.h
-generic-y += syscalls.h
 generic-y += preempt.h
+generic-y += syscalls.h
+generic-y += trace_clock.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 1acbb8b..ef38961 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -6,11 +6,11 @@ generic-y += local64.h
 generic-y += mutex.h
 generic-y += parport.h
 generic-y += percpu.h
+generic-y += preempt.h
 generic-y += scatterlist.h
 generic-y += sections.h
 generic-y += segment.h
 generic-y += serial.h
 generic-y += trace_clock.h
-generic-y += preempt.h
 generic-y += ucontext.h
 generic-y += xor.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index 032143e..6fb781f 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -2,5 +2,5 @@
 generic-y += barrier.h
 generic-y += clkdev.h
 generic-y += exec.h
-generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += trace_clock.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index da1951a..32b5562 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -10,8 +10,8 @@ generic-y += bugs.h
 generic-y += cacheflush.h
 generic-y += checksum.h
 generic-y += clkdev.h
-generic-y += cmpxchg.h
 generic-y += cmpxchg-local.h
+generic-y += cmpxchg.h
 generic-y += cputime.h
 generic-y += current.h
 generic-y += device.h
@@ -41,6 +41,7 @@ generic-y += pci.h
 generic-y += percpu.h
 generic-y += poll.h
 generic-y += posix_types.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += sections.h
@@ -53,11 +54,11 @@ generic-y += siginfo.h
 generic-y += signal.h
 generic-y += socket.h
 generic-y += sockios.h
-generic-y += statfs.h
 generic-y += stat.h
+generic-y += statfs.h
 generic-y += string.h
-generic-y += switch_to.h
 generic-y += swab.h
+generic-y += switch_to.h
 generic-y += termbits.h
 generic-y += termios.h
 generic-y += topology.h
@@ -68,4 +69,3 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index 34b0be4..bb0d9ebb 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -1,8 +1,24 @@
 
+generic-y += auxvec.h
 generic-y += barrier.h
-generic-y += word-at-a-time.h auxvec.h user.h cputime.h emergency-restart.h \
-	  segment.h topology.h vga.h device.h percpu.h hw_irq.h mutex.h \
-	  div64.h irq_regs.h kdebug.h kvm_para.h local64.h local.h param.h \
-	  poll.h xor.h clkdev.h exec.h
-generic-y += trace_clock.h
+generic-y += clkdev.h
+generic-y += cputime.h
+generic-y += device.h
+generic-y += emergency-restart.h
+generic-y += exec.h
+generic-y += hw_irq.h
+generic-y += irq_regs.h
+generic-y += kdebug.h
+generic-y += kvm_para.h
+generic-y += local.h
+generic-y += local64.h
+generic-y += mutex.h
+generic-y += param.h
+generic-y += percpu.h
 generic-y += preempt.h
+generic-y += topology.h
+generic-y += trace_clock.h
+generic-y += user.h
+generic-y += vga.h
+generic-y += word-at-a-time.h
+generic-y += xor.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index d8f9d2f..8b19a80 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -1,6 +1,6 @@
 
 generic-y += clkdev.h
+generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += trace_clock.h
-generic-y += preempt.h
-generic-y += vtime.h
\ No newline at end of file
+generic-y += vtime.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 7a5288f..6bd5f27 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -1,5 +1,5 @@
 

 generic-y += clkdev.h
-generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += trace_clock.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index fe7471e..064b55f 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -3,6 +3,6 @@ header-y +=
 
 generic-y += barrier.h
 generic-y += clkdev.h
+generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 231efbb..8856e73 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -14,12 +14,13 @@ generic-y += irq_regs.h
 generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
+generic-y += mman.h
+generic-y += msgbuf.h
 generic-y += param.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += poll.h
-generic-y += mman.h
-generic-y += msgbuf.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += sembuf.h
@@ -34,4 +35,3 @@ generic-y += termios.h
 generic-y += trace_clock.h
 generic-y += ucontext.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index bf39066..3e78fda 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -6,14 +6,14 @@ generic-y += cputime.h
 generic-y += div64.h
 generic-y += emergency-restart.h
 generic-y += exec.h
-generic-y += linkage.h
-generic-y += local64.h
-generic-y += mutex.h
 generic-y += irq_regs.h
+generic-y += linkage.h
 generic-y += local.h
+generic-y += local64.h
 generic-y += module.h
+generic-y += mutex.h
+generic-y += preempt.h
 generic-y += serial.h
 generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
-generic-y += preempt.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index 22f3bd1..948549c 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -24,6 +24,7 @@ generic-y += param.h
 generic-y += parport.h
 generic-y += poll.h
 generic-y += posix_types.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += sembuf.h
@@ -38,4 +39,3 @@ generic-y += termios.h
 generic-y += trace_clock.h
 generic-y += types.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index fdde187..1cfae1f 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -1,6 +1,25 @@
-generic-y += bug.h cputime.h device.h emergency-restart.h futex.h hardirq.h
-generic-y += hw_irq.h irq_regs.h kdebug.h percpu.h sections.h topology.h xor.h
-generic-y += ftrace.h pci.h io.h param.h delay.h mutex.h current.h exec.h
-generic-y += switch_to.h clkdev.h
-generic-y += trace_clock.h
+generic-y += bug.h
+generic-y += clkdev.h
+generic-y += cputime.h
+generic-y += current.h
+generic-y += delay.h
+generic-y += device.h
+generic-y += emergency-restart.h
+generic-y += exec.h
+generic-y += ftrace.h
+generic-y += futex.h
+generic-y += hardirq.h
+generic-y += hw_irq.h
+generic-y += io.h
+generic-y += irq_regs.h
+generic-y += kdebug.h
+generic-y += mutex.h
+generic-y += param.h
+generic-y += pci.h
+generic-y += percpu.h
 generic-y += preempt.h
+generic-y += sections.h
+generic-y += switch_to.h
+generic-y += topology.h
+generic-y += trace_clock.h
+generic-y += xor.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 00045cb..a61f73a 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -32,6 +32,7 @@ generic-y += parport.h
 generic-y += percpu.h
 generic-y += poll.h
 generic-y += posix_types.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += sections.h
@@ -60,4 +61,3 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
-generic-y += preempt.h
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 228d6ae..68da9d4 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -19,6 +19,7 @@ generic-y += linkage.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += percpu.h
+generic-y += preempt.h
 generic-y += resource.h
 generic-y += scatterlist.h
 generic-y += sections.h
@@ -28,4 +29,3 @@ generic-y += termios.h
 generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += xor.h
-generic-y += preempt.h
-- 
1.7.11.7



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
