Received: from rly30g.srv.mailcontrol.com (localhost.localdomain [127.0.0.1])
	by rly30g.srv.mailcontrol.com (MailControl) with ESMTP id m5BB5KJH018813
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 12:05:22 +0100
Received: from submission.mailcontrol.com (submission.mailcontrol.com [86.111.216.190])
	by rly30g.srv.mailcontrol.com (MailControl) id m5BB4hPM015061
	for linux-mm@kvack.org; Wed, 11 Jun 2008 12:04:43 +0100
Message-ID: <484FB149.4080000@csr.com>
Date: Wed, 11 Jun 2008 12:04:41 +0100
From: David Vrabel <david.vrabel@csr.com>
MIME-Version: 1.0
Subject: [patch] UWB: make UWB selectable on all archs with USB support
References: <20080609053908.8021a635.akpm@linux-foundation.org> <alpine.DEB.1.00.0806092250200.31236@gamma>
In-Reply-To: <alpine.DEB.1.00.0806092250200.31236@gamma>
Content-Type: multipart/mixed;
 boundary="------------070500000603020600010402"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Byron Bradley <byron.bbradley@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070500000603020600010402
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Byron Bradley wrote:
> I'm getting the error below when compiling for ARM (Marvell Orion 5x) but 
> having trouble working out exacty why. It looks like it isn't selecting 
> any of the CONFIG_UWB* options which USB_WHCI_HCD should select. Config is 
> attached.

ARM (and some other architectures) don't use drivers/Kconfig.  This
patch enables UWB on all these architectures that have USB support.

David
-- 
David Vrabel, Senior Software Engineer, Drivers
CSR, Churchill House, Cambridge Business Park,  Tel: +44 (0)1223 692562
Cowley Road, Cambridge, CB4 0WZ                 http://www.csr.com/

--------------070500000603020600010402
Content-Type: text/x-diff;
 name="uwb-arch-source-drivers-uwb-Kconfig.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="uwb-arch-source-drivers-uwb-Kconfig.patch"

UWB: make UWB selectable on all archs with USB support

Signed-off-by: David Vrabel <david.vrabel@csr.com>

---
 arch/arm/Kconfig   |    2 ++
 arch/cris/Kconfig  |    2 ++
 arch/h8300/Kconfig |    2 ++
 arch/v850/Kconfig  |    2 ++
 4 files changed, 8 insertions(+)

Index: linux-2.6-working/arch/arm/Kconfig
===================================================================
--- linux-2.6-working.orig/arch/arm/Kconfig	2008-06-11 11:55:37.000000000 +0100
+++ linux-2.6-working/arch/arm/Kconfig	2008-06-11 11:56:29.000000000 +0100
@@ -1169,6 +1169,8 @@
 
 source "drivers/usb/Kconfig"
 
+source "drivers/uwb/Kconfig"
+
 source "drivers/mmc/Kconfig"
 
 source "drivers/leds/Kconfig"
Index: linux-2.6-working/arch/cris/Kconfig
===================================================================
--- linux-2.6-working.orig/arch/cris/Kconfig	2008-06-11 11:55:37.000000000 +0100
+++ linux-2.6-working/arch/cris/Kconfig	2008-06-11 11:56:11.000000000 +0100
@@ -677,6 +677,8 @@
 
 source "drivers/usb/Kconfig"
 
+source "drivers/uwb/Kconfig"
+
 source "arch/cris/Kconfig.debug"
 
 source "security/Kconfig"
Index: linux-2.6-working/arch/h8300/Kconfig
===================================================================
--- linux-2.6-working.orig/arch/h8300/Kconfig	2008-06-11 11:55:37.000000000 +0100
+++ linux-2.6-working/arch/h8300/Kconfig	2008-06-11 11:56:11.000000000 +0100
@@ -227,6 +227,8 @@
 
 source "drivers/usb/Kconfig"
 
+source "drivers/uwb/Kconfig"
+
 endmenu
 
 source "fs/Kconfig"
Index: linux-2.6-working/arch/v850/Kconfig
===================================================================
--- linux-2.6-working.orig/arch/v850/Kconfig	2008-06-11 11:55:38.000000000 +0100
+++ linux-2.6-working/arch/v850/Kconfig	2008-06-11 11:56:11.000000000 +0100
@@ -342,6 +342,8 @@
 
 source "drivers/usb/Kconfig"
 
+source "drivers/uwb/Kconfig"
+
 source "arch/v850/Kconfig.debug"
 
 source "security/Kconfig"

--------------070500000603020600010402--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
