Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E83046B006E
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 10:25:19 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so142945807wgq.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 07:25:19 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id ee2si13403569wib.50.2015.06.29.07.25.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jun 2015 07:25:17 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 29 Jun 2015 15:25:14 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 70E281B08023
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 15:26:17 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5TEPBYA26804428
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 14:25:11 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5TEPASg022956
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:25:10 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH] mm: cleaning per architecture MM hook header files
Date: Mon, 29 Jun 2015 16:25:09 +0200
Message-Id: <1435587909-23163-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The commit 2ae416b142b6 ("mm: new mm hook framework") introduced an empty
header file (mm-arch-hooks.h) for every architecture, even those which
doesn't need to define mm hooks.

As suggested by Geert Uytterhoeven, this could be cleaned through the use
of a generic header file included via each per architecture
asm/include/Kbuild file.

The powerpc architecture is not impacted here since this architecture has
to defined the arch_remap MM hook.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Suggested-by: Geert Uytterhoeven <geert@linux-m68k.org>
CC: Andrew Morton <akpm@linux-foundation.org>
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
 59 files changed, 45 insertions(+), 435 deletions(-)
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
index cde23cd03609..6ade2b0ffe7d 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -8,3 +8,4 @@ generic-y += mcs_spinlock.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
+generic-y += mm-arch-hooks.h
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
index 769b312c1abb..2febe6ff32ed 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -49,3 +49,4 @@ generic-y += ucontext.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 83c50193626c..870a2f7cbada 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -36,3 +36,4 @@ generic-y += termios.h
 generic-y += timex.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
+generic-y += mm-arch-hooks.h
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
index b112a39834d0..8e4aaf7752fc 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -55,3 +55,4 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 1d66afdfac07..3ce00826820a 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -20,3 +20,4 @@ generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 07051a63415d..803fae380fec 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -46,3 +46,4 @@ generic-y += ucontext.h
 generic-y += unaligned.h
 generic-y += user.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 7aeb32272975..c598e839be09 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -59,3 +59,4 @@ generic-y += ucontext.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index d294f6aaff1d..32a8f801f4cf 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -26,3 +26,4 @@ generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 30edce31e5c2..dd304be68f2b 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -6,3 +6,4 @@ generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
 generic-y += trace_clock.h
+generic-y += mm-arch-hooks.h
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
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index 5ade4a163558..1cfb0a953f55 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -58,3 +58,4 @@ generic-y += ucontext.h
 generic-y += unaligned.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index ccff13d33fa2..3b3346fb6644 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -7,3 +7,4 @@ generic-y += mcs_spinlock.h
 generic-y += preempt.h
 generic-y += trace_clock.h
 generic-y += vtime.h
+generic-y += mm-arch-hooks.h
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
index ba1cdc018731..01cab2a9cd0e 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -8,3 +8,4 @@ generic-y += module.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
+generic-y += mm-arch-hooks.h
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
index 1555bc189c7d..c562b87b4357 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -34,3 +34,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 199320f3c345..dbee6519f565 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -54,3 +54,4 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 9989ddb169ca..78defa93e184 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -9,3 +9,4 @@ generic-y += mcs_spinlock.h
 generic-y += preempt.h
 generic-y += syscalls.h
 generic-y += trace_clock.h
+generic-y += mm-arch-hooks.h
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
index 7fe5c61a3cb8..cb5129f73596 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -18,3 +18,4 @@ generic-y += trace_clock.h
 generic-y += ucontext.h
 generic-y += user.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index de30b0c88796..2dc286bf9d5d 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -8,3 +8,4 @@ generic-y += mcs_spinlock.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += trace_clock.h
+generic-y += mm-arch-hooks.h
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
index 434639d510b3..e4c6706e898b 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -61,3 +61,4 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 2a2e39b8109a..49ddfea4f0d5 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -70,3 +70,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 12b341d04f88..b4046153287f 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -28,3 +28,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index dc5385ebb071..f9438034be52 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -5,3 +5,4 @@ generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
 generic-y += trace_clock.h
+generic-y += mm-arch-hooks.h
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
index 138fb3db45ba..5dbbd9124d9f 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -12,3 +12,4 @@ generic-y += sections.h
 generic-y += trace_clock.h
 generic-y += xor.h
 generic-y += serial.h
+generic-y += mm-arch-hooks.h
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
index 9ac4626e7284..acd3ade6f1aa 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -36,3 +36,4 @@ generic-y += termios.h
 generic-y += trace_clock.h
 generic-y += ucontext.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 2b2a69dcc467..861255f62e2e 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -19,3 +19,4 @@ generic-y += serial.h
 generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
+generic-y += mm-arch-hooks.h
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
index d53654488c2c..55814036fe9f 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -39,3 +39,4 @@ generic-y += termios.h
 generic-y += trace_clock.h
 generic-y += types.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 3d63ff6f583f..4020ae6fc36b 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -25,3 +25,4 @@ generic-y += switch_to.h
 generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index d12b377b5a8b..f022b35baeab 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -62,3 +62,4 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
index 14d15bf1a95b..91128f2a341e 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -29,3 +29,4 @@ generic-y += termios.h
 generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += xor.h
+generic-y += mm-arch-hooks.h
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
