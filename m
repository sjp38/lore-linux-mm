Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA7A6B000D
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 09:02:28 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m78so1081668wma.7
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 06:02:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i196sor431444wme.22.2018.03.09.06.02.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 06:02:27 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH 6/6] arch: add untagged_addr definition for other arches
Date: Fri,  9 Mar 2018 15:02:04 +0100
Message-Id: <89b4bb181a0622d2c581699bb3814fc041078d04.1520600533.git.andreyknvl@google.com>
In-Reply-To: <cover.1520600533.git.andreyknvl@google.com>
References: <cover.1520600533.git.andreyknvl@google.com>
In-Reply-To: <cover.1520600533.git.andreyknvl@google.com>
References: <cover.1520600533.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Philippe Ombredanne <pombredanne@nexb.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Kate Stewart <kstewart@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Shakeel Butt <shakeelb@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Mark Salter <msalter@redhat.com>, Aurelien Jacquiot <jacquiot.aurelien@gmail.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, James Hogan <jhogan@kernel.org>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, Ley Foon Tan <lftan@altera.com>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E . J . Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Chen Liqin <liqin.linux@gmail.com>, Lennox Wu <lennox.wu@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Andrey Konovalov <andreyknvl@google.com>

To allow arm64 syscalls accept tagged pointers from userspace, we must
untag them when they are passed to the kernel. Since untagging is done in
generic parts of the kernel (like the mm subsystem), the untagged_addr
macro should be defined for all architectures.

Define it as a noop for all other architectures besides arm64.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/alpha/include/asm/uaccess.h      | 2 ++
 arch/arc/include/asm/uaccess.h        | 1 +
 arch/arm/include/asm/uaccess.h        | 2 ++
 arch/blackfin/include/asm/uaccess.h   | 2 ++
 arch/c6x/include/asm/uaccess.h        | 2 ++
 arch/cris/include/asm/uaccess.h       | 2 ++
 arch/frv/include/asm/uaccess.h        | 2 ++
 arch/ia64/include/asm/uaccess.h       | 2 ++
 arch/m32r/include/asm/uaccess.h       | 2 ++
 arch/m68k/include/asm/uaccess.h       | 2 ++
 arch/metag/include/asm/uaccess.h      | 2 ++
 arch/microblaze/include/asm/uaccess.h | 2 ++
 arch/mips/include/asm/uaccess.h       | 2 ++
 arch/mn10300/include/asm/uaccess.h    | 2 ++
 arch/nios2/include/asm/uaccess.h      | 2 ++
 arch/openrisc/include/asm/uaccess.h   | 2 ++
 arch/parisc/include/asm/uaccess.h     | 2 ++
 arch/powerpc/include/asm/uaccess.h    | 2 ++
 arch/riscv/include/asm/uaccess.h      | 2 ++
 arch/score/include/asm/uaccess.h      | 2 ++
 arch/sh/include/asm/uaccess.h         | 2 ++
 arch/sparc/include/asm/uaccess.h      | 2 ++
 arch/tile/include/asm/uaccess.h       | 2 ++
 arch/x86/include/asm/uaccess.h        | 2 ++
 arch/xtensa/include/asm/uaccess.h     | 2 ++
 include/asm-generic/uaccess.h         | 2 ++
 26 files changed, 51 insertions(+)

diff --git a/arch/alpha/include/asm/uaccess.h b/arch/alpha/include/asm/uaccess.h
index 87d8c4f0307d..09d136bb4ff5 100644
--- a/arch/alpha/include/asm/uaccess.h
+++ b/arch/alpha/include/asm/uaccess.h
@@ -2,6 +2,8 @@
 #ifndef __ALPHA_UACCESS_H
 #define __ALPHA_UACCESS_H
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should be
  * performed or not.  If get_fs() == USER_DS, checking is performed, with
diff --git a/arch/arc/include/asm/uaccess.h b/arch/arc/include/asm/uaccess.h
index c9173c02081c..2a04b7a4aada 100644
--- a/arch/arc/include/asm/uaccess.h
+++ b/arch/arc/include/asm/uaccess.h
@@ -26,6 +26,7 @@
 
 #include <linux/string.h>	/* for generic string functions */
 
