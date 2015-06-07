Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8007B6B0073
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:42:42 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so80080548pab.3
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:42:42 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id hl3si358939pdb.148.2015.06.07.10.42.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:42:41 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:41:58 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-c7c95f19f37976731efca9576f6e4a22067798a2@git.kernel.org>
Reply-To: toshi.kani@hp.com, peterz@infradead.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        torvalds@linux-foundation.org, bp@suse.de, luto@amacapital.net,
        tglx@linutronix.de, geert@linux-m68k.org, hpa@zytor.com,
        mcgrof@suse.com, mingo@kernel.org
In-Reply-To: <1433436928-31903-10-git-send-email-bp@alien8.de>
References: <1433436928-31903-10-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] video/fbdev, asm/io.h: Remove ioremap_writethrough()
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, peterz@infradead.org, toshi.kani@hp.com, akpm@linux-foundation.org, mcgrof@suse.com, mingo@kernel.org, bp@suse.de, luto@amacapital.net, tglx@linutronix.de, geert@linux-m68k.org, hpa@zytor.com

Commit-ID:  c7c95f19f37976731efca9576f6e4a22067798a2
Gitweb:     http://git.kernel.org/tip/c7c95f19f37976731efca9576f6e4a22067798a2
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:17 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:57 +0200

video/fbdev, asm/io.h: Remove ioremap_writethrough()

Replace all calls to ioremap_writethrough() with ioremap_wt().
Remove ioremap_writethrough() too.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
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
Link: http://lkml.kernel.org/r/1433436928-31903-10-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/frv/include/asm/io.h        | 5 -----
 arch/m68k/include/asm/io_mm.h    | 5 -----
 arch/m68k/include/asm/io_no.h    | 4 ----
 arch/microblaze/include/asm/io.h | 1 -
 arch/tile/include/asm/io.h       | 1 -
 drivers/video/fbdev/amifb.c      | 4 ++--
 drivers/video/fbdev/atafb.c      | 3 +--
 drivers/video/fbdev/hpfb.c       | 4 ++--
 8 files changed, 5 insertions(+), 22 deletions(-)

