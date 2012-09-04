Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 4FCDA6B006C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:04:14 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 4 Sep 2012 16:04:12 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E89166E80B5
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:03:36 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q84K3aP7062846
	for <linux-mm@kvack.org>; Tue, 4 Sep 2012 16:03:36 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q84K3ZLI009035
	for <linux-mm@kvack.org>; Tue, 4 Sep 2012 16:03:36 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH v2 2/3] drivers: add memory management driver class
Date: Tue,  4 Sep 2012 15:02:48 -0500
Message-Id: <1346788969-4100-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1346788969-4100-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1346788969-4100-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patchset creates a new driver class under drivers/ for
memory management related drivers, like zcache.

This driver class would be for drivers that don't actually enabled
a hardware device, but rather augment the memory manager in some
way.

In-tree candidates for this driver class are zcache, zram, and
lowmemorykiller, both in staging.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/Kconfig    |    2 ++
 drivers/Makefile   |    1 +
 drivers/mm/Kconfig |    3 +++
 3 files changed, 6 insertions(+)
 create mode 100644 drivers/mm/Kconfig

diff --git a/drivers/Kconfig b/drivers/Kconfig
index 324e958..d126132 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -154,4 +154,6 @@ source "drivers/vme/Kconfig"
 
 source "drivers/pwm/Kconfig"
 
+source "drivers/mm/Kconfig"
+
 endmenu
diff --git a/drivers/Makefile b/drivers/Makefile
index d64a0f7..aa69e1c 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -140,3 +140,4 @@ obj-$(CONFIG_EXTCON)		+= extcon/
 obj-$(CONFIG_MEMORY)		+= memory/
 obj-$(CONFIG_IIO)		+= iio/
 obj-$(CONFIG_VME_BUS)		+= vme/
+obj-$(CONFIG_MM_DRIVERS)	+= mm/
diff --git a/drivers/mm/Kconfig b/drivers/mm/Kconfig
new file mode 100644
index 0000000..e5b3743
--- /dev/null
+++ b/drivers/mm/Kconfig
@@ -0,0 +1,3 @@
+menu "Memory management drivers"
+
+endmenu
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
