Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j3BMxV5j837888
	for <linux-mm@kvack.org>; Mon, 11 Apr 2005 18:59:31 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j3BMxV6O250588
	for <linux-mm@kvack.org>; Mon, 11 Apr 2005 16:59:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j3BMxVaq029404
	for <linux-mm@kvack.org>; Mon, 11 Apr 2005 16:59:31 -0600
Subject: [PATCH 1/3] mm/Kconfig: kill unused ARCH_FLATMEM_DISABLE
From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 11 Apr 2005 15:59:29 -0700
Message-Id: <E1DL7sQ-00030O-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, zippel@linux-m68k.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This used to be used to disable FLATMEM selection, but I decided
to change it to be done generically when DISCONTIG is enabled.
The option is unused, so this kills it.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/./arch/mips/Kconfig   |    4 ----
 memhotplug-dave/./arch/parisc/Kconfig |    4 ----
 memhotplug-dave/./arch/sh/Kconfig     |    4 ----
 3 files changed, 12 deletions(-)

diff -puN ./arch/parisc/Kconfig~A0-mm-Kconfig-kill-ARCH_FLATMEM_DISABLE ./arch/parisc/Kconfig
--- memhotplug/./arch/parisc/Kconfig~A0-mm-Kconfig-kill-ARCH_FLATMEM_DISABLE	2005-04-11 15:49:09.000000000 -0700
+++ memhotplug-dave/./arch/parisc/Kconfig	2005-04-11 15:49:09.000000000 -0700
@@ -153,10 +153,6 @@ config ARCH_DISCONTIGMEM_ENABLE
 	  or have huge holes in the physical address space for other reasons.
 	  See <file:Documentation/vm/numa> for more.
 
-config ARCH_FLATMEM_DISABLE
-	def_bool y
-	depends on ARCH_DISCONTIGMEM_ENABLE
-
 source "mm/Kconfig"
 
 config PREEMPT
diff -puN ./arch/sh/Kconfig~A0-mm-Kconfig-kill-ARCH_FLATMEM_DISABLE ./arch/sh/Kconfig
--- memhotplug/./arch/sh/Kconfig~A0-mm-Kconfig-kill-ARCH_FLATMEM_DISABLE	2005-04-11 15:49:09.000000000 -0700
+++ memhotplug-dave/./arch/sh/Kconfig	2005-04-11 15:49:09.000000000 -0700
@@ -496,10 +496,6 @@ config ARCH_DISCONTIGMEM_ENABLE
 	  or have huge holes in the physical address space for other reasons.
 	  See <file:Documentation/vm/numa> for more.
 
-config ARCH_FLATMEM_DISABLE
-	def_bool y
-	depends on ARCH_DISCONTIGMEM_ENABLE
-
 source "mm/Kconfig"
 
 config ZERO_PAGE_OFFSET
diff -puN ./arch/mips/Kconfig~A0-mm-Kconfig-kill-ARCH_FLATMEM_DISABLE ./arch/mips/Kconfig
--- memhotplug/./arch/mips/Kconfig~A0-mm-Kconfig-kill-ARCH_FLATMEM_DISABLE	2005-04-11 15:49:09.000000000 -0700
+++ memhotplug-dave/./arch/mips/Kconfig	2005-04-11 15:49:09.000000000 -0700
@@ -501,10 +501,6 @@ config ARCH_DISCONTIGMEM_ENABLE
 	  or have huge holes in the physical address space for other reasons.
 	  See <file:Documentation/vm/numa> for more.
 
-config ARCH_FLATMEM_DISABLE
-	def_bool y
-	depends on ARCH_DISCONTIGMEM_ENABLE
-
 config NUMA
 	bool "NUMA Support"
 	depends on SGI_IP27
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
