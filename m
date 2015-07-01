Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9346B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 06:17:43 -0400 (EDT)
Received: by wguu7 with SMTP id u7so32458100wgu.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 03:17:42 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id e9si24463920wic.93.2015.07.01.03.17.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jul 2015 03:17:41 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 1 Jul 2015 11:17:39 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1C88017D8068
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 11:18:48 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t61AHZc433489032
	for <linux-mm@kvack.org>; Wed, 1 Jul 2015 10:17:35 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t61AHYwb005178
	for <linux-mm@kvack.org>; Wed, 1 Jul 2015 04:17:35 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2] mm: cleaning per architecture MM hook header files
Date: Wed,  1 Jul 2015 12:17:33 +0200
Message-Id: <1435745853-27535-1-git-send-email-ldufour@linux.vnet.ibm.com>
In-Reply-To: <55924508.9080101@synopsys.com>
References: <55924508.9080101@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: uclinux-h8-devel@lists.sourceforge.jp, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The commit 2ae416b142b6 ("mm: new mm hook framework") introduced an empty
header file (mm-arch-hooks.h) for every architecture, even those which
doesn't need to define mm hooks.

As suggested by Geert Uytterhoeven, this could be cleaned through the use
of a generic header file included via each per architecture
asm/include/Kbuild file.

The PowerPC architecture is not impacted here since this architecture has
to defined the arch_remap MM hook.

Changes in V2:
--------------
 - Vineet Gupta reported that the Kbuild files should be kept sorted.
 - Add fix for the newly introduced H8/300 architecture.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Suggested-by: Geert Uytterhoeven <geert@linux-m68k.org>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Vineet Gupta <Vineet.Gupta1@synopsys.com>
CC: linux-arch@vger.kernel.org
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/alpha/include/asm/Kbuild               |  1 +
 arch/alpha/include/asm/mm-arch-hooks.h      | 15 ---------------
 arch/arc/include/asm/Kbuild                 |  1 +
 arch/arc/include/asm/mm-arch-hooks.h        | 15 ---------------
 arch/arm/include/asm/Kbuild                 |  1 +
 arch/arm/include/asm/mm-arch-hooks.h        | 15 ---------------
 arch/arm64/include/asm/Kbuild               |  1 +
 arch/arm64/include/asm/mm-arch-hooks.h      | 15 ---------------
 arch/avr32/include/asm/Kbuild               |  1 +
 arch/avr32/include/asm/mm-arch-hooks.h      | 15 ---------------
 arch/blackfin/include/asm/Kbuild            |  1 +
 arch/blackfin/include/asm/mm-arch-hooks.h   | 15 ---------------
 arch/c6x/include/asm/Kbuild                 |  1 +
 arch/c6x/include/asm/mm-arch-hooks.h        | 15 ---------------
 arch/cris/include/asm/Kbuild                |  1 +
 arch/cris/include/asm/mm-arch-hooks.h       | 15 ---------------
 arch/frv/include/asm/Kbuild                 |  1 +
 arch/frv/include/asm/mm-arch-hooks.h        | 15 ---------------
 arch/h8300/include/asm/Kbuild               |  1 +
 arch/hexagon/include/asm/Kbuild             |  1 +
 arch/hexagon/include/asm/mm-arch-hooks.h    | 15 ---------------
 arch/ia64/include/asm/Kbuild                |  1 +
 arch/ia64/include/asm/mm-arch-hooks.h       | 15 ---------------
 arch/m32r/include/asm/Kbuild                |  1 +
 arch/m32r/include/asm/mm-arch-hooks.h       | 15 ---------------
 arch/m68k/include/asm/Kbuild                |  1 +
 arch/m68k/include/asm/mm-arch-hooks.h       | 15 ---------------
 arch/metag/include/asm/Kbuild               |  1 +
 arch/metag/include/asm/mm-arch-hooks.h      | 15 ---------------
 arch/microblaze/include/asm/Kbuild          |  1 +
 arch/microblaze/include/asm/mm-arch-hooks.h | 15 ---------------
 arch/mips/include/asm/Kbuild                |  1 +
 arch/mips/include/asm/mm-arch-hooks.h       | 15 ---------------
 arch/mn10300/include/asm/Kbuild             |  1 +
 arch/mn10300/include/asm/mm-arch-hooks.h    | 15 ---------------
 arch/nios2/include/asm/Kbuild               |  1 +
 arch/nios2/include/asm/mm-arch-hooks.h      | 15 ---------------
 arch/openrisc/include/asm/Kbuild            |  1 +
 arch/openrisc/include/asm/mm-arch-hooks.h   | 15 ---------------
 arch/parisc/include/asm/Kbuild              |  1 +
 arch/parisc/include/asm/mm-arch-hooks.h     | 15 ---------------
 arch/s390/include/asm/Kbuild                |  1 +
 arch/s390/include/asm/mm-arch-hooks.h       | 15 ---------------
 arch/score/include/asm/Kbuild               |  1 +
 arch/score/include/asm/mm-arch-hooks.h      | 15 ---------------
 arch/sh/include/asm/Kbuild                  |  1 +
 arch/sh/include/asm/mm-arch-hooks.h         | 15 ---------------
 arch/sparc/include/asm/Kbuild               |  1 +
 arch/sparc/include/asm/mm-arch-hooks.h      | 15 ---------------
 arch/tile/include/asm/Kbuild                |  1 +
 arch/tile/include/asm/mm-arch-hooks.h       | 15 ---------------
 arch/um/include/asm/Kbuild                  |  1 +
 arch/um/include/asm/mm-arch-hooks.h         | 15 ---------------
 arch/unicore32/include/asm/Kbuild           |  1 +
 arch/unicore32/include/asm/mm-arch-hooks.h  | 15 ---------------
 arch/x86/include/asm/Kbuild                 |  1 +
 arch/x86/include/asm/mm-arch-hooks.h        | 15 ---------------
 arch/xtensa/include/asm/Kbuild              |  1 +
 arch/xtensa/include/asm/mm-arch-hooks.h     | 15 ---------------
 include/asm-generic/mm-arch-hooks.h         | 16 ++++++++++++++++
 60 files changed, 46 insertions(+), 435 deletions(-)
 delete mode 100644 arch/alpha/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/arc/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/arm/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/arm64/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/avr32/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/blackfin/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/c6x/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/cris/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/frv/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/hexagon/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/ia64/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/m32r/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/m68k/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/metag/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/microblaze/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/mips/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/mn10300/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/nios2/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/openrisc/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/parisc/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/s390/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/score/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/sh/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/sparc/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/tile/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/um/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/unicore32/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/x86/include/asm/mm-arch-hooks.h
 delete mode 100644 arch/xtensa/include/asm/mm-arch-hooks.h
 create mode 100644 include/asm-generic/mm-arch-hooks.h

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index cde23cd03609..ffd9cf5ec8c4 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -5,6 +5,7 @@ generic-y += cputime.h
 generic-y += exec.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/alpha/include/asm/mm-arch-hooks.h b/arch/alpha/include/asm/mm-arch-hooks.h