+#define untagged_addr(addr)	addr
 
 #define __kernel_ok		(uaccess_kernel())
 
diff --git a/arch/arm/include/asm/uaccess.h b/arch/arm/include/asm/uaccess.h
index 0bf2347495f1..7d4f4e4021f2 100644
--- a/arch/arm/include/asm/uaccess.h
+++ b/arch/arm/include/asm/uaccess.h
@@ -19,6 +19,8 @@
 
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * These two functions allow hooking accesses to userspace to increase
  * system integrity by ensuring that the kernel can not inadvertantly
diff --git a/arch/blackfin/include/asm/uaccess.h b/arch/blackfin/include/asm/uaccess.h
index 45da4bcb050e..fb6bdc54e7bd 100644
--- a/arch/blackfin/include/asm/uaccess.h
+++ b/arch/blackfin/include/asm/uaccess.h
@@ -18,6 +18,8 @@
 #include <asm/segment.h>
 #include <asm/sections.h>
 
+#define untagged_addr(addr)	addr
+
 #define get_ds()        (KERNEL_DS)
 #define get_fs()        (current_thread_info()->addr_limit)
 
diff --git a/arch/c6x/include/asm/uaccess.h b/arch/c6x/include/asm/uaccess.h
index ba6756879f00..f187696cf440 100644
--- a/arch/c6x/include/asm/uaccess.h
+++ b/arch/c6x/include/asm/uaccess.h
@@ -9,6 +9,8 @@
 #ifndef _ASM_C6X_UACCESS_H
 #define _ASM_C6X_UACCESS_H
 
+#define untagged_addr(addr)	addr
+
 #include <linux/types.h>
 #include <linux/compiler.h>
 #include <linux/string.h>
diff --git a/arch/cris/include/asm/uaccess.h b/arch/cris/include/asm/uaccess.h
index 3b42ab0cae93..86d8fbd200c4 100644
--- a/arch/cris/include/asm/uaccess.h
+++ b/arch/cris/include/asm/uaccess.h
@@ -19,6 +19,8 @@
 #include <asm/processor.h>
 #include <asm/page.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should be
  * performed or not.  If get_fs() == USER_DS, checking is performed, with
diff --git a/arch/frv/include/asm/uaccess.h b/arch/frv/include/asm/uaccess.h
index ff9562dc6825..be21b42bde09 100644
--- a/arch/frv/include/asm/uaccess.h
+++ b/arch/frv/include/asm/uaccess.h
@@ -12,6 +12,8 @@
 #ifndef _ASM_UACCESS_H
 #define _ASM_UACCESS_H
 
+#define untagged_addr(addr)	addr
+
 /*
  * User space memory access functions
  */
diff --git a/arch/ia64/include/asm/uaccess.h b/arch/ia64/include/asm/uaccess.h
index a74524f2d625..1c46bf1c4f73 100644
--- a/arch/ia64/include/asm/uaccess.h
+++ b/arch/ia64/include/asm/uaccess.h
@@ -42,6 +42,8 @@
 #include <asm/io.h>
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * For historical reasons, the following macros are grossly misnamed:
  */
diff --git a/arch/m32r/include/asm/uaccess.h b/arch/m32r/include/asm/uaccess.h
index 9d89bc3d8181..6e0fe6b215be 100644
--- a/arch/m32r/include/asm/uaccess.h
+++ b/arch/m32r/include/asm/uaccess.h
@@ -16,6 +16,8 @@
 #include <asm/setup.h>
 #include <linux/prefetch.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should be
  * performed or not.  If get_fs() == USER_DS, checking is performed, with
diff --git a/arch/m68k/include/asm/uaccess.h b/arch/m68k/include/asm/uaccess.h
index e896466a41a4..02e0c5878ad5 100644
--- a/arch/m68k/include/asm/uaccess.h
+++ b/arch/m68k/include/asm/uaccess.h
@@ -5,3 +5,5 @@
 #include <asm/uaccess_mm.h>
 #endif
 #include <asm/extable.h>
