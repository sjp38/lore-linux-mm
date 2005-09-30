From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20050930073242.10631.47460.sendpatchset@cherry.local>
In-Reply-To: <20050930073232.10631.63786.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
Subject: [PATCH 02/07] i386: numa on non-smp
Date: Fri, 30 Sep 2005 16:33:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
From: Magnus Damm <magnus@valinux.co.jp>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch makes it possible to compile and use CONFIG_NUMA without CONFIG_SMP.
Useful for NUMA emulation on real or emulated UP hardware.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 asm-i386/topology.h |    7 ++++++-
 linux/topology.h    |    2 +-
 2 files changed, 7 insertions(+), 2 deletions(-)

--- from-0002/include/asm-i386/topology.h
+++ to-work/include/asm-i386/topology.h	2005-09-28 16:26:20.000000000 +0900
@@ -29,8 +29,9 @@
 
 #ifdef CONFIG_NUMA
 
-#include <asm/mpspec.h>
+#ifdef CONFIG_SMP
 
+#include <asm/mpspec.h>
 #include <linux/cpumask.h>
 
 /* Mappings between logical cpu number and node number */
@@ -88,6 +89,10 @@ static inline int node_to_first_cpu(int 
 	.nr_balance_failed	= 0,			\
 }
 
+#else
+#include <asm-generic/topology.h>
+#endif
+
 extern unsigned long node_start_pfn[];
 extern unsigned long node_end_pfn[];
 extern unsigned long node_remap_size[];
--- from-0002/include/linux/topology.h
+++ to-work/include/linux/topology.h	2005-09-28 16:26:20.000000000 +0900
@@ -158,7 +158,7 @@
 	.nr_balance_failed	= 0,			\
 }
 
-#ifdef CONFIG_NUMA
+#if defined(CONFIG_NUMA) && defined(CONFIG_SMP)
 #ifndef SD_NODE_INIT
 #error Please define an appropriate SD_NODE_INIT in include/asm/topology.h!!!
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