deleted file mode 100644
index b07fd862fec3..000000000000
--- a/arch/alpha/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_ALPHA_MM_ARCH_HOOKS_H
-#define _ASM_ALPHA_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_ALPHA_MM_ARCH_HOOKS_H */
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 769b312c1abb..f2a3cdfee5f5 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -23,6 +23,7 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += param.h
diff --git a/arch/arc/include/asm/mm-arch-hooks.h b/arch/arc/include/asm/mm-arch-hooks.h
deleted file mode 100644
index c37541c5f8ba..000000000000
--- a/arch/arc/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_ARC_MM_ARCH_HOOKS_H
-#define _ASM_ARC_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_ARC_MM_ARCH_HOOKS_H */
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 83c50193626c..30b3bc1666d2 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -13,6 +13,7 @@ generic-y += kdebug.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += msgbuf.h
 generic-y += param.h
 generic-y += parport.h
diff --git a/arch/arm/include/asm/mm-arch-hooks.h b/arch/arm/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 7056660c7cc4..000000000000
--- a/arch/arm/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_ARM_MM_ARCH_HOOKS_H
-#define _ASM_ARM_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_ARM_MM_ARCH_HOOKS_H */
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index b112a39834d0..70fd9ffb58cf 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -25,6 +25,7 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += msi.h
diff --git a/arch/arm64/include/asm/mm-arch-hooks.h b/arch/arm64/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 562b655f5ba9..000000000000
--- a/arch/arm64/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_ARM64_MM_ARCH_HOOKS_H
-#define _ASM_ARM64_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_ARM64_MM_ARCH_HOOKS_H */
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 1d66afdfac07..f61f2dd67464 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -12,6 +12,7 @@ generic-y += irq_work.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += param.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/avr32/include/asm/mm-arch-hooks.h b/arch/avr32/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 145452ffbdad..000000000000
--- a/arch/avr32/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_AVR32_MM_ARCH_HOOKS_H
-#define _ASM_AVR32_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_AVR32_MM_ARCH_HOOKS_H */
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index 07051a63415d..61cd1e786a14 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -21,6 +21,7 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += mutex.h
diff --git a/arch/blackfin/include/asm/mm-arch-hooks.h b/arch/blackfin/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 1c5211ec338f..000000000000
--- a/arch/blackfin/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_BLACKFIN_MM_ARCH_HOOKS_H
-#define _ASM_BLACKFIN_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_BLACKFIN_MM_ARCH_HOOKS_H */
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index 7aeb32272975..f17c4dc6050c 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -26,6 +26,7 @@ generic-y += kdebug.h
 generic-y += kmap_types.h
 generic-y += local.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += mmu.h
 generic-y += mmu_context.h
