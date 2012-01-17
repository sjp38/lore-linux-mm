Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 2A4EC6B00DD
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 12:25:13 -0500 (EST)
Date: Tue, 17 Jan 2012 09:24:54 -0800
From: tip-bot for Randy Dunlap <rdunlap@xenotime.net>
Message-ID: <tip-5ee71535440f034de1196b11f78cef81c4025c2b@git.kernel.org>
Reply-To: mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
        torvalds@linux-foundation.org, rdunlap@xenotime.net,
        tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org,
        mingo@elte.hu
In-Reply-To: <4F14811E.6090107@xenotime.net>
References: <4F14811E.6090107@xenotime.net>
Subject: [tip:x86/urgent] x86/kconfig: Move the ZONE_DMA entry under a menu
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com, torvalds@linux-foundation.org, rdunlap@xenotime.net, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, mingo@elte.hu

Commit-ID:  5ee71535440f034de1196b11f78cef81c4025c2b
Gitweb:     http://git.kernel.org/tip/5ee71535440f034de1196b11f78cef81c4025c2b
Author:     Randy Dunlap <rdunlap@xenotime.net>
AuthorDate: Mon, 16 Jan 2012 11:57:18 -0800
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Tue, 17 Jan 2012 10:41:36 +0100

x86/kconfig: Move the ZONE_DMA entry under a menu

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
Acked-by: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/4F14811E.6090107@xenotime.net
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: David Rientjes <rientjes@google.com>
---
 arch/x86/Kconfig |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 5731eb7..db190fa 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -120,16 +120,6 @@ config HAVE_LATENCYTOP_SUPPORT
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
 
@@ -253,6 +243,16 @@ source "kernel/Kconfig.freezer"
 
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
