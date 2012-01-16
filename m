Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 3DA086B00AB
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 13:58:59 -0500 (EST)
Message-ID: <4F14811E.6090107@xenotime.net>
Date: Mon, 16 Jan 2012 11:57:18 -0800
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: [PATCH] config menu: move ZONE_DMA under a menu
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, x86 maintainers <x86@kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Move the ZONE_DMA kconfig symbol under a menu item instead
of having it listed before everything else in
"make {xconfig | gconfig | nconfig | menuconfig}".

This drops the first line of the top-level kernel config menu
(in 3.2) below and moves it under "Processor type and features".

          [*] DMA memory allocation support
              General setup  --->
          [*] Enable loadable module support  --->
          [*] Enable the block layer  --->
              Processor type and features  --->
              Power management and ACPI options  --->
              Bus options (PCI etc.)  --->
              Executable file formats / Emulations  --->


Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Cc: David Rientjes <rientjes@google.com>
---
 arch/x86/Kconfig |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

--- lnx-32.orig/arch/x86/Kconfig
+++ lnx-32/arch/x86/Kconfig
@@ -118,16 +118,6 @@ config HAVE_LATENCYTOP_SUPPORT
 config MMU
 	def_bool y
 
-config ZONE_DMA
-	bool "DMA memory allocation support" if EXPERT
-	default y
-	help
-	  DMA memory allocation support allows devices with less than 32-bit
-	  addressing to allocate within the first 16MB of address space.
-	  Disable if no such devices will be used.
-
-	  If unsure, say Y.
-
 config SBUS
 	bool
 
@@ -254,6 +244,16 @@ source "kernel/Kconfig.freezer"
 
 menu "Processor type and features"
 
+config ZONE_DMA
+	bool "DMA memory allocation support" if EXPERT
+	default y
+	help
+	  DMA memory allocation support allows devices with less than 32-bit
+	  addressing to allocate within the first 16MB of address space.
+	  Disable if no such devices will be used.
+
+	  If unsure, say Y.
+
 source "kernel/time/Kconfig"
 
 config SMP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