diff --git a/arch/c6x/include/asm/mm-arch-hooks.h b/arch/c6x/include/asm/mm-arch-hooks.h
deleted file mode 100644
index bb3c4a6ce8e9..000000000000
--- a/arch/c6x/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_C6X_MM_ARCH_HOOKS_H
-#define _ASM_C6X_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_C6X_MM_ARCH_HOOKS_H */
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index d294f6aaff1d..ad2244f35bca 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -18,6 +18,7 @@ generic-y += linkage.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += module.h
 generic-y += percpu.h
 generic-y += preempt.h
diff --git a/arch/cris/include/asm/mm-arch-hooks.h b/arch/cris/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 314f774db2b0..000000000000
--- a/arch/cris/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_CRIS_MM_ARCH_HOOKS_H
-#define _ASM_CRIS_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_CRIS_MM_ARCH_HOOKS_H */
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 30edce31e5c2..8e47b832cc76 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -4,5 +4,6 @@ generic-y += cputime.h
 generic-y += exec.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += trace_clock.h
diff --git a/arch/frv/include/asm/mm-arch-hooks.h b/arch/frv/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 51d13a870404..000000000000
--- a/arch/frv/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_FRV_MM_ARCH_HOOKS_H
-#define _ASM_FRV_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_FRV_MM_ARCH_HOOKS_H */
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index 00379d64f707..70e6ae1e7006 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -33,6 +33,7 @@ generic-y += linkage.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += mmu.h
 generic-y += mmu_context.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index 5ade4a163558..daee37bd0999 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -28,6 +28,7 @@ generic-y += kmap_types.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += pci.h
diff --git a/arch/hexagon/include/asm/mm-arch-hooks.h b/arch/hexagon/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 05e8b939e416..000000000000
--- a/arch/hexagon/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_HEXAGON_MM_ARCH_HOOKS_H
-#define _ASM_HEXAGON_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_HEXAGON_MM_ARCH_HOOKS_H */
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index ccff13d33fa2..9de3ba12f6b9 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -4,6 +4,7 @@ generic-y += exec.h
 generic-y += irq_work.h
 generic-y += kvm_para.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += vtime.h
diff --git a/arch/ia64/include/asm/mm-arch-hooks.h b/arch/ia64/include/asm/mm-arch-hooks.h
deleted file mode 100644
index ab4b5c698322..000000000000
--- a/arch/ia64/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_IA64_MM_ARCH_HOOKS_H
-#define _ASM_IA64_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_IA64_MM_ARCH_HOOKS_H */
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index ba1cdc018731..e0eb704ca1fa 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -4,6 +4,7 @@ generic-y += cputime.h
 generic-y += exec.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += module.h
 generic-y += preempt.h
 generic-y += sections.h
diff --git a/arch/m32r/include/asm/mm-arch-hooks.h b/arch/m32r/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 6d60b4750f41..000000000000
--- a/arch/m32r/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_M32R_MM_ARCH_HOOKS_H
-#define _ASM_M32R_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_M32R_MM_ARCH_HOOKS_H */
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index 1555bc189c7d..eb85bd9c6180 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -18,6 +18,7 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += mutex.h
 generic-y += percpu.h
diff --git a/arch/m68k/include/asm/mm-arch-hooks.h b/arch/m68k/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 7e8709bc90ae..000000000000
--- a/arch/m68k/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_M68K_MM_ARCH_HOOKS_H
-#define _ASM_M68K_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_M68K_MM_ARCH_HOOKS_H */
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 199320f3c345..df31353fd200 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -25,6 +25,7 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += msgbuf.h
 generic-y += mutex.h
 generic-y += param.h
diff --git a/arch/metag/include/asm/mm-arch-hooks.h b/arch/metag/include/asm/mm-arch-hooks.h
deleted file mode 100644
index b0072b2eb0de..000000000000
--- a/arch/metag/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_METAG_MM_ARCH_HOOKS_H
-#define _ASM_METAG_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_METAG_MM_ARCH_HOOKS_H */
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index 9989ddb169ca..2f222f355c4b 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -6,6 +6,7 @@ generic-y += device.h
 generic-y += exec.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += syscalls.h
 generic-y += trace_clock.h