+
+#define untagged_addr(addr)	addr
diff --git a/arch/metag/include/asm/uaccess.h b/arch/metag/include/asm/uaccess.h
index a5311eb36e32..1b2f0478868a 100644
--- a/arch/metag/include/asm/uaccess.h
+++ b/arch/metag/include/asm/uaccess.h
@@ -14,6 +14,8 @@
  * For historical reasons, these macros are grossly misnamed.
  */
 
+#define untagged_addr(addr)	addr
+
 #define MAKE_MM_SEG(s)  ((mm_segment_t) { (s) })
 
 #define KERNEL_DS       MAKE_MM_SEG(0xFFFFFFFF)
diff --git a/arch/microblaze/include/asm/uaccess.h b/arch/microblaze/include/asm/uaccess.h
index 81f16aadbf9e..a66bc26660c3 100644
--- a/arch/microblaze/include/asm/uaccess.h
+++ b/arch/microblaze/include/asm/uaccess.h
@@ -20,6 +20,8 @@
 #include <asm/extable.h>
 #include <linux/string.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * On Microblaze the fs value is actually the top of the corresponding
  * address space.
diff --git a/arch/mips/include/asm/uaccess.h b/arch/mips/include/asm/uaccess.h
index b71306947290..2db7606c388b 100644
--- a/arch/mips/include/asm/uaccess.h
+++ b/arch/mips/include/asm/uaccess.h
@@ -16,6 +16,8 @@
 #include <asm/asm-eva.h>
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should be
  * performed or not.  If get_fs() == USER_DS, checking is performed, with
diff --git a/arch/mn10300/include/asm/uaccess.h b/arch/mn10300/include/asm/uaccess.h
index 5af468fd1359..6604699b34b6 100644
--- a/arch/mn10300/include/asm/uaccess.h
+++ b/arch/mn10300/include/asm/uaccess.h
@@ -17,6 +17,8 @@
 #include <linux/kernel.h>
 #include <asm/page.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should be
  * performed or not.  If get_fs() == USER_DS, checking is performed, with
diff --git a/arch/nios2/include/asm/uaccess.h b/arch/nios2/include/asm/uaccess.h
index dfa3c7cb30b4..36152a7302a8 100644
--- a/arch/nios2/include/asm/uaccess.h
+++ b/arch/nios2/include/asm/uaccess.h
@@ -19,6 +19,8 @@
 
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * Segment stuff
  */
diff --git a/arch/openrisc/include/asm/uaccess.h b/arch/openrisc/include/asm/uaccess.h
index bbf5c79cce7a..5b43d13ab363 100644
--- a/arch/openrisc/include/asm/uaccess.h
+++ b/arch/openrisc/include/asm/uaccess.h
@@ -27,6 +27,8 @@
 #include <asm/page.h>
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should be
  * performed or not.  If get_fs() == USER_DS, checking is performed, with
diff --git a/arch/parisc/include/asm/uaccess.h b/arch/parisc/include/asm/uaccess.h
index ea70e36ce6af..b0f3cd529c8d 100644
--- a/arch/parisc/include/asm/uaccess.h
+++ b/arch/parisc/include/asm/uaccess.h
@@ -11,6 +11,8 @@
 #include <linux/bug.h>
 #include <linux/string.h>
 
+#define untagged_addr(addr)	addr
+
 #define KERNEL_DS	((mm_segment_t){0})
 #define USER_DS 	((mm_segment_t){1})
 
diff --git a/arch/powerpc/include/asm/uaccess.h b/arch/powerpc/include/asm/uaccess.h
index 51bfeb8777f0..07ae1c318166 100644
--- a/arch/powerpc/include/asm/uaccess.h
+++ b/arch/powerpc/include/asm/uaccess.h
@@ -8,6 +8,8 @@
 #include <asm/page.h>
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should be
  * performed or not.  If get_fs() == USER_DS, checking is performed, with
