Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 521336B00E7
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 12:50:08 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] remove duplicate asm/mman.h files
Date: Fri, 18 Sep 2009 18:48:42 +0200
References: <cover.1251197514.git.ebmunson@us.ibm.com> <20090917174616.f64123fb.akpm@linux-foundation.org> <200909181719.47240.arnd@arndb.de>
In-Reply-To: <200909181719.47240.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909181848.42192.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ebmunson@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, rth@twiddle.net, ink@jurassic.park.msu.ru
List-ID: <linux-mm.kvack.org>

A number of architectures have identical asm/mman.h files,
x86 differs only in a single line, so they can all be merged
by using the new generic file.

The remaining asm/mman.h files are substantially different
from each other.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
On Friday 18 September 2009, Arnd Bergmann wrote:
> A logical next step would be to replace the mman.h files that are basically
> copies of include/asm-generic/mman.h.

We might as well do it now, since we're touching them anyway...
Patch applies on top of the previous one.

 arch/arm/include/asm/mman.h     |   20 +-------------------
 arch/avr32/include/asm/mman.h   |   20 +-------------------
 arch/cris/include/asm/mman.h    |   22 +---------------------
 arch/frv/include/asm/mman.h     |   21 +--------------------
 arch/h8300/include/asm/mman.h   |   20 +-------------------
 arch/ia64/include/asm/mman.h    |   16 ++--------------
 arch/m32r/include/asm/mman.h    |   20 +-------------------
 arch/m68k/include/asm/mman.h    |   20 +-------------------
 arch/mn10300/include/asm/mman.h |   31 +------------------------------
 arch/s390/include/asm/mman.h    |   15 +--------------
 arch/x86/include/asm/mman.h     |   15 +--------------
 11 files changed, 12 insertions(+), 208 deletions(-)

diff --git a/arch/arm/include/asm/mman.h b/arch/arm/include/asm/mman.h
index 6464d47..8eebf89 100644
--- a/arch/arm/include/asm/mman.h
+++ b/arch/arm/include/asm/mman.h
@@ -1,19 +1 @@
-#ifndef __ARM_MMAN_H__
-#define __ARM_MMAN_H__
-
-#include <asm-generic/mman-common.h>
-
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) page tables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
-
-#endif /* __ARM_MMAN_H__ */
+#include <asm-generic/mman.h>
diff --git a/arch/avr32/include/asm/mman.h b/arch/avr32/include/asm/mman.h
index 38cea1b..8eebf89 100644
--- a/arch/avr32/include/asm/mman.h
+++ b/arch/avr32/include/asm/mman.h
@@ -1,19 +1 @@
-#ifndef __ASM_AVR32_MMAN_H__
-#define __ASM_AVR32_MMAN_H__
-
-#include <asm-generic/mman-common.h>
-
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) page tables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
-
-#endif /* __ASM_AVR32_MMAN_H__ */
+#include <asm-generic/mman.h>
diff --git a/arch/cris/include/asm/mman.h b/arch/cris/include/asm/mman.h
index de6b903..8eebf89 100644
--- a/arch/cris/include/asm/mman.h
+++ b/arch/cris/include/asm/mman.h
@@ -1,21 +1 @@
-#ifndef __CRIS_MMAN_H__
-#define __CRIS_MMAN_H__
-
-/* verbatim copy of asm-i386/ version */
-
-#include <asm-generic/mman-common.h>
-
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
-
-#endif /* __CRIS_MMAN_H__ */
+#include <asm-generic/mman.h>
diff --git a/arch/frv/include/asm/mman.h b/arch/frv/include/asm/mman.h
index 1939343..8eebf89 100644
--- a/arch/frv/include/asm/mman.h
+++ b/arch/frv/include/asm/mman.h
@@ -1,20 +1 @@
-#ifndef __ASM_MMAN_H__
-#define __ASM_MMAN_H__
-
-#include <asm-generic/mman-common.h>
-
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
-
-#endif /* __ASM_MMAN_H__ */
-
+#include <asm-generic/mman.h>
diff --git a/arch/h8300/include/asm/mman.h b/arch/h8300/include/asm/mman.h
index eacacd0..8eebf89 100644
--- a/arch/h8300/include/asm/mman.h
+++ b/arch/h8300/include/asm/mman.h
@@ -1,19 +1 @@
-#ifndef __H8300_MMAN_H__
-#define __H8300_MMAN_H__
-
-#include <asm-generic/mman-common.h>
-
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
-
-#endif /* __H8300_MMAN_H__ */
+#include <asm-generic/mman.h>
diff --git a/arch/ia64/include/asm/mman.h b/arch/ia64/include/asm/mman.h
index cf55884..4459028 100644
--- a/arch/ia64/include/asm/mman.h
+++ b/arch/ia64/include/asm/mman.h
@@ -8,21 +8,9 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co
  */
 