diff --git a/arch/microblaze/include/asm/mm-arch-hooks.h b/arch/microblaze/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 5c4065911bda..000000000000
--- a/arch/microblaze/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_MICROBLAZE_MM_ARCH_HOOKS_H
-#define _ASM_MICROBLAZE_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_MICROBLAZE_MM_ARCH_HOOKS_H */
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 7fe5c61a3cb8..1f8546081d20 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -7,6 +7,7 @@ generic-y += emergency-restart.h
 generic-y += irq_work.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mutex.h
 generic-y += parport.h
 generic-y += percpu.h
diff --git a/arch/mips/include/asm/mm-arch-hooks.h b/arch/mips/include/asm/mm-arch-hooks.h
deleted file mode 100644
index b5609fe8e475..000000000000
--- a/arch/mips/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_MIPS_MM_ARCH_HOOKS_H
-#define _ASM_MIPS_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_MIPS_MM_ARCH_HOOKS_H */
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index de30b0c88796..6edb9ee6128e 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -5,6 +5,7 @@ generic-y += cputime.h
 generic-y += exec.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/mn10300/include/asm/mm-arch-hooks.h b/arch/mn10300/include/asm/mm-arch-hooks.h
deleted file mode 100644
index e2029a652f4c..000000000000
--- a/arch/mn10300/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_MN10300_MM_ARCH_HOOKS_H
-#define _ASM_MN10300_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_MN10300_MM_ARCH_HOOKS_H */
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index 434639d510b3..914864eb5a25 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -30,6 +30,7 @@ generic-y += kmap_types.h
 generic-y += kvm_para.h
 generic-y += local.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += module.h
 generic-y += msgbuf.h
diff --git a/arch/nios2/include/asm/mm-arch-hooks.h b/arch/nios2/include/asm/mm-arch-hooks.h
deleted file mode 100644
index d7290dc68558..000000000000
--- a/arch/nios2/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_NIOS2_MM_ARCH_HOOKS_H
-#define _ASM_NIOS2_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_NIOS2_MM_ARCH_HOOKS_H */
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 2a2e39b8109a..2832f031fb11 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -36,6 +36,7 @@ generic-y += kmap_types.h
 generic-y += kvm_para.h
 generic-y += local.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += module.h
 generic-y += msgbuf.h
diff --git a/arch/openrisc/include/asm/mm-arch-hooks.h b/arch/openrisc/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 6d33cb555fe1..000000000000
--- a/arch/openrisc/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_OPENRISC_MM_ARCH_HOOKS_H
-#define _ASM_OPENRISC_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_OPENRISC_MM_ARCH_HOOKS_H */
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index 12b341d04f88..f9b3a81aefcd 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -15,6 +15,7 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mutex.h
 generic-y += param.h
 generic-y += percpu.h
diff --git a/arch/parisc/include/asm/mm-arch-hooks.h b/arch/parisc/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 654ec63b0ee9..000000000000
--- a/arch/parisc/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_PARISC_MM_ARCH_HOOKS_H
-#define _ASM_PARISC_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_PARISC_MM_ARCH_HOOKS_H */
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index dc5385ebb071..5ad26dd94d77 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -3,5 +3,6 @@
 generic-y += clkdev.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += trace_clock.h
diff --git a/arch/s390/include/asm/mm-arch-hooks.h b/arch/s390/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 07680b2f3c59..000000000000
--- a/arch/s390/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_S390_MM_ARCH_HOOKS_H
-#define _ASM_S390_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_S390_MM_ARCH_HOOKS_H */
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index 138fb3db45ba..92ffe397b893 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -7,6 +7,7 @@ generic-y += clkdev.h
 generic-y += cputime.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
diff --git a/arch/score/include/asm/mm-arch-hooks.h b/arch/score/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 5e38689f189a..000000000000
--- a/arch/score/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_SCORE_MM_ARCH_HOOKS_H
-#define _ASM_SCORE_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_SCORE_MM_ARCH_HOOKS_H */
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 9ac4626e7284..aac452b26aa8 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -16,6 +16,7 @@ generic-y += kvm_para.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += msgbuf.h
 generic-y += param.h
diff --git a/arch/sh/include/asm/mm-arch-hooks.h b/arch/sh/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 18087298b728..000000000000
--- a/arch/sh/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_SH_MM_ARCH_HOOKS_H
-#define _ASM_SH_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_SH_MM_ARCH_HOOKS_H */
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index 2b2a69dcc467..e928618838bc 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -12,6 +12,7 @@ generic-y += linkage.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += module.h
 generic-y += mutex.h
 generic-y += preempt.h