diff --git a/arch/riscv/include/asm/uaccess.h b/arch/riscv/include/asm/uaccess.h
index 14b0b22fb578..e774239aac24 100644
--- a/arch/riscv/include/asm/uaccess.h
+++ b/arch/riscv/include/asm/uaccess.h
@@ -25,6 +25,8 @@
 #include <asm/byteorder.h>
 #include <asm/asm.h>
 
+#define untagged_addr(addr)	addr
+
 #define __enable_user_access()							\
 	__asm__ __volatile__ ("csrs sstatus, %0" : : "r" (SR_SUM) : "memory")
 #define __disable_user_access()							\
diff --git a/arch/score/include/asm/uaccess.h b/arch/score/include/asm/uaccess.h
index a233f3236846..fd16c2a71091 100644
--- a/arch/score/include/asm/uaccess.h
+++ b/arch/score/include/asm/uaccess.h
@@ -5,6 +5,8 @@
 #include <linux/kernel.h>
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 #define get_ds()		(KERNEL_DS)
 #define get_fs()		(current_thread_info()->addr_limit)
 #define segment_eq(a, b)	((a).seg == (b).seg)
diff --git a/arch/sh/include/asm/uaccess.h b/arch/sh/include/asm/uaccess.h
index 32eb56e00c11..31f3ea075190 100644
--- a/arch/sh/include/asm/uaccess.h
+++ b/arch/sh/include/asm/uaccess.h
@@ -5,6 +5,8 @@
 #include <asm/segment.h>
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 #define __addr_ok(addr) \
 	((unsigned long __force)(addr) < current_thread_info()->addr_limit.seg)
 
diff --git a/arch/sparc/include/asm/uaccess.h b/arch/sparc/include/asm/uaccess.h
index dd85bc2c2cad..70c2f5ea09ce 100644
--- a/arch/sparc/include/asm/uaccess.h
+++ b/arch/sparc/include/asm/uaccess.h
@@ -7,6 +7,8 @@
 #include <asm/uaccess_32.h>
 #endif
 
+#define untagged_addr(addr)	addr
+
 #define user_addr_max() \
 	(uaccess_kernel() ? ~0UL : TASK_SIZE)
 
diff --git a/arch/tile/include/asm/uaccess.h b/arch/tile/include/asm/uaccess.h
index cb4fbe7e4f88..7d365b087dcb 100644
--- a/arch/tile/include/asm/uaccess.h
+++ b/arch/tile/include/asm/uaccess.h
@@ -22,6 +22,8 @@
 #include <asm/processor.h>
 #include <asm/page.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should be
  * performed or not.  If get_fs() == USER_DS, checking is performed, with
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index aae77eb8491c..3c233fbdd32b 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -12,6 +12,8 @@
 #include <asm/smap.h>
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should be
  * performed or not.  If get_fs() == USER_DS, checking is performed, with
diff --git a/arch/xtensa/include/asm/uaccess.h b/arch/xtensa/include/asm/uaccess.h
index f1158b4c629c..130e419c4d6e 100644
--- a/arch/xtensa/include/asm/uaccess.h
+++ b/arch/xtensa/include/asm/uaccess.h
@@ -20,6 +20,8 @@
 #include <asm/types.h>
 #include <asm/extable.h>
 
+#define untagged_addr(addr)	addr
+
 /*
  * The fs value determines whether argument validity checking should
  * be performed or not.  If get_fs() == USER_DS, checking is
diff --git a/include/asm-generic/uaccess.h b/include/asm-generic/uaccess.h
index 6b2e63df2739..2c46d2253dba 100644
--- a/include/asm-generic/uaccess.h
+++ b/include/asm-generic/uaccess.h
@@ -35,6 +35,8 @@ static inline void set_fs(mm_segment_t fs)
 #define segment_eq(a, b) ((a).seg == (b).seg)
 #endif
 
+#define untagged_addr(addr) addr
+
 #define access_ok(type, addr, size) __access_ok((unsigned long)(addr),(size))
 
 /*
-- 
2.16.2.395.g2e18187dfd-goog
