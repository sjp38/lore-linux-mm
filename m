Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1BA6B0072
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:42:17 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so48351667pdj.0
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:42:17 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id mv8si397749pdb.4.2015.06.07.10.42.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:42:16 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:41:37 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-556269c138a8b2d3f5714b8105fa6119ecc505f2@git.kernel.org>
Reply-To: akpm@linux-foundation.org, linux-mm@kvack.org,
        torvalds@linux-foundation.org, luto@amacapital.net, mingo@kernel.org,
        linux-kernel@vger.kernel.org, hpa@zytor.com, toshi.kani@hp.com,
        bp@suse.de, peterz@infradead.org, tglx@linutronix.de, mcgrof@suse.com
In-Reply-To: <1433436928-31903-9-git-send-email-bp@alien8.de>
References: <1433436928-31903-9-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] arch/*/io.h: Add ioremap_wt() to all architectures
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, akpm@linux-foundation.org, linux-mm@kvack.org, torvalds@linux-foundation.org, luto@amacapital.net, mingo@kernel.org, peterz@infradead.org, tglx@linutronix.de, mcgrof@suse.com, toshi.kani@hp.com, bp@suse.de

Commit-ID:  556269c138a8b2d3f5714b8105fa6119ecc505f2
Gitweb:     http://git.kernel.org/tip/556269c138a8b2d3f5714b8105fa6119ecc505f2
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:16 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:57 +0200

arch/*/io.h: Add ioremap_wt() to all architectures

Add ioremap_wt() to all arch-specific asm/io.h headers which
define ioremap_wc() locally. These headers do not include
<asm-generic/iomap.h>. Some of them include <asm-generic/io.h>,
but ioremap_wt() is defined for consistency since they define
all ioremap_xxx locally.

In all architectures without Write-Through support, ioremap_wt()
is defined indentical to ioremap_nocache().

frv and m68k already have ioremap_writethrough(). On those we
add ioremap_wt() indetical to ioremap_writethrough() and defines
ARCH_HAS_IOREMAP_WT in both architectures.

The ioremap_wt() interface is exported to drivers.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-9-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/arc/include/asm/io.h        | 1 +
 arch/arm/include/asm/io.h        | 1 +
 arch/arm64/include/asm/io.h      | 1 +
 arch/avr32/include/asm/io.h      | 1 +
 arch/frv/include/asm/io.h        | 7 +++++++
 arch/m32r/include/asm/io.h       | 1 +
 arch/m68k/include/asm/io_mm.h    | 7 +++++++
 arch/m68k/include/asm/io_no.h    | 6 ++++++
 arch/metag/include/asm/io.h      | 3 +++
 arch/microblaze/include/asm/io.h | 1 +
 arch/mn10300/include/asm/io.h    | 1 +
 arch/nios2/include/asm/io.h      | 1 +
 arch/s390/include/asm/io.h       | 1 +
 arch/sparc/include/asm/io_32.h   | 1 +
 arch/sparc/include/asm/io_64.h   | 1 +
 arch/tile/include/asm/io.h       | 1 +
 arch/xtensa/include/asm/io.h     | 1 +
 17 files changed, 36 insertions(+)

diff --git a/arch/arc/include/asm/io.h b/arch/arc/include/asm/io.h
index cabd518..7cc4ced 100644
--- a/arch/arc/include/asm/io.h
+++ b/arch/arc/include/asm/io.h
@@ -20,6 +20,7 @@ extern void iounmap(const void __iomem *addr);
 
 #define ioremap_nocache(phy, sz)	ioremap(phy, sz)
 #define ioremap_wc(phy, sz)		ioremap(phy, sz)
+#define ioremap_wt(phy, sz)		ioremap(phy, sz)
 
 /* Change struct page to physical address */
 #define page_to_phys(page)		(page_to_pfn(page) << PAGE_SHIFT)
diff --git a/arch/arm/include/asm/io.h b/arch/arm/include/asm/io.h
index db58deb..1b7677d 100644
--- a/arch/arm/include/asm/io.h
+++ b/arch/arm/include/asm/io.h
@@ -336,6 +336,7 @@ extern void _memset_io(volatile void __iomem *, int, size_t);
 #define ioremap_nocache(cookie,size)	__arm_ioremap((cookie), (size), MT_DEVICE)
 #define ioremap_cache(cookie,size)	__arm_ioremap((cookie), (size), MT_DEVICE_CACHED)
 #define ioremap_wc(cookie,size)		__arm_ioremap((cookie), (size), MT_DEVICE_WC)