-#include <asm-generic/mman-common.h>
+#include <asm-generic/mman.h>
 
-#define MAP_GROWSDOWN	0x00100		/* stack-like segment */
-#define MAP_GROWSUP	0x00200		/* register stack-like segment */
-#define MAP_DENYWRITE	0x00800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x01000		/* mark it as an executable */
-#define MAP_LOCKED	0x02000		/* pages are locked */
-#define MAP_NORESERVE	0x04000		/* don't check for reservations */
-#define MAP_POPULATE	0x08000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
+#define MAP_GROWSUP	0x0200		/* register stack-like segment */
 
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
diff --git a/arch/m32r/include/asm/mman.h b/arch/m32r/include/asm/mman.h
index d191089..8eebf89 100644
--- a/arch/m32r/include/asm/mman.h
+++ b/arch/m32r/include/asm/mman.h
@@ -1,19 +1 @@
-#ifndef __M32R_MMAN_H__
-#define __M32R_MMAN_H__
-
-#include <asm-generic/mman-common.h>
-
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
-
-#endif /* __M32R_MMAN_H__ */
+#include <asm-generic/mman.h>
diff --git a/arch/m68k/include/asm/mman.h b/arch/m68k/include/asm/mman.h
index c421fef..8eebf89 100644
--- a/arch/m68k/include/asm/mman.h
+++ b/arch/m68k/include/asm/mman.h
@@ -1,19 +1 @@
-#ifndef __M68K_MMAN_H__
-#define __M68K_MMAN_H__
-
-#include <asm-generic/mman-common.h>
-
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
-
-#endif /* __M68K_MMAN_H__ */
+#include <asm-generic/mman.h>
diff --git a/arch/mn10300/include/asm/mman.h b/arch/mn10300/include/asm/mman.h
index 94611c3..8eebf89 100644
--- a/arch/mn10300/include/asm/mman.h
+++ b/arch/mn10300/include/asm/mman.h
@@ -1,30 +1 @@
-/* MN10300 Constants for mmap and co.
- *
- * Copyright (C) 2007 Matsushita Electric Industrial Co., Ltd.
- * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
- * - Derived from asm-x86/mman.h
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public Licence
- * as published by the Free Software Foundation; either version
- * 2 of the Licence, or (at your option) any later version.
- */
-#ifndef _ASM_MMAN_H
-#define _ASM_MMAN_H
-
-#include <asm-generic/mman-common.h>
-
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
-
-#endif /* _ASM_MMAN_H */
+#include <asm-generic/mman.h>
diff --git a/arch/s390/include/asm/mman.h b/arch/s390/include/asm/mman.h
index 22714ca..4e9c8ae 100644
--- a/arch/s390/include/asm/mman.h
+++ b/arch/s390/include/asm/mman.h
@@ -9,20 +9,7 @@
 #ifndef __S390_MMAN_H__
 #define __S390_MMAN_H__
 
-#include <asm-generic/mman-common.h>
-
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
+#include <asm-generic/mman.h>
 
 #if defined(__KERNEL__) && !defined(__ASSEMBLY__) && defined(CONFIG_64BIT)
 int s390_mmap_check(unsigned long addr, unsigned long len);
diff --git a/arch/x86/include/asm/mman.h b/arch/x86/include/asm/mman.h
index c719f36..c582add 100644
--- a/arch/x86/include/asm/mman.h
+++ b/arch/x86/include/asm/mman.h
@@ -1,21 +1,8 @@
 #ifndef _ASM_X86_MMAN_H
 #define _ASM_X86_MMAN_H
 
-#include <asm-generic/mman-common.h>
+#include <asm-generic/mman.h>
 
 #define MAP_32BIT	0x40		/* only give out 32bit addresses */
 
-#define MAP_GROWSDOWN	0x0100		/* stack-like segment */
-#define MAP_DENYWRITE	0x0800		/* ETXTBSY */
-#define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
-#define MAP_LOCKED	0x2000		/* pages are locked */
-#define MAP_NORESERVE	0x4000		/* don't check for reservations */
-#define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
-#define MAP_NONBLOCK	0x10000		/* do not block on IO */
-#define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
-#define MAP_HUGETLB	0x40000		/* create a huge page mapping */
-
-#define MCL_CURRENT	1		/* lock all current mappings */
-#define MCL_FUTURE	2		/* lock all future mappings */
-
 #endif /* _ASM_X86_MMAN_H */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
