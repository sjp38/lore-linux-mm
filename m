Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE7B6B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 13:09:00 -0500 (EST)
Date: Tue, 7 Dec 2010 10:08:24 -0800
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V0 4/4] kztmem: misc build/config
Message-ID: <20101207180824.GA28189@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

[PATCH V0 4/4] kztmem: misc build/config

Makefiles and Kconfigs to build kztmem in drivers/staging

There is a dependency on xvmalloc.* which in 2.6.36 resides
in drivers/staging/zram.  Should this move or disappear,
some Makefile/Kconfig changes will be required.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

---

Diffstat:
 drivers/staging/Kconfig                  |    2 ++
 drivers/staging/Makefile                 |    1 +
 drivers/staging/kztmem/Kconfig           |    8 ++++++++
 drivers/staging/kztmem/Makefile          |    1 +
 4 files changed, 12 insertions(+)

--- linux-2.6.36/drivers/staging/kztmem/Makefile	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-kztmem/drivers/staging/kztmem/Makefile	2010-12-02 11:57:51.000000000 -0700
@@ -0,0 +1 @@
+obj-$(CONFIG_KZTMEM)	+=	kztmem.o tmem.o sadix-tree.o
--- linux-2.6.36/drivers/staging/kztmem/Kconfig	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-kztmem/drivers/staging/kztmem/Kconfig	2010-11-29 09:10:32.000000000 -0700
@@ -0,0 +1,8 @@
+config KZTMEM
+	tristate "In-kernel transcendent memory using compression"
+	select XVMALLOC
+	select LZO_COMPRESS
+	select LZO_DECOMPRESS
+	default n
+	help
+	  In-kernel transcendent memory using compression
--- linux-2.6.36/drivers/staging/Makefile	2010-10-20 14:30:22.000000000 -0600
+++ linux-2.6.36-kztmem/drivers/staging/Makefile	2010-11-29 09:07:07.000000000 -0700
@@ -40,6 +40,7 @@ obj-$(CONFIG_VME_BUS)		+= vme/
 obj-$(CONFIG_MRST_RAR_HANDLER)	+= memrar/
 obj-$(CONFIG_IIO)		+= iio/
 obj-$(CONFIG_ZRAM)		+= zram/
+obj-$(CONFIG_KZTMEM)		+= kztmem/
 obj-$(CONFIG_WLAGS49_H2)	+= wlags49_h2/
 obj-$(CONFIG_WLAGS49_H25)	+= wlags49_h25/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
--- linux-2.6.36/drivers/staging/Kconfig	2010-10-20 14:30:22.000000000 -0600
+++ linux-2.6.36-kztmem/drivers/staging/Kconfig	2010-11-29 09:07:22.000000000 -0700
@@ -117,6 +117,8 @@ source "drivers/staging/iio/Kconfig"
 
 source "drivers/staging/zram/Kconfig"
 
+source "drivers/staging/kztmem/Kconfig"
+
 source "drivers/staging/wlags49_h2/Kconfig"
 
 source "drivers/staging/wlags49_h25/Kconfig"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
