From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 12:53:20 +1000 (EST)
Subject: [PATCH 2/15] PTI: Add general files and directories
In-Reply-To: <20050521024331.GA6984@cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 2 of 15.

This patch adds the files and directories for architecture independent
mlpt code to sit behind a clean page table interface.

 	*mlpt.c is to contain the mlpt specific functions to be moved
 	 behind the interface.
 	*page_table.h is for including general page table implementations.
 	 In this case, the incumbent mlpt.
 	*pgtable-mlpt.h and tlb-mlpt.h are for mlpt abstractions from
 	 the generic pgtable.h and tlb.h
 	*mm-mlpt.h is for mlpt abstractions from mm.h

  include/asm-generic/pgtable-mlpt.h |    4 ++++
  include/asm-generic/tlb-mlpt.h     |    4 ++++
  include/linux/page_table.h         |   12 ++++++++++++
  include/mm/mm-mlpt.h               |    4 ++++
  mm/Makefile                        |    2 ++
  mm/fixed-mlpt/Makefile             |    3 +++
  mm/fixed-mlpt/mlpt.c               |    1 +
  7 files changed, 30 insertions(+)

Index: linux-2.6.12-rc4/mm/fixed-mlpt/mlpt.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/mm/fixed-mlpt/mlpt.c	2005-05-19 
17:08:37.000000000 +1000
@@ -0,0 +1 @@
+#include <linux/page_table.h>
Index: linux-2.6.12-rc4/mm/Makefile
===================================================================
--- linux-2.6.12-rc4.orig/mm/Makefile	2005-05-19 17:08:34.000000000 
+1000
+++ linux-2.6.12-rc4/mm/Makefile	2005-05-19 17:08:37.000000000 
+1000
@@ -7,6 +7,8 @@
  			   mlock.o mmap.o mprotect.o mremap.o msync.o 
rmap.o \
  			   vmalloc.o

+mmu-$(CONFIG_MMU)	+= fixed-mlpt/
+
  obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o 
fadvise.o \
  			   page_alloc.o page-writeback.o pdflush.o \
  			   readahead.o slab.o swap.o truncate.o vmscan.o \
Index: linux-2.6.12-rc4/mm/fixed-mlpt/Makefile
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/mm/fixed-mlpt/Makefile	2005-05-19 
17:08:37.000000000 +1000
@@ -0,0 +1,3 @@
+#Makefile for mm/fixed-mlpt/
+
+obj-y	:= mlpt.o
Index: linux-2.6.12-rc4/include/linux/page_table.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/include/linux/page_table.h	2005-05-19 
17:08:37.000000000 +1000
@@ -0,0 +1,12 @@
+#ifndef _LINUX_PAGE_TABLE_H
+#define _LINUX_PAGE_TABLE_H 1
+
+#include <linux/config.h>
+#include <asm/pgtable.h>
+
+#ifdef CONFIG_MLPT
+#include <asm/pgalloc.h>
+#include <mm/mlpt-generic.h>
+#endif
+
+#endif
Index: linux-2.6.12-rc4/include/mm/mm-mlpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/include/mm/mm-mlpt.h	2005-05-19 
17:08:37.000000000 +1000
@@ -0,0 +1,4 @@
+#ifndef _MM_MM_MLPT_H
+#define _MM_MM_MLPT_H 1
+
+#endif
Index: linux-2.6.12-rc4/include/asm-generic/pgtable-mlpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/include/asm-generic/pgtable-mlpt.h	2005-05-19 
17:08:37.000000000 +1000
@@ -0,0 +1,4 @@
+#ifndef _ASM_GENERIC_PGTABLE_MLPT_H
+#define _ASM_GENERIC_PGTABLE_MLPT_H 1
+
+#endif
Index: linux-2.6.12-rc4/include/asm-generic/tlb-mlpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/include/asm-generic/tlb-mlpt.h	2005-05-19 
17:08:37.000000000 +1000
@@ -0,0 +1,4 @@
+#ifndef _ASM_GENERIC_TLB_MLPT_H
+#define _ASM_GENERIC_TLB_MLPT_H 1
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