diff --git a/arch/sparc/include/asm/mm-arch-hooks.h b/arch/sparc/include/asm/mm-arch-hooks.h
deleted file mode 100644
index b89ba44c16f1..000000000000
--- a/arch/sparc/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_SPARC_MM_ARCH_HOOKS_H
-#define _ASM_SPARC_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_SPARC_MM_ARCH_HOOKS_H */
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index d53654488c2c..d8a843163471 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -19,6 +19,7 @@ generic-y += irq_regs.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += msgbuf.h
 generic-y += mutex.h
 generic-y += param.h
diff --git a/arch/tile/include/asm/mm-arch-hooks.h b/arch/tile/include/asm/mm-arch-hooks.h
deleted file mode 100644
index d1709ea774f7..000000000000
--- a/arch/tile/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_TILE_MM_ARCH_HOOKS_H
-#define _ASM_TILE_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_TILE_MM_ARCH_HOOKS_H */
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index 3d63ff6f583f..149ec55f9c46 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -16,6 +16,7 @@ generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += kdebug.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mutex.h
 generic-y += param.h
 generic-y += pci.h
diff --git a/arch/um/include/asm/mm-arch-hooks.h b/arch/um/include/asm/mm-arch-hooks.h
deleted file mode 100644
index a7c8b0dfdd4e..000000000000
--- a/arch/um/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_UM_MM_ARCH_HOOKS_H
-#define _ASM_UM_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_UM_MM_ARCH_HOOKS_H */
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index d12b377b5a8b..1fc7a286dc6f 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -26,6 +26,7 @@ generic-y += kdebug.h
 generic-y += kmap_types.h
 generic-y += local.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += mman.h
 generic-y += module.h
 generic-y += msgbuf.h
diff --git a/arch/unicore32/include/asm/mm-arch-hooks.h b/arch/unicore32/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 4d79a850c509..000000000000
--- a/arch/unicore32/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_UNICORE32_MM_ARCH_HOOKS_H
-#define _ASM_UNICORE32_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_UNICORE32_MM_ARCH_HOOKS_H */
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 4dd1f2d770af..aeac434c9feb 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -9,3 +9,4 @@ generic-y += cputime.h
 generic-y += dma-contiguous.h
 generic-y += early_ioremap.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
diff --git a/arch/x86/include/asm/mm-arch-hooks.h b/arch/x86/include/asm/mm-arch-hooks.h
deleted file mode 100644
index 4e881a342236..000000000000
--- a/arch/x86/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_X86_MM_ARCH_HOOKS_H
-#define _ASM_X86_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_X86_MM_ARCH_HOOKS_H */
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 14d15bf1a95b..5b478accd5fc 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -19,6 +19,7 @@ generic-y += linkage.h
 generic-y += local.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
+generic-y += mm-arch-hooks.h
 generic-y += percpu.h
 generic-y += preempt.h
 generic-y += resource.h
diff --git a/arch/xtensa/include/asm/mm-arch-hooks.h b/arch/xtensa/include/asm/mm-arch-hooks.h
deleted file mode 100644
index d2e5cfd3dd02..000000000000
--- a/arch/xtensa/include/asm/mm-arch-hooks.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/*
- * Architecture specific mm hooks
- *
- * Copyright (C) 2015, IBM Corporation
- * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef _ASM_XTENSA_MM_ARCH_HOOKS_H
-#define _ASM_XTENSA_MM_ARCH_HOOKS_H
-
-#endif /* _ASM_XTENSA_MM_ARCH_HOOKS_H */
diff --git a/include/asm-generic/mm-arch-hooks.h b/include/asm-generic/mm-arch-hooks.h
new file mode 100644
index 000000000000..5ff0e5193f85
--- /dev/null
+++ b/include/asm-generic/mm-arch-hooks.h
@@ -0,0 +1,16 @@
+/*
+ * Architecture specific mm hooks
+ */
+
+#ifndef _ASM_GENERIC_MM_ARCH_HOOKS_H
+#define _ASM_GENERIC_MM_ARCH_HOOKS_H
+
+/*
+ * This file should be included through arch/../include/asm/Kbuild for
+ * the architecture which doesn't need specific mm hooks.
+ *
+ * In that case, the generic hooks defined in include/linux/mm-arch-hooks.h
+ * are used.
+ */
+
+#endif /* _ASM_GENERIC_MM_ARCH_HOOKS_H */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
