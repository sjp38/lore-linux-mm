Message-Id: <20070504103203.181287020@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:24 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 33/40] uml: enable scsi and add iscsi config
Content-Disposition: inline; filename=uml_iscsi.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

Enable (i)SCSI on UML, dunno why SCSI was deemed broken, it works like a charm.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Jeff Dike <jdike@addtoit.com>
Cc: James Bottomley <James.Bottomley@SteelEye.com>
Cc: Mike Christie <michaelc@cs.wisc.edu>
---
 arch/um/Kconfig      |   16 --------------
 arch/um/Kconfig.scsi |   58 ---------------------------------------------------
 2 files changed, 1 insertion(+), 73 deletions(-)

Index: linux-2.6-git/arch/um/Kconfig
===================================================================
--- linux-2.6-git.orig/arch/um/Kconfig	2006-12-11 14:39:09.000000000 +0100
+++ linux-2.6-git/arch/um/Kconfig	2007-01-16 14:14:45.000000000 +0100
@@ -317,21 +317,7 @@ source "crypto/Kconfig"
 
 source "lib/Kconfig"
 
-menu "SCSI support"
-depends on BROKEN
-
-config SCSI
-	tristate "SCSI support"
-
-# This gives us free_dma, which scsi.c wants.
-config GENERIC_ISA_DMA
-	bool
-	depends on SCSI
-	default y
-
-source "arch/um/Kconfig.scsi"
-
-endmenu
+source "drivers/scsi/Kconfig"
 
 source "drivers/md/Kconfig"
 
Index: linux-2.6-git/arch/um/Kconfig.scsi
===================================================================
--- linux-2.6-git.orig/arch/um/Kconfig.scsi	2006-09-05 15:30:39.000000000 +0200
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,58 +0,0 @@
-comment "SCSI support type (disk, tape, CD-ROM)"
-	depends on SCSI
-
-config BLK_DEV_SD
-	tristate "SCSI disk support"
-	depends on SCSI
-
-config SD_EXTRA_DEVS
-	int "Maximum number of SCSI disks that can be loaded as modules"
-	depends on BLK_DEV_SD
-	default "40"
-
-config CHR_DEV_ST
-	tristate "SCSI tape support"
-	depends on SCSI
-
-config BLK_DEV_SR
-	tristate "SCSI CD-ROM support"
-	depends on SCSI
-
-config BLK_DEV_SR_VENDOR
-	bool "Enable vendor-specific extensions (for SCSI CDROM)"
-	depends on BLK_DEV_SR
-
-config SR_EXTRA_DEVS
-	int "Maximum number of CDROM devices that can be loaded as modules"
-	depends on BLK_DEV_SR
-	default "2"
-
-config CHR_DEV_SG
-	tristate "SCSI generic support"
-	depends on SCSI
-
-comment "Some SCSI devices (e.g. CD jukebox) support multiple LUNs"
-	depends on SCSI
-
-#if [ "$CONFIG_EXPERIMENTAL" = "y" ]; then
-config SCSI_DEBUG_QUEUES
-	bool "Enable extra checks in new queueing code"
-	depends on SCSI
-
-#fi
-config SCSI_MULTI_LUN
-	bool "Probe all LUNs on each SCSI device"
-	depends on SCSI
-
-config SCSI_CONSTANTS
-	bool "Verbose SCSI error reporting (kernel size +=12K)"
-	depends on SCSI
-
-config SCSI_LOGGING
-	bool "SCSI logging facility"
-	depends on SCSI
-
-config SCSI_DEBUG
-	tristate "SCSI debugging host simulator (EXPERIMENTAL)"
-	depends on SCSI
-

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
