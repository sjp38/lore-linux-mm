Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j3BMxc5j171534
	for <linux-mm@kvack.org>; Mon, 11 Apr 2005 18:59:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j3BMxc6O226434
	for <linux-mm@kvack.org>; Mon, 11 Apr 2005 16:59:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j3BMxcVX029651
	for <linux-mm@kvack.org>; Mon, 11 Apr 2005 16:59:38 -0600
Subject: [PATCH 3/3] mm/Kconfig: give DISCONTIG more help text
From: Dave Hansen <haveblue@us.ibm.com>
Date: Mon, 11 Apr 2005 15:59:36 -0700
Message-Id: <E1DL7sX-00037u-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, zippel@linux-m68k.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This gives DISCONTIGMEM a bit more help text to explain
what it does, not just when to choose it.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/mm/Kconfig |   10 ++++++++++
 1 files changed, 10 insertions(+)

diff -puN mm/Kconfig~A2-mm-Kconfig-DISCONTIG-help-text mm/Kconfig
--- memhotplug/mm/Kconfig~A2-mm-Kconfig-DISCONTIG-help-text	2005-04-11 15:49:10.000000000 -0700
+++ memhotplug-dave/mm/Kconfig	2005-04-11 15:49:10.000000000 -0700
@@ -23,6 +23,16 @@ config DISCONTIGMEM_MANUAL
 	bool "Discontigious Memory"
 	depends on ARCH_DISCONTIGMEM_ENABLE
 	help
+	  This option provides enhanced support for discontiguous
+	  memory systems, over FLATMEM.  These systems have holes
+	  in their physical address spaces, and this option provides
+	  more efficient handling of these holes.  However, the vast
+	  majority of hardware has quite flat address spaces, and
+	  can have degraded performance from extra overhead that
+	  this option imposes.
+
+	  Many NUMA configurations will have this as the only option.
+
 	  If unsure, choose "Flat Memory" over this option.
 
 endchoice
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