diff --git a/arch/frv/include/asm/io.h b/arch/frv/include/asm/io.h
index 1fe98fe..a31b63e 100644
--- a/arch/frv/include/asm/io.h
+++ b/arch/frv/include/asm/io.h
@@ -267,11 +267,6 @@ static inline void __iomem *ioremap_nocache(unsigned long physaddr, unsigned lon
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
 
-static inline void __iomem *ioremap_writethrough(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
-}
-
 static inline void __iomem *ioremap_wt(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
diff --git a/arch/m68k/include/asm/io_mm.h b/arch/m68k/include/asm/io_mm.h
index 7c12138..618c85d3 100644
--- a/arch/m68k/include/asm/io_mm.h
+++ b/arch/m68k/include/asm/io_mm.h
@@ -467,11 +467,6 @@ static inline void __iomem *ioremap_nocache(unsigned long physaddr, unsigned lon
 {
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
-static inline void __iomem *ioremap_writethrough(unsigned long physaddr,
-					 unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
-}
 static inline void __iomem *ioremap_wt(unsigned long physaddr,
 					 unsigned long size)
 {
diff --git a/arch/m68k/include/asm/io_no.h b/arch/m68k/include/asm/io_no.h
index 5fff9a2..ad7bd40 100644
--- a/arch/m68k/include/asm/io_no.h
+++ b/arch/m68k/include/asm/io_no.h
@@ -155,10 +155,6 @@ static inline void *ioremap_nocache(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
-static inline void *ioremap_writethrough(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
-}
 static inline void *ioremap_wt(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
diff --git a/arch/microblaze/include/asm/io.h b/arch/microblaze/include/asm/io.h
index ec3da11..39b6315 100644
--- a/arch/microblaze/include/asm/io.h
+++ b/arch/microblaze/include/asm/io.h
@@ -39,7 +39,6 @@ extern resource_size_t isa_mem_base;
 extern void iounmap(void __iomem *addr);
 
 extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
-#define ioremap_writethrough(addr, size)	ioremap((addr), (size))
 #define ioremap_nocache(addr, size)		ioremap((addr), (size))
 #define ioremap_fullcache(addr, size)		ioremap((addr), (size))
 #define ioremap_wc(addr, size)			ioremap((addr), (size))
diff --git a/arch/tile/include/asm/io.h b/arch/tile/include/asm/io.h
index 9c3d950..dc61de1 100644
--- a/arch/tile/include/asm/io.h
+++ b/arch/tile/include/asm/io.h
@@ -55,7 +55,6 @@ extern void iounmap(volatile void __iomem *addr);
 #define ioremap_nocache(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_wc(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_wt(physaddr, size)		ioremap(physaddr, size)
-#define ioremap_writethrough(physaddr, size)	ioremap(physaddr, size)
 #define ioremap_fullcache(physaddr, size)	ioremap(physaddr, size)
 
 #define mmiowb()
diff --git a/drivers/video/fbdev/amifb.c b/drivers/video/fbdev/amifb.c
index 35f7900..ee3a703 100644
--- a/drivers/video/fbdev/amifb.c
+++ b/drivers/video/fbdev/amifb.c
@@ -3705,8 +3705,8 @@ default_chipset:
 	 * access the videomem with writethrough cache
 	 */
 	info->fix.smem_start = (u_long)ZTWO_PADDR(videomemory);
-	videomemory = (u_long)ioremap_writethrough(info->fix.smem_start,
-						   info->fix.smem_len);
+	videomemory = (u_long)ioremap_wt(info->fix.smem_start,
+					 info->fix.smem_len);
 	if (!videomemory) {
 		dev_warn(&pdev->dev,
 			 "Unable to map videomem cached writethrough\n");
diff --git a/drivers/video/fbdev/atafb.c b/drivers/video/fbdev/atafb.c
index cb9ee25..d6ce613 100644
--- a/drivers/video/fbdev/atafb.c
+++ b/drivers/video/fbdev/atafb.c
@@ -3185,8 +3185,7 @@ int __init atafb_init(void)
 		/* Map the video memory (physical address given) to somewhere
 		 * in the kernel address space.
 		 */
-		external_screen_base = ioremap_writethrough(external_addr,
-						     external_len);
+		external_screen_base = ioremap_wt(external_addr, external_len);
 		if (external_vgaiobase)
 			external_vgaiobase =
 			  (unsigned long)ioremap(external_vgaiobase, 0x10000);
diff --git a/drivers/video/fbdev/hpfb.c b/drivers/video/fbdev/hpfb.c
index a1b7e5f..9476d19 100644
--- a/drivers/video/fbdev/hpfb.c
+++ b/drivers/video/fbdev/hpfb.c
@@ -241,8 +241,8 @@ static int hpfb_init_one(unsigned long phys_base, unsigned long virt_base)
 	fb_info.fix.line_length = fb_width;
 	fb_height = (in_8(fb_regs + HPFB_FBHMSB) << 8) | in_8(fb_regs + HPFB_FBHLSB);
 	fb_info.fix.smem_len = fb_width * fb_height;
-	fb_start = (unsigned long)ioremap_writethrough(fb_info.fix.smem_start,
-						       fb_info.fix.smem_len);
+	fb_start = (unsigned long)ioremap_wt(fb_info.fix.smem_start,
+					     fb_info.fix.smem_len);
 	hpfb_defined.xres = (in_8(fb_regs + HPFB_DWMSB) << 8) | in_8(fb_regs + HPFB_DWLSB);
 	hpfb_defined.yres = (in_8(fb_regs + HPFB_DHMSB) << 8) | in_8(fb_regs + HPFB_DHLSB);
 	hpfb_defined.xres_virtual = hpfb_defined.xres;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
