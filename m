Date: Thu, 22 Jan 2004 14:12:22 -0700
From: Tom Rini <trini@kernel.crashing.org>
Subject: Re: 2.6.2-rc1-mm1
Message-ID: <20040122211222.GP15271@stop.crashing.org>
References: <20040122013501.2251e65e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040122013501.2251e65e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 22, 2004 at 01:35:01AM -0800, Andrew Morton wrote:

> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2-rc1/2.6.2-rc1-mm1/

Relative to this I have:
>From Tom Rini <trini@kernel.crashing.org>

Switch PPC32 over to drivers/Kconfig

 arch/ppc/Kconfig |   41 +----------------------------------------
 1 files changed, 1 insertion(+), 40 deletions(-)
--- 1.47/arch/ppc/Kconfig	Mon Jan 19 16:38:06 2004
+++ edited/arch/ppc/Kconfig	Thu Jan 22 13:47:15 2004
@@ -989,8 +989,6 @@
 
 source "drivers/pcmcia/Kconfig"
 
-source "drivers/parport/Kconfig"
-
 endmenu
 
 menu "Advanced setup"
@@ -1088,36 +1086,7 @@
 	depends on ADVANCED_OPTIONS && 8xx
 endmenu
 
-source "drivers/base/Kconfig"
-
-source "drivers/mtd/Kconfig"
-
-source "drivers/pnp/Kconfig"
-
-source "drivers/block/Kconfig"
-
-source "drivers/md/Kconfig"
-
-source "drivers/ide/Kconfig"
-
-source "drivers/scsi/Kconfig"
-
-source "drivers/message/fusion/Kconfig"
-
-source "drivers/ieee1394/Kconfig"
-
-source "drivers/message/i2o/Kconfig"
-
-source "net/Kconfig"
-
-source "drivers/isdn/Kconfig"
-
-source "drivers/video/Kconfig"
-
-source "drivers/cdrom/Kconfig"
-
-source "drivers/input/Kconfig"
-
+source "drivers/Kconfig"
 
 menu "Macintosh device drivers"
 
@@ -1253,14 +1222,8 @@
 
 endmenu
 
-source "drivers/char/Kconfig"
-
-source "drivers/media/Kconfig"
-
 source "fs/Kconfig"
 
-source "sound/Kconfig"
-
 source "arch/ppc/8xx_io/Kconfig"
 
 source "arch/ppc/8260_io/Kconfig"
@@ -1284,8 +1247,6 @@
 	default y
 
 endmenu
-
-source "drivers/usb/Kconfig"
 
 source "lib/Kconfig"
 

-- 
Tom Rini
http://gate.crashing.org/~trini/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