+#define ioremap_wt(cookie,size)		__arm_ioremap((cookie), (size), MT_DEVICE)
 #define iounmap				__arm_iounmap
 
 /*
diff --git a/arch/arm64/include/asm/io.h b/arch/arm64/include/asm/io.h
index 540f7c0..7116d39 100644
--- a/arch/arm64/include/asm/io.h
+++ b/arch/arm64/include/asm/io.h
@@ -170,6 +170,7 @@ extern void __iomem *ioremap_cache(phys_addr_t phys_addr, size_t size);
 #define ioremap(addr, size)		__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
 #define ioremap_nocache(addr, size)	__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
 #define ioremap_wc(addr, size)		__ioremap((addr), (size), __pgprot(PROT_NORMAL_NC))
+#define ioremap_wt(addr, size)		__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
 #define iounmap				__iounmap
 
 /*
diff --git a/arch/avr32/include/asm/io.h b/arch/avr32/include/asm/io.h
index 4f5ec2b..e998ff5 100644
--- a/arch/avr32/include/asm/io.h
+++ b/arch/avr32/include/asm/io.h
@@ -296,6 +296,7 @@ extern void __iounmap(void __iomem *addr);
 	__iounmap(addr)
 
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 #define cached(addr) P1SEGADDR(addr)
 #define uncached(addr) P2SEGADDR(addr)
diff --git a/arch/frv/include/asm/io.h b/arch/frv/include/asm/io.h
index 0b78bc8..1fe98fe 100644
--- a/arch/frv/include/asm/io.h
+++ b/arch/frv/include/asm/io.h
@@ -17,6 +17,8 @@
 
 #ifdef __KERNEL__
 
+#define ARCH_HAS_IOREMAP_WT
+
 #include <linux/types.h>
 #include <asm/virtconvert.h>
 #include <asm/string.h>
@@ -270,6 +272,11 @@ static inline void __iomem *ioremap_writethrough(unsigned long physaddr, unsigne
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
 
+static inline void __iomem *ioremap_wt(unsigned long physaddr, unsigned long size)
+{
+	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
+}
+
 static inline void __iomem *ioremap_fullcache(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
diff --git a/arch/m32r/include/asm/io.h b/arch/m32r/include/asm/io.h
index 9cc00db..0c3f25e 100644
--- a/arch/m32r/include/asm/io.h
+++ b/arch/m32r/include/asm/io.h
@@ -68,6 +68,7 @@ static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 extern void iounmap(volatile void __iomem *addr);
 #define ioremap_nocache(off,size) ioremap(off,size)
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 /*
  * IO bus memory addresses are also 1:1 with the physical address
diff --git a/arch/m68k/include/asm/io_mm.h b/arch/m68k/include/asm/io_mm.h
index 8955b40..7c12138 100644
--- a/arch/m68k/include/asm/io_mm.h
+++ b/arch/m68k/include/asm/io_mm.h
@@ -20,6 +20,8 @@
 
 #ifdef __KERNEL__
 
+#define ARCH_HAS_IOREMAP_WT
+
 #include <linux/compiler.h>
 #include <asm/raw_io.h>
 #include <asm/virtconvert.h>
@@ -470,6 +472,11 @@ static inline void __iomem *ioremap_writethrough(unsigned long physaddr,
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
+static inline void __iomem *ioremap_wt(unsigned long physaddr,
+					 unsigned long size)
+{
+	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
+}
 static inline void __iomem *ioremap_fullcache(unsigned long physaddr,
 				      unsigned long size)
 {
diff --git a/arch/m68k/include/asm/io_no.h b/arch/m68k/include/asm/io_no.h
index a93c8cd..5fff9a2 100644
--- a/arch/m68k/include/asm/io_no.h
+++ b/arch/m68k/include/asm/io_no.h
@@ -3,6 +3,8 @@
 
 #ifdef __KERNEL__
 
+#define ARCH_HAS_IOREMAP_WT
+
 #include <asm/virtconvert.h>
 #include <asm-generic/iomap.h>
 
@@ -157,6 +159,10 @@ static inline void *ioremap_writethrough(unsigned long physaddr, unsigned long s
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
+static inline void *ioremap_wt(unsigned long physaddr, unsigned long size)
+{
+	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
+}
 static inline void *ioremap_fullcache(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
diff --git a/arch/metag/include/asm/io.h b/arch/metag/include/asm/io.h
index d5779b0..9890f21 100644
--- a/arch/metag/include/asm/io.h
+++ b/arch/metag/include/asm/io.h
@@ -160,6 +160,9 @@ extern void __iounmap(void __iomem *addr);
 #define ioremap_wc(offset, size)                \
 	__ioremap((offset), (size), _PAGE_WR_COMBINE)
 
+#define ioremap_wt(offset, size)                \
+	__ioremap((offset), (size), 0)
+
 #define iounmap(addr)                           \
 	__iounmap(addr)
 
diff --git a/arch/microblaze/include/asm/io.h b/arch/microblaze/include/asm/io.h
index 940f5fc..ec3da11 100644
--- a/arch/microblaze/include/asm/io.h
+++ b/arch/microblaze/include/asm/io.h
@@ -43,6 +43,7 @@ extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
 #define ioremap_nocache(addr, size)		ioremap((addr), (size))
 #define ioremap_fullcache(addr, size)		ioremap((addr), (size))
 #define ioremap_wc(addr, size)			ioremap((addr), (size))
+#define ioremap_wt(addr, size)			ioremap((addr), (size))
 
 #endif /* CONFIG_MMU */
 
