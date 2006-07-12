From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:37:34 +0200
Message-Id: <20060712143734.16998.1938.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 3/39] mm: pgrep: prepare for page replace framework
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Introduce the configuration option, and modify the Makefile.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 mm/Kconfig   |   11 +++++++++++
 mm/Makefile  |    2 ++
 mm/useonce.c |    3 +++
 3 files changed, 16 insertions(+)

Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/Kconfig	2006-07-12 16:11:29.000000000 +0200
@@ -133,6 +133,17 @@ config SPLIT_PTLOCK_CPUS
 	default "4096" if PARISC && !PA20
 	default "4"
 
+choice
+	prompt	"Page replacement policy"
+	default MM_POLICY_USEONCE
+
+config MM_POLICY_USEONCE
+	bool "LRU-2Q USE-ONCE"
+	help
+	  This option selects the standard multi-queue LRU policy.
+
+endchoice
+
 #
 # support for page migration
 #
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/Makefile	2006-07-12 16:11:29.000000000 +0200
@@ -12,6 +12,8 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o $(mmu-y)
 
+obj-$(CONFIG_MM_POLICY_USEONCE) += useonce.o
+
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
Index: linux-2.6/mm/useonce.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:58.000000000 +0200
@@ -0,0 +1,3 @@
+
+
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