diff --git a/arch/mn10300/include/asm/io.h b/arch/mn10300/include/asm/io.h
index cc4a2ba..07c5b4a 100644
--- a/arch/mn10300/include/asm/io.h
+++ b/arch/mn10300/include/asm/io.h
@@ -282,6 +282,7 @@ static inline void __iomem *ioremap_nocache(unsigned long offset, unsigned long
 }
 
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 static inline void iounmap(void __iomem *addr)
 {
diff --git a/arch/nios2/include/asm/io.h b/arch/nios2/include/asm/io.h
index 6e24d7c..c5a62da 100644
--- a/arch/nios2/include/asm/io.h
+++ b/arch/nios2/include/asm/io.h
@@ -46,6 +46,7 @@ static inline void iounmap(void __iomem *addr)
 }
 
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 /* Pages to physical address... */
 #define page_to_phys(page)	virt_to_phys(page_to_virt(page))
diff --git a/arch/s390/include/asm/io.h b/arch/s390/include/asm/io.h
index 30fd5c8..cb5fdf3 100644
--- a/arch/s390/include/asm/io.h
+++ b/arch/s390/include/asm/io.h
@@ -29,6 +29,7 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
 
 #define ioremap_nocache(addr, size)	ioremap(addr, size)
 #define ioremap_wc			ioremap_nocache
+#define ioremap_wt			ioremap_nocache
 
 static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 {
diff --git a/arch/sparc/include/asm/io_32.h b/arch/sparc/include/asm/io_32.h
index 407ac14..57f26c3 100644
--- a/arch/sparc/include/asm/io_32.h
+++ b/arch/sparc/include/asm/io_32.h
@@ -129,6 +129,7 @@ static inline void sbus_memcpy_toio(volatile void __iomem *dst,
 void __iomem *ioremap(unsigned long offset, unsigned long size);
 #define ioremap_nocache(X,Y)	ioremap((X),(Y))
 #define ioremap_wc(X,Y)		ioremap((X),(Y))
+#define ioremap_wt(X,Y)		ioremap((X),(Y))
 void iounmap(volatile void __iomem *addr);
 
 /* Create a virtual mapping cookie for an IO port range */
diff --git a/arch/sparc/include/asm/io_64.h b/arch/sparc/include/asm/io_64.h
index 50d4840..c32fa3f 100644
--- a/arch/sparc/include/asm/io_64.h
+++ b/arch/sparc/include/asm/io_64.h
@@ -402,6 +402,7 @@ static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 
 #define ioremap_nocache(X,Y)		ioremap((X),(Y))
 #define ioremap_wc(X,Y)			ioremap((X),(Y))
+#define ioremap_wt(X,Y)			ioremap((X),(Y))
 
 static inline void iounmap(volatile void __iomem *addr)
 {
diff --git a/arch/tile/include/asm/io.h b/arch/tile/include/asm/io.h
index 6ef4eca..9c3d950 100644
--- a/arch/tile/include/asm/io.h
+++ b/arch/tile/include/asm/io.h
@@ -54,6 +54,7 @@ extern void iounmap(volatile void __iomem *addr);
 
 #define ioremap_nocache(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_wc(physaddr, size)		ioremap(physaddr, size)
+#define ioremap_wt(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_writethrough(physaddr, size)	ioremap(physaddr, size)
 #define ioremap_fullcache(physaddr, size)	ioremap(physaddr, size)
 
diff --git a/arch/xtensa/include/asm/io.h b/arch/xtensa/include/asm/io.h
index fe1600a..c39bb6e 100644
--- a/arch/xtensa/include/asm/io.h
+++ b/arch/xtensa/include/asm/io.h
@@ -59,6 +59,7 @@ static inline void __iomem *ioremap_cache(unsigned long offset,
 }
 
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
